
class Bulb.Document extends CJS.Document

	constructor: (id, parent) ->
		super(id, parent)

	getCanvas: ->
		canvas = @getChildById('canvas')
		canvas = new Bulb.Canvas('canvas', @) if not canvas?
		canvas

	getToolbar: ->
		toolbar = @getChildById('toolbar')
		if not toolbar?
			canvas = @getCanvas()
			toolbar = new Bulb.Toolbar('toolbar', @)
			toolbar.getEvent('addCircle').subscribe(canvas, canvas.addCircle)
			toolbar.getEvent('addPlane').subscribe(canvas, canvas.addPlane)
			toolbar.getEvent('addCube').subscribe(canvas, canvas.addCube)
			toolbar.getEvent('addSphere').subscribe(canvas, canvas.addSphere)
			toolbar.getEvent('addCylinder').subscribe(canvas, canvas.addCylinder)
			toolbar.getEvent('addDodecahedron').subscribe(canvas, canvas.addDodecahedron)
			toolbar.getEvent('addTorus').subscribe(canvas, canvas.addTorus)
			toolbar.getEvent('addLight').subscribe(canvas, canvas.addLight)
		toolbar

	getObjectList: ->
		objectList = @getChildById('objectList');
		if not objectList?
			objectList = new Bulb.ObjectList('objectList', @)
			objectList.setItems(@getCanvas().getScene().children)
		objectList

	propertyTabChange: (tabMenu) ->
		tab = tabMenu.getSelectedTab()
		id = tabMenu.getChildId(tab.id)
		child = tabMenu.getChildById(id)
		object = @getCanvas().getScene().getObjectById(@getObjectList().getSelectedItemId())
		switch tab.id
			when 'mesh'
				if not child?
					child = new Bulb.MeshPropertyList(id, tabMenu)
					child.getEvent('change').subscribe(@, @meshChange)
				object = {position: null, rotation: null} if not object?
				child.setPosition(object.position).setRotation(object.rotation).setScale(object.scale)
			when 'geometry'
				if not child?
					child = new Bulb.GeometryPropertyList(id, tabMenu)
					child.getEvent('change').subscribe(@, @geometryChange)
				child.setGeometry(object.children[0].geometry.parameters)
			when 'vertices'
				if not child?
					child = new Bulb.VertexList(id, tabMenu) if not child?
					child.getEvent('change').subscribe(@, @vertexChange)
				child.setVertices(object.children[0].geometry.vertices)

	getProperties: ->
		properties = @getChildById('properties')
		if not properties
			properties = new CJS.TabMenu('properties', @)
			properties.addTab('mesh', 'Mesh', yes).addTab('geometry', 'Geometry').addTab('vertices', 'Vertices')
			properties.getEvent('change').subscribe(@, @propertyTabChange).fire(properties)
		properties

	selectObject: (objectList) ->
		properties = @getProperties()
		@propertyTabChange(properties)
		properties.render()

	geometryChange: (propertyList) ->
		objectList = @getObjectList()
		params = propertyList.getGeometry()
		canvas = @getCanvas()
		object = canvas.replaceObject(objectList.getSelectedItemId(), params)
		objectList.setSelectedItemId(object.id).render()
		canvas.restoreView()

	meshChange: (meshPropertyList) ->
		position = meshPropertyList.getPosition()
		rotation = meshPropertyList.getRotation()
		scale = meshPropertyList.getScale()
		canvas = @getCanvas()
		object = canvas.getScene().getObjectById(@getObjectList().getSelectedItemId())
		object.position.set(position.x, position.y, position.z)
		object.rotation.set(rotation.x, rotation.y, rotation.z)
		object.scale.set(scale.x, scale.y, scale.z)
		object.lookAt(new THREE.Vector3(0, 0, 0)) if object instanceof THREE.Camera
		canvas.restoreView()

	vertexChange: (vertexList) ->
		vectors = []
		vectors.push(new THREE.Vector3(vertex.x, vertex.y, vertex.z)) for vertex in vertexList.getVertices()
		canvas = @getCanvas()
		object = canvas.getScene().getObjectById(@getObjectList().getSelectedItemId())
		object.children.forEach (child) ->
			child.geometry.vertices = vectors
			child.geometry.verticesNeedUpdate = yes
		canvas.restoreView()

	renderFinish: ->
		super()
		document.getElementById('objectList').style.height = Math.round(window.innerHeight - 360) + 'px'

		bindEvents: ->
		super()
		canvas = @getCanvas()
		objectList = @getObjectList()
		canvas.getEvent('change').subscribe(objectList, objectList.restore)
		objectList.getEvent('remove').subscribe(canvas, canvas.remove)
		objectList.getEvent('select').subscribe(@, @selectObject)


	getHtml: ->
		toolbar = @getToolbar()
		html = '<div id="' + toolbar.getId() + '">' + toolbar.getHtml() + '</div>'

		html += '<div class="rightColumn">'
		objectList = @getObjectList()
		html += '<div id="' + objectList.getId() + '">' + objectList.getHtml() + '</div>'

		properties = @getProperties()
		html += '<div id="' + properties.getId() + '">' + properties.getHtml() + '</div>'
		html += '</div>'

		canvas = @getCanvas()
		html += '<div id="' + canvas.getId() + '">' + canvas.getHtml() + '</div>'
