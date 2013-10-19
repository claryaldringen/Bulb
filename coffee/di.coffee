
class Di

	createCube: (width, height, depth, color)-> new THREE.Mesh new THREE.CubeGeometry(width, height, depth), new THREE.MeshLambertMaterial color: color

	createSphere: (radius, color)-> new THREE.Mesh new THREE.SphereGeometry(radius, 16, 16), new THREE.MeshLambertMaterial color: color
