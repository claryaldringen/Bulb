
describe 'Di', ->

	object = null

	beforeEach -> object = new Di()

	describe '#createCube', ->

		it 'should return instance of THREE.mesh with THREE.CubeGeometry and THREE.MeshLambertMaterial', ->
			cube = object.createCube 10, 20, 15, 'red'
			expect(cube instanceof THREE.Mesh).toBeTruthy()
			expect(cube.geometry instanceof THREE.CubeGeometry).toBeTruthy()
			expect(cube.geometry.width).toBe 10
			expect(cube.geometry.height).toBe 20
			expect(cube.geometry.depth).toBe 15
			expect(cube.material instanceof THREE.MeshLambertMaterial).toBeTruthy()
			expect(cube.material.color).toEqual new THREE.Color 'red'

	describe '#createSphere', ->

		it 'should return instance of THREE.mesh with THREE.SphereGeometry and THREE.MeshLambertMaterial', ->
			cube = object.createSphere 10, 0xff55ff
			expect(cube instanceof THREE.Mesh).toBeTruthy()
			expect(cube.geometry instanceof THREE.SphereGeometry).toBeTruthy()
			expect(cube.geometry.radius).toBe 10
			expect(cube.geometry.widthSegments).toBe 16
			expect(cube.geometry.heightSegments).toBe 16
			expect(cube.material instanceof THREE.MeshLambertMaterial).toBeTruthy()
			expect(cube.material.color).toEqual new THREE.Color 0xff55ff
