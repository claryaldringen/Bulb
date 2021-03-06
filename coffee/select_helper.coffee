
class Bulb.SelectHelper extends THREE.Object3D

	constructor: (@camera) ->
		super()
		@worldPosition = new THREE.Vector3()
		@camPosition = new THREE.Vector3()

	attach: (@object) ->
		@remove(@children[i]) for i in [@children.length - 1..0] by -1
		@groups = @getGroups()
		for face in @groups.faces
			geometry = new THREE.Geometry()
			geometry.vertices.push(@object.geometry.vertices[face[0]], @object.geometry.vertices[face[1]], @object.geometry.vertices[face[2]], @object.geometry.vertices[face[0]])
			line = new THREE.Line(geometry, new THREE.LineBasicMaterial({color: 0xff8f00}))
			@add(line)
		for edge in @groups.edges
			geometry = new THREE.Geometry()
			geometry.vertices.push(@object.geometry.vertices[edge[0]], @object.geometry.vertices[edge[1]])
			line = new THREE.Line(geometry, new THREE.LineBasicMaterial({color: 0xff8f00}))
			@add(line)
		@showSinglePoint(@object.geometry.vertices[point]) for point in @groups.points
		@

	update: ->
		@camera.updateMatrixWorld()
		worldPosition = new THREE.Vector3()
		camPosition = new THREE.Vector3()
		worldPosition.setFromMatrixPosition(@object.matrixWorld)
		camPosition.setFromMatrixPosition(@camera.matrixWorld )
		scale = worldPosition.distanceTo(camPosition)/6

		@position.copy(@object.position)
		@scale.copy(@object.scale)
		@rotation.copy(@object.rotation)
		if @object.selecteds?
			for selectedIndex in @object.selecteds
				@updateGeometry(selectedIndex, @groups.faces, 0).updateGeometry(selectedIndex, @groups.edges, @groups.faces.length)
		@updatePoint(scale)

	updateGeometry: (selectedIndex, groups, coefficient) ->
		for group, childIndex in groups
			for index,i in group when index is selectedIndex
				vector = @object.geometry.vertices[index]
				geometry = @children[childIndex+coefficient].geometry
				geometry.vertices[i].copy(vector)
				geometry.dynamic = yes
				geometry.verticesNeedUpdate = yes
				break
		@

	updatePoint: (scale) ->
		if @groups? and @groups.faces? and @groups.edges?
			start = @groups.faces.length + @groups.edges.length
			for index,childIndex in @groups.points
				vector = @object.geometry.vertices[index]
				@children[childIndex+start].position.copy(vector)
				@children[childIndex+start].scale.set(scale,scale,scale)
		@

	getGroups: ->
		selecteds = @object.selecteds.slice()
		faces = @object.geometry.faces.slice()
		edges1 = []
		edges2 = []
		edges3 = []
		for face,i in faces
			edge = []
			edge.push(face[key]) for key in ['a','b','c'] when face[key] in selecteds
			edges3.push edge.sort() if edge.length is 3
			edges2.push edge.sort() if edge.length is 2
			edges1.push edge[0] if edge.length is 1
		i = edges1.length
		while i--
			for edge2 in edges2
				if edges1[i] is edge2[0] or edges1[i] is edge2[1]
					edges1.splice(i, 1)
					break
		edges1 = edges1.filter (value, index, self) -> self.indexOf(value) is index
		i = edges2.length
		while i--
			for edge3 in edges3
				if edges2[i][0] in edge3 and edges2[i][1] in edge3
					edges2.splice(i, 1)
					break
		{faces: edges3, edges: edges2, points: edges1}

	showSinglePoint: (vector) ->
		cross = @getCross()
		cross.position.copy(vector)
		@add(cross)

	getCross: ->
		cross = new THREE.Object3D()
		for axis in ['x','y','z']
			start = new THREE.Vector3()
			start[axis] = -0.1
			end = new THREE.Vector3()
			end[axis] = 0.1
			geometry = new THREE.Geometry()
			geometry.vertices.push(start, end)
			line = new THREE.Line(geometry, new THREE.LineBasicMaterial({color: 0xff8f00}))
			cross.add(line)
		cross