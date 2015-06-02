
class Bulb.Exporter

	getObjExporter: ->
		@exporter = new THREE.OBJExporter() if not @exporter?
		@exporter

	getObjectObj: (canvas) -> @getObjExporter().parse(canvas.getSelectedObject())

	getSceneObj: (canvas)->
		objects = canvas.getObjectCollection().getAsArray('objects')
		output = new THREE.Scene()
		output.add(object) for object in objects
		@getExporter().parse(output)

	getSettings: (canvas, callback) ->
		objects = canvas.getObjectCollection().getAsArray('objects')
		output = new THREE.Scene()
		output.userData = canvas.getScene().userData
		output.add(object) for object in objects
		callback = 'var func = ' + callback
		eval(callback)
		func(output)

	checkRules: (data, rules) ->
		logic = null
		prevOperator = yes
		for rule in rules
			operator = no
			operator = yes if rule.operator is 'is' and data[rule.name] is rule.value
			operator = yes if rule.operator is 'isnt' and data[rule.name] isnt rule.value
			if logic is 'and'
				if operator and prevOperator then prevOperator = yes else return no
				logic = rule.next
				break
			if logic is 'or'
				if operator or prevOperator then prevOperator = yes else return no
				logic = rule.next
				break
			prevOperator = operator
			logic = rule.next
		prevOperator


	getAll: (filename, canvas, callback) ->
		objects = canvas.getObjectCollection().getAsArray('objects')
		exporter = @getObjExporter()
		files = []
		json = localStorage.getItem('zip_rules')
		if json? then rules = JSON.parse(json) else rules = []
		for object,i in objects when @checkRules(object.userData, rules)
			cloned = object.clone()
			cloned.position.set(0,0,0)
			cloned.scale.set(1,1,1)
			cloned.updateMatrixWorld()
			files.push({name: object.name + '.obj', content: new Blob([exporter.parse(cloned)], {type: 'text/plain' })})
		json = localStorage.getItem('scripts')
		if json?
			scripts = JSON.parse(json)
			for script in scripts when script.type is 'export' and script.code isnt ''
				files.push({name: filename + '.' + script.extension, content: new Blob([@getSettings(canvas, script.code)], {type: 'text/plain' })})
		zipper = new Bulb.Zipper()
		zipper.addFiles(files, (zipped) -> callback(zipped, filename + '.zip'))
