
class Bulb.VertexControl extends Bulb.VertexHelper

	constructor: (@camera, @domElement) ->
		@mouse = new THREE.Vector2()
		@take = no
		super(@camera, @domElement)
		@moved = no
		@normalArrow = null
		@mathFunction = -> 1

	init: ->
		@planes = []
		@binded = no
		@createArrows().createPlanes().update() if not @children.length

	createPlanes: ->
		planeGeometry = new THREE.PlaneGeometry( 50, 50, 2, 2 )
		material = new THREE.MeshBasicMaterial( { wireframe: true } )
		for index in [0..3]
			plane = new THREE.Object3D()
			if not @axis? or ['x','y','z'][index] is @axis
				plane = new THREE.Mesh(planeGeometry, material)
				plane.visible = no
				@add(plane)
			@planes.push(plane)
		@planes[1].rotation.set( 0, Math.PI/2, 0 )
		@planes[2].rotation.set( - Math.PI/2, 0, 0 )
		@

	createArrows: ->
		super()
		@addNormalArrow()

	addNormalArrow: ->
		length = 0.8
		color = 0x800080
		@remove(@normalArrow) if @normalArrow?
		if @axis is 'n'
			@normalArrow = new THREE.ArrowHelper(@getNormal(),new THREE.Vector3(0,0,0), length, color, length/4, length/10)
			@add(@normalArrow)
		@

	getNormal: ->
		faces = @object.geometry.faces
		selecteds = @object.selecteds
		foo = []
		for selected,i in selecteds
			foo[i] = []
			for face in faces
				for key,j of {a: 0, b: 1, c: 2} when face[key] is selected
					foo[i].push(face.vertexNormals[j])
					break

		total = new THREE.Vector3()
		for normals in foo
			vertexNormal = new THREE.Vector3()
			for normal in normals
				vertexNormal.add(normal)
			vertexNormal.divideScalar(normals.length)
			total.add(vertexNormal)
		total.divideScalar(foo.length)
		total

	getMoved: -> @moved

	setMoved: (@moved) -> @

	setAxis: (@axis) ->
		for index in [0,1,2]
			@remove(@planes[index]) if @planes[index]?
			@remove(@arrows[index]) if @arrows[index]?
		@arrows = []
		@planes = []
		@createArrows().createPlanes().update()

	getAxis: -> @axis

	getRaycaster: ->
		@raycaster = new THREE.Raycaster() if not @raycaster?
		@raycaster

	getMatrix: ->
		if not @matrix
			@object.updateMatrixWorld()
			@matrix = new THREE.Matrix4().getInverse(@object.matrixWorld)
		@matrix

	getArrows: -> @arrows

	setMathFunction: (@mathFunction) -> @

	getMathFunction: -> @mathFunction

	highlight: (intersect) ->
		colors = [0xff0000, 0x00ff00, 0x0000ff, 0x800080]
		for arrow,index in @arrows
			if intersect? and arrow is intersect.object.parent
				if not arrow.highlighted
					arrow.setColor(0xffff00)
					arrow.highlighted = yes
					@dispatchEvent({type: 'change'})
			else
				if arrow.highlighted
					arrow.setColor(colors[index])
					arrow.highlighted = no
					@dispatchEvent({type: 'change'})
		@

	attach: (vertex, face, object) ->
		if not @binded
			@domElement.addEventListener "mousedown", (event) => @onPointerDown(event)
			@domElement.addEventListener "mousemove", (event) => @onPointerMove(event)
			@domElement.addEventListener "mouseup", (event) => @onPointerUp(event)
			@binded = yes
		@addNormalArrow()
		super(vertex, face, object)

	detach: ->
		if @binded
			@domElement.removeEventListener "mousedown", (event) => @onPointerDown(event)
			@domElement.removeEventListener "mousemove", (event) => @onPointerMove(event)
			@domElement.removeEventListener "mouseup", (event) => @onPointerUp(event)
			@binded = no
		@vertex = null
		@object = null
		@

	update: ->
		if @object? and @vertex?
			position = @vertex.clone()
			@object.updateMatrixWorld()
			position.applyMatrix4(@object.matrixWorld)
			@camera.updateMatrixWorld()
			@worldPosition.setFromMatrixPosition(@object.matrixWorld)
			@camPosition.setFromMatrixPosition(@camera.matrixWorld )
			scale = @worldPosition.distanceTo(@camPosition) / 6 * 0.8
			@position.set(position.x, position.y, position.z)
			@scale.set(scale, scale, scale)
			if @space is 'local' then @rotation.copy(@object.rotation) else @rotation.set(0,0,0)
		@

	moveToPoint: (point) ->
		sub = point.clone()
		sub.sub(@point)
		axises = ['x','y','z']
		for axis,index in axises when index is @arrowIndex
			@move(sub[axis], axis)
		@point = point.clone()

	computeMove: (vector, axis, step) ->
		distance = vector.distanceTo(@vertex)
		func = @getMathFunction()
		if @axis isnt 'n'
			sub = new THREE.Vector3(0,0,0)
			for ax in ['x','y','z'] when ax is axis
				sub[ax] = func(distance) * step
				break
		else
			normal = @getNormal().clone()
			normal.normalize()
			normal.x *= func(distance) * step
			normal.y *= func(distance) * step
			normal.z *= func(distance) * step
			sub = normal
		sub


	move: (step, axis) ->
		if @object.selecteds.length
			for index in @object.selecteds
				vector = @object.geometry.vertices[index]
				position = vector.clone()
				position = @object.localToWorld(position) if @space is 'world'
				position.add(@computeMove(vector, axis, step))
				position = @object.worldToLocal(position) if @space is 'world'
				vector.set(position.x, position.y, position.z)
			position = @vertex.clone()
			position = @object.localToWorld(position) if @space is 'world'
			position.add( @computeMove(@vertex, axis, step))
			position = @object.worldToLocal(position) if @space is 'world'
			@vertex.set(position.x, position.y, position.z)
			@update()
			@dispatchEvent({type: 'change'})
			@moved = yes
		@

	onPointerDown: (event) ->
		event.preventDefault()
		event.stopPropagation()
		@mouse.set(( event.clientX / window.innerWidth ) * 2 - 1, - ( event.clientY / window.innerHeight ) * 2 + 1)
		raycaster = new THREE.Raycaster()
		raycaster.setFromCamera(@mouse, @camera)
		intersects = raycaster.intersectObjects(@getArrows(), yes)
		if intersects[0]?
			@point = intersects[0].point.clone()
			for arrow,index in @arrows when arrow is intersects[0].object.parent
				@arrowIndex = index
				@take = yes
				break
			if @arrowIndex is 3
				intersects = raycaster.intersectObjects(@planes, yes)
				@point = intersects[0].point.clone()
				@plane = intersects[0].object

	onPointerMove: (event) ->
		if @object? and @vertex?
			raycaster = @getRaycaster()
			@mouse.set(( event.clientX / window.innerWidth ) * 2 - 1, - ( event.clientY / window.innerHeight ) * 2 + 1)
			raycaster.setFromCamera(@mouse, @camera)
			if @arrowIndex?
				event.preventDefault()
				event.stopPropagation()
				if @arrowIndex < 3 then objects = [@planes[@arrowIndex]] else objects = [@plane]
				point = raycaster.intersectObjects(objects, yes)[0]?.point
				if point?
					@moveToPoint(point)
					if @take
						@dispatchEvent({type: 'take'})
						@take = no
			else
				@highlight(raycaster.intersectObjects(@arrows, yes)[0])

	onPointerUp: (event) ->
		@arrowIndex = null
		@point = null
		if @object? and @object.geometry.parameters?
			delete(@object.geometry.parameters)
			@object.geometry.type = 'Geometry'
		@dispatchEvent({type: 'let'})
		@dispatchEvent({type: 'change'})
		@moved = no

