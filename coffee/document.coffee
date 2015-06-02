
class Bulb.Document extends CJS.Document

	constructor: (id, parent) ->
		super(id, parent)
		@active = yes

	clear: ->
		window.indexedDB.deleteDatabase('Bulb')
		window.document.location.reload(yes)

	setActive: (@active) -> @

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
			toolbar.getEvent('doSave').subscribe(@, => @getSaveDialog().open('Save...'))
			toolbar.getEvent('doNew').subscribe(@, @clear)
			toolbar.getEvent('doLoad').subscribe(@, @load)
			toolbar.getEvent('doUndo').subscribe(@, @undo)
			toolbar.getEvent('doRedo').subscribe(@, @redo)
			toolbar.getEvent('doSettings').subscribe(@, => @getSettingsDialog().open('Settings'))
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
		object = @getCanvas().getSelectedObject()
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
					child = new Bulb.VertexList(id, tabMenu)
					child.getEvent('change').subscribe(canvas, canvas.changeGeometry)
				child.setVertices([object.selectedVector]).setHighlighted().setSelected() if object.selectedVector?
			when 'userData'
				if not child?
					child = new Bulb.UserData(id, tabMenu)
				child.setObject(object)

	getProperties: ->
		properties = @getChildById('properties')
		if not properties
			properties = new CJS.TabMenu('properties', @)
			properties.addTab('mesh', 'Mesh', yes).addTab('geometry', 'Geometry').addTab('vertices', 'Vertices').addTab('userData', 'User Data')
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
		object = @getCanvas().getSelectedObject()
		if object.selectedVector? then vectors = [object.selectedVector] else vectors = []
		properties = @getProperties()
		properties.getChildById(properties.getChildId(properties.getSelectedTab().id)).setVertices(vectors)
		properties.render()

	meshChange: (meshPropertyList) ->
		position = meshPropertyList.getPosition()
		rotation = meshPropertyList.getRotation()
		scale = meshPropertyList.getScale()
		canvas = @getCanvas()
		object = canvas.getSelectedObject()
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


	getSaveDialog: ->
		child = @getChildById('saveDialog')
		if not child?
			child = new Bulb.SaveDialog('saveDialog', @)
			child.addSaveType('Selected object', 'obj')
				.addSaveType('All objects on scene', 'obj')
				.addSaveType('Scene and terrain settings', 'zip')
			child.getEvent('save').subscribe(@, @export)
		child

	getSettingsDialog: ->
		child = @getChildById('settingsDialog')
		if not child?
			child = new Bulb.SettingsDialog('saveDialog', @)
		child

	getExporter: ->
		@exporter = new Bulb.Exporter() if not @exporter?
		@exporter

	export: (saveTypeId, filename)->
		switch saveTypeId
			when 0
				filename += '.obj'
				output = @getExporter().getObjectObj(@getCanvas())
				@download(output, filename)
			when 1
				filename += '.obj'
				output = @getExporter().getSceneObj(@getCanvas())
				@download(output, filename)
			when 2
				@getExporter().getAll(filename, @getCanvas(), @download)

	download: (output, filename) ->
		blob = new Blob( [output], {type: 'text/plain' })
		link = document.createElement('a')
		link.href = URL.createObjectURL(blob)
		link.download = filename
		link.target = '_blank'
		link.click()

	undo: ->
		canvas = @getCanvas()
		canvas.scene = null
		@getObjectList().setItems([]).render()
		canvas.getObjectCollection().clear('objects')
		@getStorage().decrease().get(canvas, canvas.setJSON)
		canvas.restoreView()

	redo: ->
		canvas = @getCanvas()
		canvas.scene = null
		@getObjectList().setItems([]).render()
		canvas.getObjectCollection().clear('objects')
		@getStorage().increase().get(canvas, canvas.setJSON)
		canvas.restoreView()

	load: ->
		el = document.createElement('input')
		el.type = 'file'
		el.accept = '.obj,.zip'
		el.addEventListener 'change', (event) =>
			file = event.target.files[0]
			if file.type is 'application/zip'
				zipper = new Bulb.Zipper()
				zipper.getEvent('read').subscribe(@, @parseFile)
				zipper.getEvent('readEnd').subscribe(@, @finishLoad)
				zipper.readFiles(file)
			else
				reader = new FileReader()
				reader.onload = (frEvent) =>
					data = frEvent.target.result
					@addObjectToCanvas(data)
				reader.readAsText(file)
		el.click()

	parseFile: (text, name, ext) ->
		if ext is 'obj'
			@addObjectToCanvas(text)
		else
			json = localStorage.getItem('scripts')
			if json?
				scripts = JSON.parse(json)
				for script in scripts when script.type is 'import' and script.extension is ext
					@loadCallbackParam = text
					callback = 'this.loadCallback = ' + script.code
					eval(callback)
		@

	finishLoad: ->
		@loadCallback(@loadCallbackParam, @getCanvas())
		@getCanvas().restoreView()

	addObjectToCanvas: (data) ->
		loader = new THREE.OBJLoader()
		@getCanvas().addLoadedObject(loader.parse(data))
		@

	getStorage: ->
		@storage = new Bulb.Storage() if not @storage?
		@storage

	handleAddingObject: (items) -> @getObjectList().restore(items)

	saveStatus: -> @getStorage().set(@getCanvas().getJSON())

	bindEvents: ->
		super()
		canvas = @getCanvas()
		canvas.getEvent('objectAdded').subscribe(@, @handleAddingObject)
		canvas.getEvent('saveStatus').subscribe(@, @saveStatus)
		@getObjectList().getEvent('remove').subscribe(canvas, canvas.remove)
		window.addEventListener 'load', =>
			canvas = @getCanvas()
			@getStorage().get(canvas, canvas.setJSON)
		window.addEventListener 'resize', => @getCanvas().resize()
		window.addEventListener 'keypress', (event) =>
			#console.log event.keyCode
			#console.log event.shiftKey
			if @active
				canvas = @getCanvas()
				if event.keyCode is 127
					canvas.remove(canvas.getSelectedObject().id)
				if event.keyCode is 26
					if event.shiftKey then @redo() else @undo()
				if event.keyCode is 120
					if canvas.getMode() is Bulb.MODE_VERTICES
						canvas.setControlAxis('x')
					else
						event.preventDefault()
						tabMenu = @getProperties()
						tab = tabMenu.getSelectedTab()
						id = tabMenu.getChildId(tab.id)
						child = tabMenu.getChildById(id)
						child.focusElement('x', canvas.getTransformMode())
				if event.keyCode is 121
					if canvas.getMode() is Bulb.MODE_VERTICES
						canvas.setControlAxis('y')
					else
						event.preventDefault()
						tabMenu = @getProperties()
						tab = tabMenu.getSelectedTab()
						id = tabMenu.getChildId(tab.id)
						child = tabMenu.getChildById(id)
						child.focusElement('y', canvas.getTransformMode())
				if event.keyCode is 122
					if canvas.getMode() is Bulb.MODE_VERTICES
						canvas.setControlAxis('z')
					else
						event.preventDefault()
						tabMenu = @getProperties()
						tab = tabMenu.getSelectedTab()
						id = tabMenu.getChildId(tab.id)
						child = tabMenu.getChildById(id)
						child.focusElement('z', canvas.getTransformMode())
				if event.keyCode is 109
					event.preventDefault()
					canvas = @getCanvas()
					mode = canvas.getMode()
					if mode is Bulb.MODE_MESH
						@getProperties().selectTab(2)
						canvas.setMode(Bulb.MODE_VERTICES)
					if mode is Bulb.MODE_VERTICES
						@getProperties().selectTab(0)
						canvas.setMode(Bulb.MODE_MESH)
				if event.keyCode is 116
					@getToolbar().checkTransform('translate')
					canvas.setTransformMode('translate')
				if event.keyCode is 114
					@getToolbar().checkTransform('rotate')
					canvas.setTransformMode('rotate')
				if event.keyCode is 115
					@getToolbar().checkTransform('scale')
					canvas.setTransformMode('scale')
				if event.keyCode is 119
					@getToolbar().checkSpace('world')
					canvas.setTransformSpace('world')
				if event.keyCode is 108
					@getToolbar().checkSpace('local')
					canvas.setTransformSpace('local')
				if event.keyCode is 102
					canvas.setFillSelect()

		window.addEventListener 'keydown', (event) =>
			axis = @getCanvas().getControlAxis()
			if axis?
				step = 0.01
				step = 0.1 if event.shiftKey
				if event.keyCode in [37,40]
					@getCanvas().moveSelected(-step, axis)
				if event.keyCode in [38,39]
					@getCanvas().moveSelected(step, axis)
		window.addEventListener 'keyup', (event) =>

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
