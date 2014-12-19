
class Bulb.GeometryPropertyList extends CJS.Component

	setGeometry: (@geometry) -> @

	getGeometry: -> @geometry

	change: (element) ->
		@geometry[element.dataset.property] = element.value
		@getEvent('change').fire(@)

	format: (string) ->
		string = string.replace(/([a-z](?=[A-Z]))/g, '$1 ')
		string.charAt(0).toUpperCase() + string.slice(1)

	getHtml: ->
		html = '<table><tr><th colspan="2">Geometry</th></tr>'
		for property,value of @geometry
			html += '<tr><td>' + @format(property) + ':</td><td><input data-property="' + property + '" type="number" value="' + value + '"></label></td></tr>'
		html += '</table>'

