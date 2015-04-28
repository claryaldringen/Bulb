
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

	getSettings: (canvas) ->
		round = (num) -> Math.round(num*100)/100
		objects = canvas.getObjectCollection().getAsArray('objects')
		scene = canvas.getScene()
		scene.userData.maxNumberOfParticles = 0 if not scene.userData.maxNumberOfParticles?
		scene.userData.distanceLimitForTesselation = 0 if not scene.userData.distanceLimitForTesselation?
		output1 = "# models (filename reverseWinding scaleFactor translation)\n"
		output2 = "# fluid and wind source (rate position size)\n"
		output3 = "# material (sediment_change max_sediment_in_particle critical_shear)\n"
		for object,i in objects
			object.userData = @fillDefaultModel(object.userData)
			type = object.userData.type
			if type is 'm'
				output1 += type + ' ' + object.name + i + '.obj ' + (if object.userData.reverseWinding then '1' else '0') + ' '
				output1 += object.scale.x + '/' + object.scale.y + '/' + object.scale.z + ' '
				output1 += round(object.position.x) + '/' + round(object.position.y) + '/' + round(object.position.z) + "\n"

				output3 += 's ' + object.userData.sediment.sedimentChange + ' ' + scene.userData.maxNumberOfParticles + ' ' + object.userData.sediment.criticalShear + "\n"
			else
				output2 += type + ' ' + object.userData.rate + ' ' + object.position.x + '/' + object.position.y + '/' + object.position.z + ' ' + object.scale.x + '/' + object.scale.y + '/' + object.scale.z + "\n"
		output2 += "\n# maximum number of particles\np #{scene.userData.maxNumberOfParticles}\n\n# distance limit for tesselation\nd #{scene.userData.distanceLimitForTesselation}\n"
		"# Scene settings\n----------------\n" + output1 + "\n" + output2 + "\n" + output3

	getAll: (filename, canvas, callback) ->
		objects = canvas.getObjectCollection().getAsArray('objects')
		exporter = @getObjExporter()
		files = []
		for object,i in objects
			object.userData = @fillDefaultModel(object.userData)
			if object.userData.type is 'm'
				cloned = object.clone()
				cloned.position.set(0,0,0)
				cloned.scale.set(1,1,1)
				cloned.updateMatrixWorld()
				files.push({name: object.name + i + '.obj', content: new Blob([exporter.parse(cloned)], {type: 'text/plain' })})
		files.push({name: filename + '.settings', content: new Blob([@getSettings(canvas)], {type: 'text/plain' })})
		zipper = new Bulb.Zipper()
		zipper.addFiles(files, (zipped) -> callback(zipped, filename + '.zip'))

	fillDefaultModel: (userData) ->
		if not userData.type?
			userData.type = 'm'
			userData.reverseWinding = 0
			userData.sediment = {sedimentChange: 0, criticalShear: 0}
		userData

