
class Bulb.VertexList extends CJS.Component

	setVertices: (@vertices) -> @

	getVertices: -> @vertices

	change: (element) ->
		@vertices[element.dataset.index][element.dataset.axis] = element.value
		@getEvent('change').fire(@)

	getHtml: ->
		html = '<table><tr><th>Vertices</th></tr>'
		for vertex,index in @vertices
			html += '<tr><td>'
			for axis in ['x','y','z']
				html += '<input data-index="' + index + '" data-axis="' + axis + '" type="number" value="' + vertex[axis] + '">'
			html += '</td></tr>'
		html += '</table>'
