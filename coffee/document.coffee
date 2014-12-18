
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
		objectList = @getChildById('object_list');
		if not objectList?
			objectList = new Bulb.ObjectList('object_list', @)
			objectList.setItems(@getCanvas().getScene().children)
		objectList

#	getPropertyList:  ->
#		propertyList = @getChildById('properties')
#		if not propertyList
#			propertyList = new Bulb.PropertyList('properties')
#			propertyList.getEvent('changeGeometry').subscribe(@, @geometryChange)
#			propertyList.getEvent('change').subscribe(@, @propertyChange)
#			propertyList.setParent(@)
#		propertyList

	propertyTabChange: (tabMenu) ->
		tab = tabMenu.getSelectedTab()
		id = tabMenu.getChildId(tab.id)
		childId = tabMenu.getChildById(id)
		if not childId?
			switch tab.id
				when 'mesh' then new Bulb.MeshPropertyList(id, tabMenu)
				when 'geometry' then new Bulb.GeometryPropertyList(id, tabMenu)
				when 'vertices' then new Bulb.VertexList(id, tabMenu)

	getProperties: ->
		properties = @getChildById('properties')
		if not properties
			properties = new CJS.TabMenu('properties', @)
			properties.addTab('mesh', 'Mesh', yes).addTab('geometry', 'Geometry').addTab('vertices', 'Vertices')
			properties.getEvent('change').subscribe(@, @propertyTabChange).fire(properties)
		properties

	selectObject: (objectList) ->
		object = @getCanvas().getScene().getObjectById(objectList.getSelectedItemId())
		object = {position: null, rotation: null} if not object?
		@getPropertyList()
			.setPosition(object.position)
			.setRotation(object.rotation)
			.setScale(object.scale)
			.setGeometry(object.children[0].geometry.parameters)
			.setVertices(object.children[0].geometry.vertices)
			.render()

	geometryChange: (propertyList) ->
		objectList = @getObjectList()
		params = propertyList.getGeometry()
		object = @getCanvas().replaceObject(objectList.getSelectedItemId(), params)
		objectList.setSelectedItemId(object.id).render()
		propertyList.setVertices(object.children[0].geometry.vertices).render()
		@propertyChange(propertyList)

	propertyChange: (propertyList) ->
		position = propertyList.getPosition()
		rotation = propertyList.getRotation()
		scale = propertyList.getScale()
		vertices = propertyList.getVertices()
		canvas = @getCanvas()
		object = canvas.getScene().getObjectById(@getObjectList().getSelectedItemId())
		object.position.set(position.x, position.y, position.z)
		object.rotation.set(rotation.x, rotation.y, rotation.z)
		object.scale.set(scale.x, scale.y, scale.z)

		vectors = []
		vectors.push(new THREE.Vector3(vertice.x, vertice.y, vertice.z)) for vertice in vertices
		object.children.forEach (child) ->
			child.geometry.vertices = vectors
			child.geometry.verticesNeedUpdate = yes

		object.lookAt(new THREE.Vector3(0, 0, 0)) if object instanceof THREE.Camera
		canvas.restoreView()
		propertyList

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

		canvas = @getCanvas()
		html += '<div id="' + canvas.getId() + '">' + canvas.getHtml() + '</div>'

		objectList = @getObjectList()
		html += '<div id="object_list">' + objectList.getHtml() + '</div>'

		#object = canvas.getScene().getObjectById(objectList.getSelectedItemId())
		#propertyList = @getPropertyList(object?.geometry)
		properties = @getProperties()
		html += '<div id="properties">' + properties.getHtml() + '</div>'