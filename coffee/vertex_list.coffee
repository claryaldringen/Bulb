
class Bulb.VertexList extends CJS.Component

	setVertices: (@vertices) -> @

	getVertices: -> @vertices

	setGeometry: (@geometry) -> @

	getGeometry: -> @geometry

	setHighlighted: (@highlightedIndex) ->
		@highlightedIndex = highlightedIndex*1 if highlightedIndex?
		@

	setSelected: (selectedIndex) ->
		@selectedIndex = selectedIndex*1
		@

	format: (string) ->
		string = string.replace(/([a-z](?=[A-Z]))/g, '$1 ')
		(string.charAt(0).toUpperCase() + string.slice(1)).replace(' ', '&nbsp;')

	change: (element) ->
		@geometry[element.dataset.property] = element.value if element.hasClass('doChangeGeometry')
		@vertices[element.dataset.index][element.dataset.axis] = element.value if element.hasClass('doSelectVertex')
		@getEvent('change').fire(@)

	renderFinish: ->
		top = document.querySelector('#' + @id + ' .selected')?.offsetTop
		element = document.getElementById(@id)
		element.scrollTop = top - element.clientHeight/2 if top?
		@

	getHtml: ->
		if @vertices?
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
		else
			html = 'Please select some face.'
		if @geometry?
			html += '<table>'
			for property,value of @geometry
				html += '<tr><th>' + @format(property) + ':</th><td><input class="doChangeGeometry" data-property="' + property + '" type="number" value="' + value + '"></label></td></tr>'
			html += '</table>'
		html
