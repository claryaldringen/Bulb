
class Bulb.WireframeHelper extends THREE.Line

	constructor: (color) ->
		super(new THREE.BufferGeometry(), new THREE.LineBasicMaterial(color: color), THREE.LinePieces)

	attach: (@object) ->
		@update()

	update: ->
		object = @object
		edge = [ 0, 0 ]
		hash = {}
		sortFunction = (a, b) -> a - b

		keys = [ "a", "b", "c" ]
		if object.geometry instanceof THREE.Geometry
			vertices = object.geometry.vertices
			faces = object.geometry.faces
			numEdges = 0

			# allocate maximal size
			edges = new Uint32Array(6 * faces.length)
			i = 0
			l = faces.length

			while i < l
				face = faces[i]
				j = 0

				while j < 3
					edge[0] = face[keys[j]]
					edge[1] = face[keys[(j + 1) % 3]]
					edge.sort sortFunction
					key = edge.toString()
					if hash[key] is `undefined`
						edges[2 * numEdges] = edge[0]
						edges[2 * numEdges + 1] = edge[1]
						hash[key] = true
						numEdges++
					j++
				i++
			coords = new Float32Array(numEdges * 2 * 3)
			i = 0
			l = numEdges

			while i < l
				j = 0

				while j < 2
					vertex = vertices[edges[2 * i + j]]
					index = 6 * i + 3 * j
					coords[index + 0] = vertex.x
					coords[index + 1] = vertex.y
					coords[index + 2] = vertex.z
					j++
				i++
			@geometry.addAttribute "position", new THREE.BufferAttribute(coords, 3)
		@matrix = object.matrixWorld
		@matrixAutoUpdate = false