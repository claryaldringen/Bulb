
class Bulb.VertexControl extends Bulb.VertexHelper

	constructor: (@camera, @domElement) ->
		@mouse = new THREE.Vector2()
		@take = no
		super(@camera, @domElement)

	init: ->
		@planes = []
		@binded = no
		@createArrows().createPlanes().update() if not @children.length

	createPlanes: ->
		planeGeometry = new THREE.PlaneGeometry( 50, 50, 2, 2 )
		material = new THREE.MeshBasicMaterial( { wireframe: true } )
		for index in [1..3]
			plane = new THREE.Mesh(planeGeometry, material)
			plane.visible = no
			@planes.push(plane)
			@add(plane)
		@planes[1].rotation.set( 0, Math.PI/2, 0 )
		@planes[2].rotation.set( - Math.PI/2, 0, 0 )
		@

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

	move: (point) ->
		sub = point.clone()
		sub.sub(@point)
		if @arrowIndex is 3
			length = sub.length()
			sub = @getNormal().clone()
			length *= -1 if point.length() - @point.length() < 0
			sub.multiplyScalar(length)
		else
			axises = ['x','y','z']
			sub[axis] = 0 for axis,index in axises when index isnt @arrowIndex
		for index in @object.selecteds
			vector = @object.geometry.vertices[index]
			position = vector.clone()
			position = @object.localToWorld(position) if @space is 'world'
			position.add(sub)
			position = @object.worldToLocal(position) if @space is 'world'
			vector.set(position.x, position.y, position.z)
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
					@move(point)
					@dispatchEvent({type: 'change'})
					if @take
						@dispatchEvent({type: 'take'})
						@take = no
			else
				@highlight(raycaster.intersectObjects(@arrows, yes)[0])

	onPointerUp: (event) ->
		@arrowIndex = null
		@point = null
		@dispatchEvent({type: 'let'})
		@dispatchEvent({type: 'change'})

