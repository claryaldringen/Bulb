
class @Bulb

	@data = {}

	@MODE_MESH = 1
	@MODE_VERTICES = 2

	@Math =
		constant: -> 1
		linear: (x) -> x
		quadratic: (x) -> x*x
		exponential: (x) -> Math.exp(x)
		logarithm: (x) -> Math.log(x + Math.exp(1))
		hyperbolic: (x) -> 1/x
		sinus: (x) -> Math.sin(x)
		cosinus: (x) -> Math.cos(x)
