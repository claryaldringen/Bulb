
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
			@render()
		if element.hasClass('doSelect')
			@selectedItemId = element.dataset.id*1
			@getEvent('select').fire(@selectedItemId)
			document.querySelector('#' + @id + ' .selected')?.classList.remove('selected')
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
			html += '<img src="images/cross.png" data-id="' + item.id + '" class="doRemove" title="Remove">'
			html += '</div></li>'
		html += '</ul></div>'