
class CJS.Event

	constructor: ->
		@listeners = []

	subscribe: (obj, func) ->
		@listeners.push({func: func, obj: obj})
		@

	fire: ->
		for listener in @listeners
			#listener.func.call(listener.obj)
			listener.func.apply(listener.obj, Array.prototype.slice.call(arguments))



