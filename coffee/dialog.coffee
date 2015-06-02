
class Bulb.Dialog extends CJS.Component

	open: (windowTitle = '', x = window.innerWidth/2, y = window.innerHeight/3) ->
		super(windowTitle, x, y)
		@parent.setActive(no)

	close: ->
		super()
		@parent.setActive(yes)
