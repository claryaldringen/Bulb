
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

	click: ->

	focusIn: ->

	change: ->

	render: ->
		document.getElementById(@id).innerHTML = @getHtml()
		@renderFinish()
		@restoreView()
		@

	renderFinish: -> child.renderFinish() for childId,child of @children

	restoreView: -> child.restoreView() for childId,child of @children

	getHtml: -> ''

