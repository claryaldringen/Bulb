
class @Bulb

	@data = {}

	@MODE_MESH = 1
	@MODE_VERTICES = 2

	@Math =
		constant: -> 1
		linear: (x, max) -> max-x
		quadratic: (x, max) -> (max-x)*(max-x)
		exponential: (x, max) -> Math.exp(max-x)
		logarithm: (x, max) -> Math.log((max-x) + Math.exp(1))
		hyperbolic: (x, max) -> max/x
		sinus: (x, max) -> Math.sin((2*Math.PI/max)*x)
		cosinus: (x, max) -> Math.cos((2*Math.PI/max)*x)
