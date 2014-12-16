
class CJS.Document extends CJS.Component

	findId: (target) ->
		if target.id? and target.id isnt ''
			target.id.split('-')[0]
		else
			@findId(target.parentElement)

	bindEvents: ->
		$('body').bind 'focusin', (event) => @getChildById(@findId(event.target)).focusIn(event.target)
		$('body').bind 'click', (event) => @getChildById(@findId(event.target)).click(event.target)
		$('body').bind 'change', (event) => @getChildById(@findId(event.target)).change(event.target)

	render: ->
		super()
		@bindEvents()
		@
