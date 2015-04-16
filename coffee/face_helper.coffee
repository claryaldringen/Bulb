
class Bulb.FaceHelper extends THREE.Object3D

	constructor: (@camera, domElement) ->
		super()
		@worldPosition = new THREE.Vector3()
		#domElement.addEventListener('mousemove',((event)=> @onPointerHover(event)), no)
		#domElement.addEventListener('click',((event)=> @onPointerClick(event)), no)

	attach: (object, face) ->
		@position = object.position
		@rotation = object.rotation
		@scale = object.scale

		geometry = new THREE.Geometry()
		geometry.vertices.push(object.geometry.vertices[face.a].clone(), object.geometry.vertices[face.b].clone(), object.geometry.vertices[face.c].clone())
		geometry.faces.push( new THREE.Face3( 0, 1, 2 ) )
		geometry.computeBoundingSphere()

		mesh = new THREE.Mesh(geometry, new THREE.MeshBasicMaterial({color: 0xFFFF00, wireframe: yes}))
		@add(mesh)
		@

