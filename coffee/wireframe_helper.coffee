
class Bulb.WireframeHelper extends THREE.Mesh

	constructor: (@object) ->
		super(@object.geometry.clone(), new THREE.MeshBasicMaterial({color: 0xffffff, wireframe: yes}))
		@update()

	update: ->
		@position.copy(@object.position)
		@scale.copy(@object.scale)
		@rotation.copy(@object.rotation)
		if @object.selecteds?
			@geometry.vertices[index].copy(@object.geometry.vertices[index]) for index in @object.selecteds when index?
			@geometry.dynamic = yes
			@geometry.verticesNeedUpdate = yes
		@
