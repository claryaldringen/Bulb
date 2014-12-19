
class Bulb.VertexList extends CJS.Component

	setVertices: (@vertices) -> @

	getVertices: -> @vertices

	change: (element) ->
		@vertices[element.dataset.index][element.dataset.axis] = element.value
		@getEvent('change').fire(@)

	getHtml: ->
		html = '<table><tr><th colspan="3">Vertices</th></tr>'
		for vertex,index in @vertices
			html += '<tr>'
			for axis in ['x','y','z']
				html += '<td>' + axis.toUpperCase() + ': <input data-index="' + index + '" data-axis="' + axis + '" type="number" value="' + vertex[axis] + '"></td>'
			html += '</tr>'
		html += '</table>'
