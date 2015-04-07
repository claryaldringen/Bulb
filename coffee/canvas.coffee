
class Bulb.Canvas extends CJS.Component

	constructor: (id, parent) ->
		super(id, parent)
		@rendered = no
		@selectAllowed = yes
		@transformed = no
		@selectedObject = null
		@wireframeHelper = {}
		@mode = Bulb.MODE_MESH

	setMode: (mode) ->
		if @mode isnt mode
			if @selectedObject?
				controls = @getTransformControls()
				scene = @getScene()
				if mode is Bulb.MODE_VERTICES
					controls.detach(@selectedObject)
					scene.remove(controls)
					vertexHelper = @getVertexHelper()
					vertexHelper.attach(@selectedObject)
					scene.add(vertexHelper)
				if mode is Bulb.MODE_MESH
					vertexHelper = @getVertexHelper()
					vertexHelper.detach()
					scene.remove(vertexHelper)
					vertexControl = @getVertexControl()
					vertexControl.detach()
					scene.remove(vertexControl)
					controls.attach(@selectedObject)
					scene.add(controls)
					scene.remove(@getVertexHelper())
				@restoreView()
			@mode = mode
		@

	getObjectCollection: ->
		@objectCollection = new Bulb.ObjectCollection() if not @objectCollection?
		@objectCollection

	setTransformMode: (mode) ->
		@getTransformControls().setMode(mode)
		@

	setTransformSpace: (space) ->
		@getTransformControls().setSpace(space)
		@getVertexControl().setSpace(space)
		@

	getWidth: -> window.innerWidth

	getHeight: -> window.innerHeight - 3

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
		gridHelper = new THREE.GridHelper(10,1)
		gridHelper.name = 'Grid Helper'
		scene.add(gridHelper)
		axisHelper = new THREE.AxisHelper(10)
		axisHelper.name = 'Axis Helper'
		scene.add(axisHelper)
		scene.add(@getCamera())
		ambientLight = new THREE.AmbientLight(0x1C1C1C)
		ambientLight.name = 'Ambient Light'
		scene.add(ambientLight)
		@addLight()

	getCamera: ->
		if not @camera?
			@camera = new THREE.PerspectiveCamera(45, @getWidth()/@getHeight(), 0.1, 1000)
			@camera.position.x = 3
			@camera.position.y = 5
			@camera.position.z = 10
			@camera.lookAt(new THREE.Vector3(0, 0, 0))
			@camera.name = 'Camera'
		@camera

	getTrackballControls: ->
		if not @trackballControls?
			@trackballControls = new THREE.TrackballControls(@getCamera(), document.getElementById(@id))
			@trackballControls.rotateSpeed = 1.0
			@trackballControls.panSpeed = 1.0
			@trackballControls.zoomSpeed = 1.0
			@trackballControls.staticMoving = yes
			@trackballControls.addEventListener 'change', => @restoreView()
		@trackballControls

	getTransformControls: ->
		if not @transformControls?
			@transformControls = new THREE.TransformControls(@getCamera(), document.getElementById(@id))
			@transformControls.name = 'Transform Controls'
			@transformControls.setSnap(0.01).setScaleSpeed(50)
			@transformControls.addEventListener 'change', =>
				object = @transformControls.getAttached()
				@getEvent('transform').fire(object) if object?
				@restoreView()
			@transformControls.addEventListener 'mouseUp', => @transformed = yes
		@transformControls

	getMouse: ->
		@mouse = new THREE.Vector2() if not @mouse?
		@mouse

	getRaycaster: ->
		@raycaster = new THREE.Raycaster() if not @raycaster?
		@raycaster

	getSelectedObject: -> @selectedObject

	getVertexHelper: ->
		if not @vertexHelper?
			vertexHelper = new Bulb.VertexHelper(@getCamera(), document.getElementById(@id))
			vertexHelper.name = 'Vertex Helper'
			@getObjectCollection().add('helpers', vertexHelper)
			vertexHelper.addEventListener 'change', =>
				@restoreView()
				@getEvent('vertexHighlight').fire(vertexHelper.getSelectedVectorIndex())
			vertexHelper.addEventListener 'select', =>
				@selectVector(vertexHelper.getSelectedVector())
				@getEvent('vertexSelect').fire(vertexHelper.getSelectedVectorIndex())
			@vertexHelper = vertexHelper
		@vertexHelper

	getVertexControl: ->
		if not @vertexControl?
			vertexControl = new Bulb.VertexControl(@getCamera(), document.getElementById(@id))
			vertexControl.addEventListener 'change', =>
				@changeGeometry()
				@getEvent('geometryChange').fire(@selectedObject)
			@vertexControl = vertexControl
		@vertexControl

	addLight: ->
		light = new THREE.PointLight(0xFFFFFF)
		light.name = 'Point Light'
		camera = @getCamera()
		light.position.set(camera.position.x, camera.position.y, camera.position.z)
		@getScene().add(light)
		@restoreView()

	getMaterial: -> new THREE.MeshLambertMaterial({color: 0x999999})

	addLoadedObject: (object) ->
		object = object.children[0]
		geometry = new THREE.Geometry().fromBufferGeometry(object.geometry)
		geometry.mergeVertices()
		@addObject(geometry, object.name)

	addObject: (geometry, name) ->
		object = new THREE.Mesh(geometry, @getMaterial())
		object.name = name
		@getScene().add(object)
		@getObjectCollection().add('objects', object)
		@getEvent('objectAdded').fire(@getObjectCollection().getAsArray('objects'))
		@restoreView()

	addCircle: -> @addObject(new THREE.CircleGeometry(1,8, 0, 2 * Math.PI), 'Circle')

	addPlane: -> @addObject(new THREE.PlaneGeometry(1,1), 'Plane')

	addSphere: -> @addObject(new THREE.SphereGeometry(1,16,16), 'Sphere')

	addCube: -> @addObject(new THREE.BoxGeometry(1,1,1,1,1,1), 'Cube')

	addCylinder: -> @addObject(new THREE.CylinderGeometry(1,1,1,8,1, no, 0, 2 * Math.PI), 'Cylinder')

	addTorus: -> @addObject(new THREE.TorusGeometry(1,0.5,32,32), 'Torus')

	addVector: ->
		geometry = new THREE.Geometry()
		geometry.vertices.push(new THREE.Vector3(0,0,0))
		@addObject(geometry, 'Vector')

	addWireframeHelper: (key, object) ->
		if not @wireframeHelper[key]?
			helper = new THREE.WireframeHelper(object)
			helper.name = 'Wireframe Helper'
			helper.material.depthTest = no
			helper.material.opacity = 0.25
			helper.material.transparent = yes
			@wireframeHelper[key] = helper
			@getScene().add(helper)
		@

	removeWireframeHelper: (key) ->
		if @wireframeHelper[key]?
			@getScene().remove(@wireframeHelper[key])
			delete(@wireframeHelper[key])
		@

	remove: (objectId) ->
		scene = @getScene()
		object = scene.getObjectById(objectId*1, yes)
		scene.remove(object)
		@getObjectCollection().remove('objects', object)
		@getEvent('objectAdded').fire(@getObjectCollection().getAsArray('objects'))
		@restoreView()

	replaceObject: (params) ->
		@selectedObject.geometry.dispose()
		switch @selectedObject.geometry.type
			when 'BoxGeometry' then @selectedObject.geometry = new THREE.BoxGeometry(params.width*1, params.height*1, params.depth*1, params.widthSegments*1, params.heightSegments*1, params.depthSegments*1)
			when 'CircleGeometry' then @selectedObject.geometry = new THREE.CircleGeometry(params.radius*1, params.segments*1, params.thetaStart*1, params.thetaLength*1)
			when 'CylinderGeometry' then @selectedObject.geometry = new THREE.CylinderGeometry(params.radiusTop*1, params.radiusBottom*1, params.height*1, params.radialSegments*1, params.heightSegments*1, params.openEnded*1, params.thetaStart*1, params.thetaLength*1)
			when 'PlaneGeometry' then @selectedObject.geometry = new THREE.PlaneGeometry(params.width*1, params.height*1, params.widthSegments*1, params.heightSegments*1)
			when 'SphereGeometry' then @selectedObject.geometry = new THREE.SphereGeometry(params.radius*1, params.widthSegments*1, params.heightSegments*1, params.phiStart*1, params.phiLength*1, params.thetaStart*1, params.thetaLength*1)
			when 'TorusGeometry' then @selectedObject.geometry = new THREE.TorusGeometry(params.radius*1, params.tube*1, params.radialSegments*1, params.tubularSegments*1, params.arc*1)
		@changeGeometry()
		@

	changeGeometry: ->
		@selectedObject.geometry.dynamic = yes
		@selectedObject.geometry.verticesNeedUpdate = yes
		@selectedObject.geometry.normalsNeedUpdate = yes
		@selectedObject.geometry.computeFaceNormals()
		@selectedObject.geometry.computeBoundingSphere()
		@removeWireframeHelper('select').addWireframeHelper('select', @selectedObject).restoreView()
		@


	selectObject: (objectId, fireEvent = yes) ->
		scene = @getScene()
		control = @getTransformControls()
		@removeWireframeHelper('select')
		if objectId?
			@selectedObject = scene.getObjectById(objectId)
			control.attach(@selectedObject)
			scene.add(control)
			@addWireframeHelper('select', @selectedObject)
			if @mode is Bulb.MODE_VERTICES
				vertexHelper = @getVertexHelper()
				vertexHelper.attach(@selectedObject)
				scene.add(vertexHelper)
			@transformed = no
			@getEvent('select').fire(@selectedObject.id) if fireEvent
		else if @transformed
			@transformed = no
		else
			control.detach(control.getAttached())
			scene.remove(control)
			@getVertexHelper().detach()
			@getEvent('select').fire(null) if fireEvent
		@restoreView()

	selectVector: (vector) ->
		scene = @getScene()
		if vector?
			scene.add(@getVertexControl().attach(vector, @getSelectedObject()))
		@restoreView()

	highlightVertex: (vertex) ->
		@getVertexHelper().show(vertex)
		@restoreView()

	dishighlightVertex: ->
		@getVertexHelper().hide()
		@restoreView()

	getIntersect: (event, objects)->
		mouse = @getMouse()
		mouse.set(( event.clientX / @getWidth() ) * 2 - 1, - ( event.clientY / @getHeight() ) * 2 + 1)
		camera = @getCamera()
		raycaster = @getRaycaster()
		raycaster.setFromCamera(mouse, camera)
		intersects = raycaster.intersectObjects(objects, yes)
		if intersects[0]? then intersects[0].object else null

	mouseOverMesh: (event) ->
		object = @getIntersect(event, @getObjectCollection().getAsArray('objects'))
		if object?
			@addWireframeHelper('over', object)
		else
			@removeWireframeHelper('over')
		@restoreView()

	mouseMove: (element, event) ->
		switch @mode
			when Bulb.MODE_MESH then @mouseOverMesh(event)

	click: (element, event) ->
		modes = { 1: 'objects', 2: 'helpers'}
		object = @getIntersect(event, @getObjectCollection().getAsArray(modes[@mode]))
		@selectObject(object?.id) if @mode is Bulb.MODE_MESH
		@selectVector() if @mode is Bulb.MODE_VERTICES

	resize: ->
		camera = @getCamera()
		camera.aspect = window.innerWidth / window.innerHeight
		camera.updateProjectionMatrix()
		@getRenderer().setSize(window.innerWidth, window.innerHeight)
		@trackballControls.handleResize() if @trackballControls?
		@

	renderFinish: ->
		document.getElementById(@id).appendChild(@getRenderer().domElement)
		@rendered = yes
		@getTrackballControls()
		@animate()

	restoreView: ->
		if @rendered
			renderer = @getRenderer()
			scene = @getScene()
			camera = @getCamera()
			@transformControls.update() if @transformControls?
			@vertexHelper.update() if @vertexHelper?
			@vertexControl.update() if @vertexControl?
			renderer.render(scene, camera)
		@

	animate: ->
		window.requestAnimationFrame( => @animate())
		@trackballControls.update() if @trackballControls?

