
class Bulb.Canvas extends CJS.Component

	getWidth: -> window.innerWidth - 345

	getHeight: -> window.innerHeight - 20

	getRenderer: ->
		@renderer = new THREE.WebGLRenderer() if not @renderer?
		@renderer.setSize(@getWidth(), @getHeight())
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
			@camera = new THREE.PerspectiveCamera(45, @getWidth()/@getHeight(), 0.1, 10000)
			@camera.position.x = 0
			@camera.position.y = 10
			@camera.position.z = 50
			@camera.lookAt(new THREE.Vector3(0, 0, 0))
			@camera.name = 'Camera'
		@camera

	getTrackballControls: ->
		if not @trackballControls?
			@trackballControls = new THREE.TrackballControls(@getCamera())
			@trackballControls.rotateSpeed = 1.0
			@trackballControls.panSpeed = 1.0
			@trackballControls.zoomSpeed = 1.0
			@trackballControls.staticMoving = yes
		@trackballControls

	getClock: ->
		@clock = new THREE.Clock() if not @clock?
		@clock

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

	addObject: (geometry, name) ->
		object = THREE.SceneUtils.createMultiMaterialObject(geometry, @getMaterials())
		object.name = name
		@getScene().add(object)
		@restoreView()

	addCircle: -> @addObject(new THREE.CircleGeometry(5, 32), 'Circle')

	addPlane: -> @addObject(new THREE.PlaneGeometry(10,10), 'Plane')

	addSphere: -> @addObject(new THREE.SphereGeometry(5,16,16), 'Sphere')

	addCube: -> @addObject(new THREE.BoxGeometry(10,10,10,1,1,1), 'Cube')

	addCylinder: -> @addObject(new THREE.CylinderGeometry(5,5,10), 'Cylinder')

	addDodecahedron: -> @addObject(new THREE.DodecahedronGeometry(5), 'Dodecahedron')

	addTorus: -> @addObject(new THREE.TorusGeometry(5,2,8,8), 'Torus')

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
		newObject.position.set(object.position.x, object.position.y, object.position.z)
		newObject.rotation.set(object.rotation.x, object.rotation.y, object.rotation.z)
		scene.children[index] = newObject  for child,index in scene.children when child is object
		newObject

	renderFinish: ->
		document.getElementById(@id).appendChild(@getRenderer().domElement)

	restoreView: ->
		renderer = @getRenderer()
		scene = @getScene()
		camera = @getCamera()
		trackballControls = @getTrackballControls()
		trackballControls.update(@getClock().getDelta())
		window.requestAnimationFrame => @restoreView()
		renderer.render(scene, camera)
		@getEvent('change').fire(@)
		@
