
class Bulb.VertexHelper extends THREE.Object3D

	constructor: (@camera, domElement) ->
		super()
		@visibleHelper = no
		@worldPosition = new THREE.Vector3()
		domElement.addEventListener('mousemove',((event)=> @onPointerHover(event)), no)
		domElement.addEventListener('click',((event)=> @onPointerClick(event)), no)

	getRaycaster: ->
		@raycaster = new THREE.Raycaster() if not @raycaster?
		@raycaster

	attach: (object) ->
		if object isnt @object
			@children = []
			for vertex, index in object.geometry.vertices
				helper = new THREE.Mesh(new THREE.SphereGeometry(0.05,1,1,1), new THREE.MeshBasicMaterial({color: 0xFFFF00, wireframe: yes}))
				helper.position.set(vertex.x, vertex.y, vertex.z)
				helper.visible = no
				@add(helper)
			@object = object
			@update()
		@

	detach: ->
		@object = null

	getVertexByHelperObject: (object) ->
		for helper,index in @children when object is helper
			return @object.geometry.vertices[index]
		null

	update: ->
		if @object?
			@position.set(@object.position.x, @object.position.y, @object.position.z)
			@scale.set(@object.scale.x, @object.scale.y, @object.scale.z)
			@rotation.set(@object.rotation.x, @object.rotation.y, @object.rotation.z)
			@worldPosition.setFromMatrixPosition(@object.matrixWorld)
			scale = @worldPosition.distanceTo(@camera.position) / 6 * 0.5
			for vertex, index in @object.geometry.vertices
				@children[index].position.set(vertex.x, vertex.y, vertex.z)
				@children[index].scale.set(scale, scale, scale)
		@

	onPointerHover: (event) ->
		if @object?
			mouse = new THREE.Vector2()
			mouse.set(( event.clientX / window.innerWidth ) * 2 - 1, - ( event.clientY / window.innerHeight ) * 2 + 1)
			raycaster = @getRaycaster()
			raycaster.setFromCamera(mouse, @camera)
			intersects = raycaster.intersectObjects(@children)
			if intersects[0]?
				if not @visibleHelper
					intersects[0].object.visible = yes
					@dispatchEvent({type: 'change'})
					@update()
					@visibleHelper = yes
			else
				if @visibleHelper
					@hide()
					@dispatchEvent({type: 'change'})


	onPointerClick: (event) ->
		if @visibleHelper
			event.preventDefault()
			event.stopPropagation()
			@dispatchEvent({type: 'select'})

	getSelectedVector: ->
		return vector for vector,index in @object.geometry.vertices when @children[index].visible
		null

	getSelectedVectorIndex: ->
		return index for vector,index in @object.geometry.vertices when @children[index].visible
		null

	show: (vertex) ->
		for vector,index in @object.geometry.vertices when vertex is vector
			@children[index].visible = yes
			@visibleHelper = yes
			break
		@

	hide: ->
		if @visibleHelper
			helper.visible = no for helper in @children
			@visibleHelper = no
		@


