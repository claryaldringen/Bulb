
class Bulb.Document extends CJS.Document

	constructor: (id, parent) ->
		super(id, parent)

	getCanvas: ->
		canvas = @getChildById('canvas')
		canvas = new Bulb.Canvas('canvas', @) if not canvas?
		canvas

	getToolbar: ->
		toolbar = @getChildById('toolbar')
		toolbar = new Bulb.Toolbar('toolbar', @) if not toolbar?
		toolbar

	getObjectList: ->
		objectList = @getChildById('object_list');
		if not objectList?
			objectList = new Bulb.ObjectList('object_list', @)
			objectList.setItems(@getCanvas().getScene().children)
		objectList

	getPropertyList: (geometry) ->
		@propertyList = new Bulb.PropertyListCube('properties') if not @propertyList
		@propertyList.getEvent('changeGeometry').subscribe(@, @geometryChange)
		@propertyList.getEvent('change').subscribe(@, @propertyChange)
		@propertyList.setParent(@).setGeometry(geometry?.parameters)

	selectObject: (objectList) ->
		object = @getCanvas().getScene().getObjectById(objectList.getSelectedItemId())
		object = {position: null, rotation: null} if not object?
		@getPropertyList(object.geometry).setPosition(object.position).setRotation(object.rotation).setScale(object.scale).render()

	geometryChange: (propertyList) ->
		objectList = @getObjectList()
		params = propertyList.getGeometry()
		object = @getCanvas().replaceObject(objectList.getSelectedItemId(), params)
		objectList.setSelectedItemId(object.id).render()
		@propertyChange(propertyList)

	propertyChange: (propertyList) ->
		position = propertyList.getPosition()
		rotation = propertyList.getRotation()
		scale = propertyList.getScale()
		canvas = @getCanvas()
		object = canvas.getScene().getObjectById(@getObjectList().getSelectedItemId())
		object.position.set(position.x, position.y, position.z)
		object.rotation.set(rotation.x, rotation.y, rotation.z)
		object.scale.set(scale.x, scale.y, scale.z)
		object.lookAt(new THREE.Vector3(0, 0, 0)) if object instanceof THREE.Camera
		canvas.restoreView()

	bindEvents: ->
		super()
		canvas = @getCanvas()
		objectList = @getObjectList()
		@getToolbar().getEvent('addCube').subscribe(canvas, canvas.addCube)
		@getToolbar().getEvent('addSphere').subscribe(canvas, canvas.addSphere)
		@getToolbar().getEvent('addLight').subscribe(canvas, canvas.addLight)
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

		object = canvas.getScene().getObjectById(objectList.getSelectedItemId())
		propertyList = @getPropertyList(object?.geometry)
		html += '<div id="properties">' + propertyList.getHtml() + '</div>'