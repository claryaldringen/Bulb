
class Bulb.SelectControl

	constructor: (@camera, @scene, @domElement) ->
		@active = yes
		@down = no
		@events = []
		domElement.addEventListener 'mousemove', (event) => @onPointerMove(event)
		domElement.addEventListener 'mousedown', (event) => @onPointerDown(event)
		domElement.addEventListener 'click', (event) => @onPointerClick(event)

	getWidth: -> window.innerWidth

	getHeight: -> window.innerHeight - 3

	getEvent: (event) ->
		@events[event] = new CJS.Event() if not @events[event]?
		@events[event]

	setSelectedObject: (@selectedObject) ->
		@selectedObject.selecteds = []
		@active = yes
		@

	getSelectedObject: -> @selectedObject

	deactivate: ->
		@scene.remove(@vertexControl) if @vertexControl?
		@scene.remove(@vertexHelper) if @vertexHelper?
		@vertexControl = null
		@vertexHelper = null
		@selectedObject = null
		@active = yes
		@unhighlightVector()
		@actualVector = null
		@selectedObject = null
		@

	setSpace: (space) ->
		@getVertexControl().setSpace(space)
		@getVertexHelper().setSpace(space)
		@

	getVertexHelper: ->
		if not @vertexHelper?
			vertexHelper = new Bulb.VertexHelper(@camera, @domElement)
			@vertexHelper = vertexHelper
		@vertexHelper

	getVertexControl: ->
		if not @vertexControl?
			vertexControl = new Bulb.VertexControl(@camera, @domElement)
			vertexControl.addEventListener 'change', => @getEvent('changeGeometry').fire()
			vertexControl.addEventListener 'take', =>
				@unhighlightVector(no)
				@active = no
			@vertexControl = vertexControl
		@vertexControl

	getRaycaster: ->
		@raycaster = new THREE.Raycaster() if not @raycaster?
		@raycaster

	getIntersect: (event, objects)->
		mouse = new THREE.Vector2()
		mouse.set(( event.clientX / @getWidth() ) * 2 - 1, - ( event.clientY / @getHeight() ) * 2 + 1)
		raycaster = @getRaycaster()
		raycaster.setFromCamera(mouse, @camera)
		intersects = raycaster.intersectObjects(objects, yes)
		if intersects[0]? then intersects[0] else null

	highlightVector: (vector, face) ->
		if vector? and vector isnt @actualVector
			#@scene.add(@getVertexHelper().attach(vector, face, @selectedObject)) if not @isSelected(@getVertexIndex(vector))
			@actualVector = vector
			#@getEvent('change').fire()
		@

	unhighlightVector: (resetActual = yes)->
		if @actualVector?
			@scene.remove(@getVertexHelper().detach())
			@actualVector = null if resetActual
			@getEvent('change').fire()
		@

	selectVector: (add) ->
		if @active
			actualVectorIndex = @getVertexIndex(@actualVector)
			@scene.remove(@getVertexControl())
			if not @isSelected(actualVectorIndex) or not add
				if add then @selectedObject.selecteds.push(actualVectorIndex) else @selectedObject.selecteds = [actualVectorIndex]
			else
				index = @selectedObject.selecteds.indexOf(actualVectorIndex)
				@selectedObject.selecteds.splice(index,1)
			@scene.add(@getVertexControl().attach(@getGizmoPosition(), @intersect.face, @selectedObject)) if @selectedObject.selecteds.length
			@getEvent('selectVector').fire()
			@getEvent('change').fire()

	getGizmoPosition: ->
		center = new THREE.Vector3()
		center.add(@selectedObject.geometry.vertices[index]) for index in @selectedObject.selecteds
		center.divideScalar(@selectedObject.selecteds.length)
		center

	getVertexIndex: (vector) ->
		return index for vertex,index in @selectedObject.geometry.vertices when vertex is vector
		null

	isNear: (mouse, face, vectorIndex) ->
		mouse = mouse.clone()
		vertices = @selectedObject.geometry.vertices
		near = vertices[vectorIndex].distanceTo(vertices[face.a].clone().add(vertices[face.b]).add(vertices[face.c]).divideScalar(3))
		@selectedObject.worldToLocal(mouse)
		vertices[vectorIndex].distanceTo(mouse) < near


	isSelected: (index) ->
		return yes for id in @selectedObject.selecteds when id is index
		no

	showVector: (intersect) ->
		mouse = intersect.point
		face = intersect.face
		vertices = @selectedObject.geometry.vertices
		highlighted = no
		for letter in ['a','b', 'c']
			index = face[letter]
			if @isNear(mouse, face, index)
				@highlightVector(vertices[index], face)
				highlighted = yes
				break
		@unhighlightVector() if not highlighted
		@

	update: ->
		if @vertexControl?
			@vertexControl.vertex.copy(@getGizmoPosition())
			@vertexControl.update()

	mouseOverFace: (event) ->
		if @selectedObject?
			@intersect = @getIntersect(event, [@selectedObject])
			if @intersect?
				@showVector(@intersect)
			else
				@unhighlightVector()

	onPointerClick: (event) ->
		@selectVector(event.ctrlKey) if @selectedObject?
		@active = yes
		@down = no

	onPointerMove: (event) ->
		@active = no if @down
		@mouseOverFace(event) if @active

	onPointerDown: ->
		@down = yes
