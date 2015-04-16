
class Bulb.SelectControl

	constructor: (@camera, @scene, @domElement) ->
		@active = yes
		@events = []
		domElement.addEventListener 'mousemove', (event) => @onPointerMove(event)
		domElement.addEventListener 'click', (event) => @onPointerClick(event)

	getWidth: -> window.innerWidth

	getHeight: -> window.innerHeight - 3

	getEvent: (event) ->
		@events[event] = new CJS.Event() if not @events[event]?
		@events[event]

	setSelectedObject: (@selectedObject) -> @

	deactivate: ->
		@scene.remove(@vertexControl) if @vertexControl?
		@scene.remove(@vertexHelper) if @vertexHelper?
		@selectedObject = null
		@unhighlightVector()
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
				@unhighlightVector()
				@active = no
			vertexControl.addEventListener 'let', =>  setTimeout(( => @active = yes), 100)
			@vertexControl = vertexControl
		@vertexControl

	getIntersect: (event, objects)->
		mouse = new THREE.Vector2()
		mouse.set(( event.clientX / @getWidth() ) * 2 - 1, - ( event.clientY / @getHeight() ) * 2 + 1)
		raycaster = new THREE.Raycaster()
		raycaster.setFromCamera(mouse, @camera)
		intersects = raycaster.intersectObjects(objects, yes)
		if intersects[0]? then intersects[0] else null

	highlightVector: (vector, face) ->
		if vector? and vector isnt @actualVector
			@scene.add(@getVertexHelper().attach(vector, face, @selectedObject))
			@actualVector = vector
			@getEvent('change').fire()
		@

	unhighlightVector: ->
		if @actualVector?
			@scene.remove(@getVertexHelper().detach())
			@actualVector = null
			@getEvent('change').fire()
		@

	selectVector: (face) ->
		@scene.add(@getVertexControl().attach(@actualVector, @intersect.face, @selectedObject))
		@selectedObject.selectedVector = @actualVector
		@getEvent('selectVector').fire()

	unselectVector: ->
		@scene.remove(@getVertexControl().detach())
		@selectedObject.selectedVector = null
		@getEvent('selectVector').fire()
		@getEvent('change').fire()

	selectFace: ->
		@selectedObject.selectedFace.color.setHex(0xffffff) if @selectedObject.selectedFace?
		if @selectedObject.selectedFace isnt @actualFace then @selectedObject.selectedFace = @actualFace else @selectedObject.selectedFace = null
		@selectedObject.geometry.colorsNeedUpdate = yes
		@getEvent('change').fire()

	isNear: (mouse, face, vectorIndex) ->
		mouse = mouse.clone()
		vertices = @selectedObject.geometry.vertices
		near = vertices[vectorIndex].distanceTo(vertices[face.a].clone().add(vertices[face.b]).add(vertices[face.c]).divideScalar(3))/2
		@selectedObject.worldToLocal(mouse)
		vertices[vectorIndex].distanceTo(mouse) < near

	showVector: (intersect) ->
		mouse = intersect.point
		face = intersect.face
		vertices = @selectedObject.geometry.vertices
		highlighted = no
		for letter in ['a','b', 'c']
			index = face[letter]
			if @isNear(mouse, face, index)
				@highlightVector(vertices[index], face) if @selectedObject.selectedVector isnt vertices[index]
				highlighted = yes
				break
		@unhighlightVector() if not highlighted
		@

	showFace: (intersect) ->
		if @actualFace isnt intersect.face and not @actualVector
			@actualFace.color.setHex(0xffffff) if @actualFace? and @actualFace isnt @selectedObject.selectedFace
			@actualFace = intersect.face
			@actualFace.color.setHex(0xffff00)
			@selectedObject.geometry.colorsNeedUpdate = yes
			@getEvent('change').fire()
		@

	mouseOverFace: (event) ->
		if @selectedObject?
			@intersect = @getIntersect(event, [@selectedObject])
			if @intersect?
				@showVector(@intersect).showFace(@intersect)
			else
				@unhighlightVector()

		if (not @intersect? or @actualVector) and @actualFace?
			@actualFace.color.setHex(0xffffff) if @actualFace? and @actualFace isnt @selectedObject.selectedFace
			@selectedObject.geometry.colorsNeedUpdate = yes
			@actualFace = null
			@getEvent('change').fire()

	select: ->
		if @selectedObject?
			handlers = [@selectVector, @selectFace]
			@unselectVector()
			for entity, index in [@actualVector, @actualFace] when entity?
				handlers[index].call(@)
				break
		@

	onPointerClick: (event) ->
		@select() if @active

	onPointerMove: (event) ->
		@mouseOverFace(event) if @active