
class Bulb.VertexControl extends THREE.Object3D

	constructor: (@camera, domElement) ->
		super()
		@arrows = []
		@planes = []
		@arrowIndex = null
		@worldPosition = new THREE.Vector3()
		@space = 'world'
		domElement.addEventListener "mousedown", (event) => @onPointerDown(event)
		domElement.addEventListener "mousemove", (event) => @onPointerMove(event)
		domElement.addEventListener "mouseup", (event) => @onPointerUp(event)
		@init()

	setSpace: (@space) ->
		@dispatchEvent({type: 'change'})
		@update()

	init: ->
		if not @children.length
			length = 0.8
			start = {'#FF0000': new THREE.Vector3(-length/3,0,0), '#00FF00': new THREE.Vector3(0,-length/3,0), '#0000FF': new THREE.Vector3(0,0,-length/3)}
			for color,vector of {'#FF0000': new THREE.Vector3(1,0,0), '#00FF00': new THREE.Vector3(0,1,0), '#0000FF': new THREE.Vector3(0,0,1)}
				arrow = new THREE.ArrowHelper(vector, start[color], length, color, length/3, length/8)
				arrow.highlighted = no
				@add(arrow)
				@arrows.push(arrow)
			planeGeometry = new THREE.PlaneGeometry( 50, 50, 2, 2 )
			material = new THREE.MeshBasicMaterial( { wireframe: true } )
			for index in [1..3]
				plane = new THREE.Mesh(planeGeometry, material)
				plane.visible = no
				@planes.push(plane)
				@add(plane)
			@planes[1].rotation.set( 0, Math.PI/2, 0 )
			@planes[2].rotation.set( - Math.PI/2, 0, 0 )
		@update()

	getRaycaster: ->
		@raycaster = new THREE.Raycaster() if not @raycaster?
		@raycaster

	getMatrix: ->
		if not @matrix
			@object.updateMatrixWorld()
			@matrix = new THREE.Matrix4().getInverse(@object.matrixWorld)
		@matrix

	getArrows: -> @arrows

	highlight: (intersect) ->
		colors = [0xff0000, 0x00ff00, 0x0000ff]
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

	attach: (@vertex, @object) -> @update()

	detach: ->
		@vertex = null
		@object = null
		@

	update: ->
		if @object? and @vertex?
			position = @vertex.clone()
			position.applyMatrix4(@object.matrixWorld)
			@worldPosition.setFromMatrixPosition(@object.matrixWorld)
			scale = @worldPosition.distanceTo(@camera.position) / 6 * 0.5
			@position.set(position.x, position.y, position.z)
			@scale.set(scale, scale, scale)
			if @space is 'local' then @rotation.copy(@object.rotation) else @rotation.set(0,0,0)
		@

	move: (point) ->
		axises = ['x','y','z']
		sub = point.clone()
		sub.sub(@point)
		sub[axis] = 0 for axis,index in axises when index isnt @arrowIndex
		position = @vertex.clone()
		position = @object.localToWorld(position) if @space is 'world'
		position.add(sub)
		position = @object.worldToLocal(position) if @space is 'world'
		@vertex.set(position.x, position.y, position.z)
		@point = point.clone()
		@update()

	onPointerDown: (event) ->
		event.preventDefault()
		event.stopPropagation()
		mouse = new THREE.Vector2()
		mouse.set(( event.clientX / window.innerWidth ) * 2 - 1, - ( event.clientY / window.innerHeight ) * 2 + 1)
		raycaster = new THREE.Raycaster()
		raycaster.setFromCamera(mouse, @camera)
		intersects = raycaster.intersectObjects(@getArrows(), yes)
		if intersects[0]?
			@point = intersects[0].point.clone()
			for arrow,index in @arrows when arrow is intersects[0].object.parent
				@arrowIndex = index
				break

	onPointerMove: (event) ->
		if @object? and @vertex?
			raycaster = @getRaycaster()
			mouse = new THREE.Vector2()
			mouse.set(( event.clientX / window.innerWidth ) * 2 - 1, - ( event.clientY / window.innerHeight ) * 2 + 1)
			raycaster.setFromCamera(mouse, @camera)
			if @arrowIndex?
				event.preventDefault()
				event.stopPropagation()
				point = raycaster.intersectObjects([@planes[@arrowIndex]], yes)[0]?.point
				if point?
					@move(point)
					@dispatchEvent({type: 'change'})
			else
				@highlight(raycaster.intersectObjects(@arrows, yes)[0])

	onPointerUp: (event) ->
		@arrowIndex = null
		@point = null

