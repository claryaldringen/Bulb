
class Bulb.ObjectList extends CJS.Component

	setItems: (@items) -> @

	restore: (@items) -> @render()

	getSelectedItemId: -> @selectedItemId

	setSelectedItemId: (@selectedItemId) -> @

	click: (element, event) ->
		if element.className is 'doRemove'
			@selectedItemId = null if element.dataset.id*1 is @selectedItemId
			@getEvent('remove').fire(element.dataset.id)
			@render()
			return
		if element.hasClass('doSelect')
			@selectedItemId = element.dataset.id*1
			@getEvent('select').fire(@selectedItemId)
			elements = document.querySelectorAll('#' + @id + ' .selected')
			for el in elements
				el.classList.remove('selected')
			element.classList.add('selected')
		if element.hasClass('doChange')
			element.parentElement.classList.add('selected')

	change: (element) -> @getEvent('rename').fire({id: element.dataset.id, value: element.value})

	getHtml: ->
		html = '<div class="object_list"><ul>'
		for item in @items
			html += '<li data-id="' + item.id + '" class="' + (if @selectedItemId is item.id then 'doSelect selected' else 'doSelect') + '">'
			html += '<input data-id="' + item.id + '" class="doChange" type="text" value="' + item.name + '">'
			html += '<div class="actions">'
			html += '<img src="images/eye.png" data-id="' + item.id + '" class="doHide" title="Hide">&nbsp;'
			html += '<img src="images/cross.png" data-id="' + item.id + '" class="doRemove" title="Remove (Delete)">'
			html += '</div></li>'
		html += '</ul></div>'