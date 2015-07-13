
class Bulb.Exporter

	getObjExporter: ->
		@exporter = new THREE.OBJExporter() if not @exporter?
		@exporter

	getObjectObj: (canvas) -> @getObjExporter().parse(canvas.getSelectedObject())

	getSceneObj: (canvas)->
		objects = canvas.getObjectCollection().getAsArray('objects')
		output = new THREE.Scene()
		output.add(object.clone()) for object in objects
		@getExporter().parse(output)

	getSettings: (canvas, callback) ->
		objects = canvas.getObjectCollection().getAsArray('objects')
		output = new THREE.Scene()
		output.userData = canvas.getScene().userData
		output.add(object.clone()) for object in objects
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

	getSceneX3d: (canvas, title)->
		output = '<!DOCTYPE html><html><title>' + title + '</title>'
		output += '<script type="text/javascript" src="http://www.x3dom.org/download/x3dom.js"> </script>'
		output += '<link rel="stylesheet" type="text/css" href="http://www.x3dom.org/download/x3dom.css"> </link>'
		output += '</head><body>'
		output += '<x3d width="' + (canvas.getWidth() - 100) + 'px" height="' + (canvas.getHeight() - 100) + 'px">'
		output += '<Scene>'
		for object in canvas.getObjectCollection().getAsArray('objects')
			output += '<Transform '
			output += 'translation="' + object.position.x + ' ' + object.position.y + ' ' + object.position.z + '" '
			output += 'rotation="' + object.rotation.x + ' ' + object.rotation.y + ' ' + object.rotation.z + '" '
			output += 'scale="' + object.scale.x + ' ' + object.scale.y + ' ' + object.scale.z + '" '
			output += '>'
			output += '<Shape>'
			output += '<Appearance><Material diffuseColor="0.6 0.6 0.6"></Material></Appearance>'
			output += '<IndexedTriangleSet index="'
			output += face.a + ' ' + face.b + ' ' + face.c + ' ' for face in object.geometry.faces
			output += '">'
			output += '<Coordinate point="'
			output += vector.x + ' ' + vector.y + ' ' + vector.z + ' ' for vector in object.geometry.vertices
			output += '">'
			output += '</Coordinate>'
			output += '<Normal vector="'
			output += face.normal.x + ' ' + face.normal.y + ' ' + face.normal.z + ' ' for face in object.geometry.faces
			output += '">'
			output += '</Normal>'
			output += '</IndexedTriangleSet>'
			output += '</Shape>'
			output += '</Transform>'
		output += '</Scene>'
		output += '</x3d>'
		output += '</body></html>'
