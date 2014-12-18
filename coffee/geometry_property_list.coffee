
class Bulb.GeometryPropertyList extends CJS.Component

	setGeometry: (@geometry) -> @

	getGeometry: -> @geometry

	change: (element) ->
		@geometry[element.dataset.property] = element.value
		@getEvent('change').fire(@)

	getHtml: ->
		html = '</table><tr><th>Geometry</th></tr>'
		for property,value of @geometry
			html += '<tr><td><label>' + property + ': <input data-property="' + property + '" type="number" value="' + value + '"></label></td></tr>'
		html += '</table>'

