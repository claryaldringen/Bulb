
class Bulb.ObjectList extends CJS.Component

	setItems: (@items) -> @

	restore: (canvas) -> @setItems(canvas.getScene().children).render()

	getSelectedItemId: -> @selectedItemId

	setSelectedItemId: (@selectedItemId) -> @

	click: (element) ->
		if element.className is 'doRemove'
			if element.dataset.id*1 is @selectedItemId
				@selectedItemId = null
				@getEvent('select').fire(@)
			@getEvent('remove').fire(element.dataset.id)
		if element.className is 'doSelect'
			@selectedItemId = element.dataset.id*1
			@getEvent('select').fire(@)

	getHtml: ->
		html = '<div><ul>'
		for item in @items
			html += '<li><span data-id="' + item.id + '" class="doSelect">' + item.name + '</span><span data-id="' + item.id + '" class="doRemove">X</span></li>'
		html += '</ul></div>'