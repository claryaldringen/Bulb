
class Bulb.SelectControl

	constructor: (@camera, @scene, @domElement) ->
		@active = yes
		@down = no
		@events = []
		@domElement.addEventListener 'mousemove', (event) => @onPointerMove(event)
		@domElement.addEventListener 'mousedown', (event) => @onPointerDown(event)
		@domElement.addEventListener 'click', (event) => @onPointerClick(event)

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

	setAxis: (axis) ->
		@getVertexControl().setAxis(axis)
		@

	getAxis: -> @getVertexControl().getAxis()

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
			vertexControl.addEventListener 'let', =>
				@getEvent('saveStatus').fire()
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
			if not @isSelected(actualVectorIndex) or add is 0
				if add is 1
					@selectedObject.selecteds.push(actualVectorIndex)
				else if add is 2 and @selectedObject.selecteds.length
					@selectShortestPath(@selectedObject.selecteds[@selectedObject.selecteds.length-1], actualVectorIndex)
				else
					@selectedObject.selecteds = [actualVectorIndex]
			else
				index = @selectedObject.selecteds.indexOf(actualVectorIndex)
				@selectedObject.selecteds.splice(index,1)
			@scene.add(@getVertexControl().attach(@getGizmoPosition(), @intersect.face, @selectedObject)) if @selectedObject.selecteds.length
			@getEvent('selectVector').fire()
			@getEvent('change').fire()

	selectShortestPath: (start, end)->
		vertexNeighboursList = @getNeighbors()
		lengths = []
		path = []
		nonVisited = [0...@selectedObject.geometry.vertices.length]
		for i in nonVisited
			if i is start then lengths[i] = 0 else lengths[i] = Infinity
			path[i] = undefined

		while nonVisited.length
			vertex = @getMin(lengths, nonVisited)
			break if vertex is end
			nonVisited.splice(nonVisited.indexOf(vertex),1)
			for neighbor in vertexNeighboursList[vertex]
				alt = lengths[vertex]+1;
				if alt < lengths[neighbor]
					lengths[neighbor] = alt
					path[neighbor] = vertex
		shortestWay = []
		vertex = end
		while path[vertex]?
			shortestWay.unshift(vertex)
			vertex = path[vertex]
		@selectedObject.selecteds.push(vertexIndex) for vertexIndex in shortestWay
		@

	getMin: (lengths, nonVisited) ->
		min = Infinity
		for vertexIndex in nonVisited when lengths[vertexIndex]?
			len = lengths[vertexIndex]
			if len < min
				min = len
				vertex = vertexIndex
		vertex

	getNeighbors: ->
		vertices = []
		vertices[index] = [] for vertex, index in @selectedObject.geometry.vertices
		for face in @selectedObject.geometry.faces
			vertices[face['a']].push(face['b']) if face['b'] not in vertices[face['a']]
			vertices[face['a']].push(face['c']) if face['c'] not in vertices[face['a']]
			vertices[face['b']].push(face['a']) if face['a'] not in vertices[face['b']]
			vertices[face['b']].push(face['c']) if face['c'] not in vertices[face['b']]
			vertices[face['c']].push(face['a']) if face['a'] not in vertices[face['c']]
			vertices[face['c']].push(face['b']) if face['b'] not in vertices[face['c']]
		vertices

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

	moveSelected: (step, axis) ->
		sub = new THREE.Vector3(0,0,0)
		sub[ax] = step for ax in ['x','y','z'] when ax is axis
		@getVertexControl().move(sub)
		@

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
		if @vertexControl? and @vertexControl.vertex?
			@vertexControl.vertex.copy(@getGizmoPosition())
			@vertexControl.update()

	mouseOverFace: (event) ->
		if @selectedObject?
			@intersect = @getIntersect(event, [@selectedObject])
			if @intersect?
				@showVector(@intersect)
				@getEvent('mouseEnter').fire()
			else
				@unhighlightVector()
				@getEvent('mouseLeave').fire()

	onPointerClick: (event) ->
		event.preventDefault()
		add = 0
		add = 1 if event.ctrlKey
		add = 2 if event.shiftKey
		@selectVector(add) if @selectedObject?
		@active = yes
		@down = no

	onPointerMove: (event) ->
		@active = no if @down
		@mouseOverFace(event) if @active

	onPointerDown: ->
		@down = yes
