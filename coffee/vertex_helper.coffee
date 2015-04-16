
class Bulb.VertexHelper extends THREE.Object3D

	constructor: (@camera, @domElement) ->
		super()
		@arrows = []
		@worldPosition = new THREE.Vector3()
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
		start = {'#FF0000': new THREE.Vector3(-length/3,0,0), '#00FF00': new THREE.Vector3(0,-length/3,0), '#0000FF': new THREE.Vector3(0,0,-length/3)}
		for color,vector of {'#FF0000': new THREE.Vector3(1,0,0), '#00FF00': new THREE.Vector3(0,1,0), '#0000FF': new THREE.Vector3(0,0,1)}
			arrow = new THREE.ArrowHelper(vector, start[color], length, color, length/3, length/8)
			arrow.highlighted = no
			@add(arrow)
			@arrows.push(arrow)
		@

	getNormal: ->
		vertices = @object.geometry.vertices
		for key, index in ['a', 'b', 'c'] when vertices[@face[key]] is @vertex
			normal = @face.vertexNormals[index]
			break
		normal

	addNormalArrow: ->
		length = 1
		@remove(@arrows[3]) if @arrows[3]?
		origin = new THREE.Vector3(0,0,0)
		normal = @getNormal()
		@arrows[3] = new THREE.ArrowHelper(normal, origin, length, 0x800080, length/3, length/10)
		@arrows[3].highlighted = no
		@add(@arrows[3])
		@

	getMatrix: ->
		if not @matrix
			@object.updateMatrixWorld()
			@matrix = new THREE.Matrix4().getInverse(@object.matrixWorld)
		@matrix

	attach: (@vertex, @face, @object) ->
		@addNormalArrow()
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
			scale = @worldPosition.distanceTo(@camera.position) / 6 * 0.5
			@position.set(position.x, position.y, position.z)
			@scale.set(scale, scale, scale)
			if @space is 'local' then @rotation.copy(@object.rotation) else @rotation.set(0,0,0)
		@
