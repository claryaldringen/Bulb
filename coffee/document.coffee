
class Bulb.Document extends CJS.Document

	constructor: (id, parent) ->
		super(id, parent)

	getCanvas: ->
		canvas = @getChildById('canvas')
		if not canvas?
			canvas = new Bulb.Canvas('canvas', @)
			canvas.getEvent('select').subscribe(@, @selectObjectFromCanvas)
			canvas.getEvent('transform').subscribe(@, @transform)
			canvas.getEvent('geometryChange').subscribe(@, @updateVertexList)
			canvas.getEvent('vertexHighlight').subscribe(@, @highlightVertexList)
			canvas.getEvent('vertexSelect').subscribe(@, @selectVertexList)
		canvas

	getToolbar: ->
		toolbar = @getChildById('toolbar')
		if not toolbar?
			canvas = @getCanvas()
			toolbar = new Bulb.Toolbar('toolbar', @)
			toolbar.getEvent('doSave').subscribe(@, @save)
			toolbar.getEvent('doLoad').subscribe(@, @load)
			toolbar.getEvent('addVector').subscribe(canvas, canvas.addVector)
			toolbar.getEvent('addCircle').subscribe(canvas, canvas.addCircle)
			toolbar.getEvent('addPlane').subscribe(canvas, canvas.addPlane)
			toolbar.getEvent('addCube').subscribe(canvas, canvas.addCube)
			toolbar.getEvent('addSphere').subscribe(canvas, canvas.addSphere)
			toolbar.getEvent('addCylinder').subscribe(canvas, canvas.addCylinder)
			toolbar.getEvent('addTorus').subscribe(canvas, canvas.addTorus)
			toolbar.getEvent('addLight').subscribe(canvas, canvas.addLight)
			toolbar.getEvent('changeTransformMode').subscribe(canvas, canvas.setTransformMode)
			toolbar.getEvent('changeTransformSpace').subscribe(canvas, canvas.setTransformSpace)
		toolbar

	getObjectList: ->
		objectList = @getChildById('objectList');
		if not objectList?
			objectList = new Bulb.ObjectList('objectList', @)
			objectList.setItems(@getCanvas().getObjectCollection().getAsArray('objects'))
			objectList.getEvent('select').subscribe(@, @selectObjectFromObjectList)
			objectList.getEvent('rename').subscribe(@, @renameObject)
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
				@getCanvas().setMode(Bulb.MODE_MESH)
			when 'geometry'
				if not child?
					child = new Bulb.GeometryPropertyList(id, tabMenu)
					child.getEvent('change').subscribe(@, @geometryChange)
				child.setGeometry(object.geometry.parameters)
			when 'vertices'
				canvas = @getCanvas().setMode(Bulb.MODE_VERTICES)
				if not child?
					child = new Bulb.VertexList(id, tabMenu) if not child?
					child.getEvent('change').subscribe(canvas, canvas.changeGeometry)
					child.getEvent('highlight').subscribe(canvas, canvas.highlightVertex)
					child.getEvent('dishighlight').subscribe(canvas, canvas.dishighlightVertex)
					child.getEvent('select').subscribe(canvas, canvas.selectVector)
				child.setVertices(object.geometry.vertices).setHighlighted().setSelected() if object?


	getProperties: ->
		properties = @getChildById('properties')
		if not properties
			properties = new CJS.TabMenu('properties', @)
			properties.addTab('mesh', 'Mesh', yes).addTab('geometry', 'Geometry').addTab('vertices', 'Vertices')
			properties.getEvent('change').subscribe(@, @propertyTabChange).fire(properties)
		properties

	selectObjectFromCanvas: (selectedObjectId) ->
		@getObjectList().setSelectedItemId(selectedObjectId).render()
		properties = @getProperties()
		@propertyTabChange(properties)
		properties.render()

	selectObjectFromObjectList: (selectedObjectId) ->
		@getCanvas().selectObject(selectedObjectId, no)
		properties = @getProperties()
		@propertyTabChange(properties)
		properties.render()

	geometryChange: (propertyList) -> @getCanvas().replaceObject(propertyList.getGeometry())

	updateVertexList: (object) ->
		@getProperties().render()

	highlightVertexList: (index) ->
		properties = @getProperties()
		properties.getChildById(properties.getChildId(properties.getSelectedTab().id)).setHighlighted(index)
		properties.render()

	selectVertexList: (index) ->
		properties = @getProperties()
		properties.getChildById(properties.getChildId(properties.getSelectedTab().id)).setSelected(index)
		properties.render()

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

	transform: (object) ->
		tabMenu = @getProperties()
		tab = tabMenu.getSelectedTab()
		if tab.id is 'mesh'
			id = tabMenu.getChildId(tab.id)
			tabMenu.getChildById(id).setPosition(object.position).setRotation(object.rotation).setScale(object.scale)
		@

	renameObject: (params) ->
		@getCanvas().renameObject(params.id, params.value)

	save: ->
		object = @getCanvas().getSelectedObject()
		exporter = new THREE.OBJExporter()
		output = exporter.parse(object)
		blob = new Blob( [output], {type: 'text/plain' })

		link = document.createElement('a')
		link.href = URL.createObjectURL(blob)
		link.download = 'model.obj'
		link.target = '_blank'
		link.click()

	load: ->

		el = document.createElement('input')
		el.type = 'file'
		el.accept = '.obj'
		el.addEventListener 'change', (event) =>
			file = event.target.files[0]
			reader = new FileReader()
			reader.onload = (frEvent) =>
				data = frEvent.target.result
				loader = new THREE.OBJLoader()
				@getCanvas().addLoadedObject(loader.parse(data))
			reader.readAsText(file)
		el.click()

	bindEvents: ->
		super()
		canvas = @getCanvas()
		objectList = @getObjectList()
		canvas.getEvent('objectAdded').subscribe(objectList, objectList.restore)
		objectList.getEvent('remove').subscribe(canvas, canvas.remove)
		window.addEventListener 'resize', => @getCanvas().resize()

	getHtml: ->
		toolbar = @getToolbar()
		html = '<div id="' + toolbar.getId() + '">' + toolbar.getHtml() + '</div>'

		html += '<div class="rightColumn"><div class="title">Object List</div>'
		objectList = @getObjectList()
		html += '<div id="' + objectList.getId() + '">' + objectList.getHtml() + '</div>'

		properties = @getProperties()
		html += '<div id="' + properties.getId() + '">' + properties.getHtml() + '</div>'
		html += '</div>'

		canvas = @getCanvas()
		html += '<div id="' + canvas.getId() + '">' + canvas.getHtml() + '</div>'
