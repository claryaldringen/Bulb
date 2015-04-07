
class CJS.Document extends CJS.Component

	constructor: (id, parent) ->
		super(id, parent)
		@binded = no

	findId: (target) ->
		if target.id? and target.id isnt ''
			target.id.split('-')[0]
		else
			@findId(target.parentElement)

	addMethodHasClass: (element) ->
		if element? and not element.hasClass?
			element.hasClass = (className) ->
				return yes for elClass in element.className.split(' ') when elClass is className
				if element.parentElement? and element.parentElement.hasClass? then element.parentElement.hasClass(className) else no
			@addMethodHasClass(element.parentElement)
		@

	bindEvents: ->
		$('body').bind 'focusin', (event) => @addMethodHasClass(event.target).findChildById(@findId(event.target)).focusIn(event.target)
		$('body').bind 'click', (event) => @addMethodHasClass(event.target).findChildById(@findId(event.target)).click(event.target, event)
		$('body').bind 'mousedown', (event) => @addMethodHasClass(event.target).findChildById(@findId(event.target)).mouseDown(event.target, event)
		$('body').bind 'mouseup', (event) => @addMethodHasClass(event.target).findChildById(@findId(event.target)).mouseUp(event.target, event)
		$('body').bind 'mousewheel', (event) => @addMethodHasClass(event.target).findChildById(@findId(event.target)).mouseWheel(event.target, event)
		$('body').bind 'mouseover', (event) => @addMethodHasClass(event.target).findChildById(@findId(event.target))?.mouseOver(event.target, event)
		$('body').bind 'mousemove', (event) => @addMethodHasClass(event.target).findChildById(@findId(event.target))?.mouseMove(event.target, event)
		$('body').bind 'mouseout', (event) => @addMethodHasClass(event.target).findChildById(@findId(event.target))?.mouseOut(event.target, event)
		$('body').bind 'change', (event) => @addMethodHasClass(event.target).findChildById(@findId(event.target)).change(event.target)

	render: ->
		super()
		if not @binded
			@bindEvents()
			@binded = yes
		@
