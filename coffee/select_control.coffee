
class Bulb.SelectControl

	constructor: (@camera, @scene, @domElement) ->
		@active = yes
		@down = no
		@events = []
		@floodFill = no
		@gizmoShowed = no
		@domElement.addEventListener 'mousemove', (event) => @onPointerMove(event)
		@domElement.addEventListener 'mousedown', (event) => @onPointerDown(event)
		@domElement.addEventListener 'click', (event) => @onPointerClick(event)

	setFillSelect: ->
		@floodFill = yes
		@

	getWidth: -> window.innerWidth

	getHeight: -> window.innerHeight - 3

	getEvent: (event) ->
		@events[event] = new CJS.Event() if not @events[event]?
		@events[event]

	setSelectedObject: (@selectedObject) ->
		@selectedObject.selecteds = []
		@neighbours = null
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
				@getEvent('saveStatus').fire() if vertexControl.getMoved()
			@vertexControl = vertexControl
			console.log 'done'
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
			@actualVector = vector
		@

	unhighlightVector: (resetActual = yes)->
		if @actualVector?
			@actualVector = null if resetActual
		@

	toggleSelectMode: ->
		if @gizmoShowed
			@scene.remove(@getVertexControl())
			@gizmoShowed = no
		else
			@scene.add(@getVertexControl().attach(@getGizmoPosition(), @intersect.face, @selectedObject)) if @selectedObject.selecteds.length
			@gizmoShowed = yes
		@

	selectVector: (add) ->
		if @active
			actualVectorIndex = @getVertexIndex(@actualVector)
			if actualVectorIndex?
				switch add
					when 0
						if @selectedObject.selecteds[0] is actualVectorIndex then @selectedObject.selecteds = [] else @selectedObject.selecteds = [actualVectorIndex]
						@neighbours = null
					when 1
						if @isSelected(actualVectorIndex) then @selectedObject.selecteds.splice(@selectedObject.selecteds.indexOf(actualVectorIndex),1) else @selectedObject.selecteds.push(actualVectorIndex)
					when 2
						@selectShortestPath(@selectedObject.selecteds[@selectedObject.selecteds.length-1], actualVectorIndex)
					when 4
						@floodFillSelect(actualVectorIndex)
						@floodFill = no

				@getEvent('selectVector').fire()
				@getEvent('change').fire()
			@

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
		@selectedObject.selecteds = @selectedObject.selecteds.filter((value, index, self) -> self.indexOf(value) is index)
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
		if not @neighbours?
			vertices = []
			vertices[index] = [] for vertex, index in @selectedObject.geometry.vertices
			for face in @selectedObject.geometry.faces
				vertices[face['a']].push(face['b']) if face['b'] not in vertices[face['a']]
				vertices[face['a']].push(face['c']) if face['c'] not in vertices[face['a']]
				vertices[face['b']].push(face['a']) if face['a'] not in vertices[face['b']]
				vertices[face['b']].push(face['c']) if face['c'] not in vertices[face['b']]
				vertices[face['c']].push(face['a']) if face['a'] not in vertices[face['c']]
				vertices[face['c']].push(face['b']) if face['b'] not in vertices[face['c']]
			@neighbours = vertices
		@neighbours

	floodFillSelect: (vertex) ->
		@selectedObject.selecteds.push(vertex)
		neighbours = @getNeighbors()
		if neighbours[vertex]?
			for neighbor in @neighbours[vertex] when neighbor not in @selectedObject.selecteds
				@floodFillSelect(neighbor)
			@neighbours[vertex] = null
		@

	getGizmoPosition: ->
		center = new THREE.Vector3()
		center.add(@selectedObject.geometry.vertices[index]) for index in @selectedObject.selecteds
		center.divideScalar(@selectedObject.selecteds.length)
		center

	getVertexIndex: (vector) ->
		if @selectedObject.geometry?
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

	setMoved: (moved) ->
		@getVertexControl().setMoved(moved)
		@

	getMoved: -> @getVertexControl().getMoved()

	moveSelected: (step, axis) ->
		@getVertexControl().move(step, axis)
		@

	setMathFunction: (type) ->
		@getVertexControl().setMathFunction(Bulb.Math[type])
		@

	showVector: (intersect) ->
		mouse = intersect.point
		face = intersect.face
		if @selectedObject.geometry?
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
		if not @gizmoShowed
			event.preventDefault()
			add = 0
			add = 1 if event.ctrlKey
			add = 2 if event.shiftKey and @selectedObject.selecteds.length
			add = 4 if @floodFill
			@selectVector(add) if @selectedObject?
			@active = yes
			@down = no

	onPointerMove: (event) ->
		@active = no if @down
		@mouseOverFace(event) if @active

	onPointerDown: ->
		@down = yes
