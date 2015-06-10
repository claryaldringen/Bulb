
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
		if element.hasClass('doChangeGeometry')
			@geometry[element.dataset.property] = element.value
			@getEvent('change').fire(@)
		if element.hasClass('doSelectVertex')
			for vertex,i in @vertices
				@vertices[i][element.dataset.axis] = element.value*1
				console.log @vertices
			@getEvent('changeVertices').fire(@)
		if element.hasClass('doSetFunc')
			@func = element.options[element.selectedIndex].value
			@getEvent('changeFunc').fire(@func)


	renderFinish: ->
		top = document.querySelector('#' + @id + ' .selected')?.offsetTop
		element = document.getElementById(@id)
		element.scrollTop = top - element.clientHeight/2 if top?
		@

	getHtml: ->
		html = ''
		if @vertices?
			html += '<table><tr><th>X</th><th>Y</th><th>Z</th></tr>'
			vertex = @vertices[0] if @vertices.length is 1
			html += '<tr>'
			for axis in ['x','y','z']
				val = ''
				val = Math.round(vertex[axis]*100)/100 if vertex
				html += '<td><input class="doSelectVertex" data-axis="' + axis + '" type="number" value="' + val + '" step="0.01"></td>'
			html += '</tr>'
			html += '</table>'
		html += '<br>'
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

