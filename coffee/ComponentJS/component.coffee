
class CJS.Component

	constructor: (@id, @parent) ->
		@parent.setChild(@) if @parent?
		@children = {}
		@baseUrl = ''
		@events = {}

	getId: -> @id

	setParent: (@parent) ->
		@parent.setChild(@)
		@

	setChild: (child) ->
		@children[child.id] = child

	getChildById: (id) -> @children[id]

	findChildById: (id) ->
		ids = id.split('_')
		child = @
		for id in ids
			id = lastId + '_' + id if lastId?
			child = child.getChildById(id)
			lastId = id
		child

	setBaseUrl: (@baseUrl) -> @

	getEvent: (event) ->
		if not @events[event]
			@events[event] = new CJS.Event()
		@events[event]

	sendRequest: (action, params, callback) ->
		$.post(@baseUrl + action, {data: JSON.stringify(params)}, (data) =>
			callback.call(@, data)
		)
		@

	open: (@windowTitle = '', x = window.innerWidth/2, y = window.innerHeight/3) ->
		el = document.createElement('div')
		el.id = @id
		el.classList.add('window')
		document.body.appendChild(el)
		@render()
		el.style.top = (y/3) + 'px'
		el.style.left = (x - el.clientWidth/2) + 'px'
		@

	close: ->
		if @windowTitle?
			@windowTitle = null
			document.body.removeChild(document.getElementById(@id))
		@

	click: (element, event) ->

	focusIn: ->

	change: ->

	mouseDown: ->

	mouseUp: ->

	mouseWheel: ->

	mouseOver: ->

	mouseOut: ->

	mouseMove: ->

	render: ->
		html = ''
		html += '<div class="title">' + @windowTitle + '</div>' if @windowTitle
		html += @getHtml()
		document.getElementById(@id).innerHTML = html
		@renderFinish()
		@restoreView()
		@

	renderFinish: -> child.renderFinish() for childId,child of @children

	restoreView: -> child.restoreView() for childId,child of @children

	getHtml: -> ''

