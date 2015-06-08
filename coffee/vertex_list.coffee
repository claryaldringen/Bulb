
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
		if element.hasClass('doSetFunc')
			@func = element.options[element.selectedIndex].value
			@getEvent('changeFunc').fire(@func)
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
			html = 'Please select some face.<br>'
		if @geometry?
			html += '<table>'
			for property,value of @geometry
				html += '<tr><th>' + @format(property) + ':</th><td><input class="doChangeGeometry" data-property="' + property + '" type="number" value="' + value + '"></label></td></tr>'
			html += '</table>'
		else
			html += '<label>Move Function: <select class="doSetFunc">'
			html += '<option value="constant" ' + (if @func is 'constant' then 'selected' else '') + '>Constant</option>'
			html += '<option value="linear" ' + (if @func is 'linear' then 'selected' else '') + '>Linear</option>'
			html += '<option value="quadratic" ' + (if @func is 'quadratic' then 'selected' else '') + '>Quadratic</option>'
			html += '<option value="exponential" ' + (if @func is 'exponential' then 'selected' else '') + '>Exponential</option>'
			html += '<option value="logarithm" ' + (if @func is 'logarithm' then 'selected' else '') + '>Logarithm</option>'
			html += '<option value="hyperbolic" ' + (if @func is 'hyperbolic' then 'selected' else '') + '>Hyperbolic</option>'
			html += '<option value="sinus" ' + (if @func is 'sinus' then 'selected' else '') + '>Sinus</option>'
			html += '<option value="cosinus" ' + (if @func is 'cosinus' then 'selected' else '') + '>Cosinus</option>'
			html += '</select></label>'
		html

