
class Bulb.ObjectList extends CJS.Component

	setItems: (@items) -> @

	restore: (@items) -> @render()

	getSelectedItemId: -> @selectedItemId

	setSelectedItemId: (@selectedItemId) -> @

	click: (element) ->
		if element.className is 'doRemove'
			if element.dataset.id*1 is @selectedItemId
				@selectedItemId = null
				@getEvent('select').fire(@selectedItemId)
			@getEvent('remove').fire(element.dataset.id)
		if element.hasClass('doSelect')
			@selectedItemId = element.dataset.id*1
			@getEvent('select').fire(@selectedItemId)
		@render()

	getHtml: ->
		html = '<div><ul>'
		for item in @items
			html += '<li data-id="' + item.id + '" class="' + (if @selectedItemId is item.id then 'doSelect selected' else 'doSelect') + '">' + item.name + '<img src="images/cross.png" data-id="' + item.id + '" class="doRemove" title="Remove"></li>'
		html += '</ul></div>'