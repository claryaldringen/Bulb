
class Bulb.VertexHelper extends THREE.Object3D

	constructor: (@camera, @domElement) ->
		super()
		@arrows = []
		@worldPosition = new THREE.Vector3()
		@camPosition =  new THREE.Vector3()
		@space = 'world'
		@init()

	init: ->
		@createArrows().update() if not @children.length
		@

	setSpace: (@space) ->
		@dispatchEvent({type: 'change'})
		@update()

	createArrows: ->
		length = 0.8
		i = 0
		start = {'#FF0000': new THREE.Vector3(-length/3,0,0), '#00FF00': new THREE.Vector3(0,-length/3,0), '#0000FF': new THREE.Vector3(0,0,-length/3)}
		vectors = {'#FF0000': new THREE.Vector3(1,0,0), '#00FF00': new THREE.Vector3(0,1,0), '#0000FF': new THREE.Vector3(0,0,1)}
		for color,vector of vectors
			arrow = new THREE.Object3D()
			if not @axis? or ['x','y','z'][i] is @axis
				arrow = new THREE.ArrowHelper(vector, start[color], length, color, length/4, length/10)
				arrow.highlighted = no
				@add(arrow)
			@arrows.push(arrow)
			i++
		@

	getMatrix: ->
		if not @matrix
			@object.updateMatrixWorld()
			@matrix = new THREE.Matrix4().getInverse(@object.matrixWorld)
		@matrix

	attach: (@vertex, @object) ->
		@update()

	detach: ->
		@vertex = null
		@object = null
		@

	update: ->
		if @object? and @vertex?
			position = @vertex.clone()
			position.applyMatrix4(@object.matrixWorld)
			@worldPosition.setFromMatrixPosition(@object.matrixWorld)
			@camPosition.setFromMatrixPosition(@camera.matrixWorld )
			scale = @worldPosition.distanceTo(@camPosition) / 6 * 0.8
			@position.set(position.x, position.y, position.z)
			@scale.set(scale, scale, scale)
			if @space is 'local' then @rotation.copy(@object.rotation) else @rotation.set(0,0,0)
		@
