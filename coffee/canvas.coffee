
class Bulb.Canvas extends CJS.Component

	getRenderer: ->
		@renderer = new THREE.WebGLRenderer() if not @renderer?
		@renderer.setSize(400, 300)
		@renderer

	getScene: ->
		if not @scene?
			@scene = new THREE.Scene()
			@initScene()
		@scene

	initScene: ->
		scene = @getScene()
		gridHelper = new THREE.GridHelper(100,10)
		gridHelper.name = 'Grid Helper'
		scene.add(gridHelper)
		axisHelper = new THREE.AxisHelper(100)
		axisHelper.name = 'Axis Helper'
		scene.add(axisHelper)
		scene.add(@getCamera())
		@addLight()

	getCamera: ->
		if not @camera?
			@camera = new THREE.PerspectiveCamera(45, 400/300, 0.1, 10000)
			@camera.position.x = 0
			@camera.position.y = 10
			@camera.position.z = 50
			@camera.lookAt(new THREE.Vector3(0, 0, 0))
			@camera.name = 'Camera'
		@camera

	addLight: ->
		light = new THREE.PointLight(0xFFFFFF)
		light.name = 'Point Light'
		camera = @getCamera()
		light.position.set(camera.position.x, camera.position.y, camera.position.z)
		@getScene().add(light)
		@restoreView()

	getMaterials: ->
		[
			new THREE.MeshLambertMaterial({opacity:0.9, color: 0xFFFFFF, transparent: yes})
		  new THREE.MeshBasicMaterial({color: 0xFFFFFF, wireframe: yes})
		]

	addSphere: ->
		sphere = THREE.SceneUtils.createMultiMaterialObject(new THREE.SphereGeometry(5,16,16), @getMaterials())
		sphere.name = 'Sphere'
		@getScene().add(sphere)
		@restoreView()

	addCube: ->
		cube = THREE.SceneUtils.createMultiMaterialObject(new THREE.BoxGeometry(10,10,10,1,1,1), @getMaterials())
		cube.name = 'Cube'
		@getScene().add(cube)
		@restoreView()

	remove: (objectId) ->
		scene = @getScene()
		scene.remove(scene.getObjectById(objectId*1, yes))
		@restoreView()

	replaceObject: (id, params) ->
		scene = @getScene()
		object = scene.getObjectById(id)
		geometry = object.children[0].geometry
		geometry = new THREE.BoxGeometry(params.width, params.height, params.depth, params.widthSegments, params.heightSegments, params.depthSegments) if geometry instanceof THREE.BoxGeometry
		geometry = new THREE.SphereGeometry(params.radius, params.widthSegments, params.heightSegments, params.phiStart, params.phiLength, params.thetaStart, params.thetaLength) if geometry instanceof THREE.SphereGeometry
		newObject  = THREE.SceneUtils.createMultiMaterialObject(geometry, @getMaterials())
		newObject.parent = object.parent
		newObject.name = object.name
		scene.children[index] = newObject  for child,index in scene.children when child is object
		newObject

	renderFinish: ->
		document.getElementById(@id).appendChild(@getRenderer().domElement)

	restoreView: ->
		renderer = @getRenderer()
		scene = @getScene()
		camera = @getCamera()
		renderer.render(scene, camera)
		@getEvent('change').fire(@)
		@