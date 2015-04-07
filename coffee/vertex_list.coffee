
class Bulb.VertexList extends CJS.Component

	setVertices: (@vertices) -> @

	getVertices: -> @vertices

	setHighlighted: (@highlightedIndex) ->
		@highlightedIndex = highlightedIndex*1 if highlightedIndex?
		@

	setSelected: (selectedIndex) ->
		@selectedIndex = selectedIndex*1
		@

	focusIn: (element) ->
		@setSelected(element.dataset.index)
		document.querySelector('#' + @id + ' .selected')?.classList.remove('selected')
		element.parentElement.parentElement.classList.add('selected')
		@getEvent('select').fire(@vertices[element.dataset.index])

	change: (element) ->
		@vertices[element.dataset.index][element.dataset.axis] = element.value
		@getEvent('change').fire(@)

	mouseOver: (element) ->
		if element.hasClass('doSelectVertex')
			@getEvent('highlight').fire(@vertices[element.dataset.index])

	mouseOut: (element) ->
		if element.hasClass('doSelectVertex')
			@getEvent('dishighlight').fire()

	renderFinish: ->
		top = document.querySelector('#' + @id + ' .selected')?.offsetTop
		element = document.getElementById(@id)
		element.scrollTop = top - element.clientHeight/2 if top?
		@

	getHtml: ->
		html = '<table><tr><th>X</th><th>Y</th><th>Z</th></tr>'
		for vertex,index in @vertices
			cssClass = ''
			if @highlightedIndex is index then cssClass = 'highlighted'
			if @selectedIndex is index then cssClass = 'selected'
			html += '<tr class="' + cssClass + '">'
			for axis in ['x','y','z']
				html += '<td><input class="doSelectVertex" data-index="' + index + '" data-axis="' + axis + '" type="number" value="' + Math.round(vertex[axis]*100)/100 + '" step="0.01"></td>'
			html += '</tr>'
		html += '</table>'
