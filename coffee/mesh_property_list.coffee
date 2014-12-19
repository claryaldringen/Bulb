
class Bulb.MeshPropertyList extends CJS.Component

	setPosition: (@position) -> @

	getPosition: -> @position

	setRotation: (@rotation) -> @

	getRotation: -> @rotation

	setScale: (@scale) -> @

	getScale: -> @scale

	change: (element) ->
		@[element.dataset.type][element.dataset.axis] = element.value
		@getEvent('change').fire(@)

	getHtml: ->
		html = ''
		if @position? and @rotation?
			html += '<table>'
			html += '<tr><th>Position</th><th>Scale</th></tr>'
			for label, axis of {X: 'x',Y: 'y', Z: 'z'}
				html += '<tr><td><label>' + label + ': <input data-type="position" data-axis="' + axis + '" type="number" value="' + @position[axis] + '"></label></td>'
				html += '<td><label>' + label + ': <input data-type="scale" data-axis="' + axis + '" type="number" value="' + @scale[axis] + '"></label></td></tr>'
			html += '<tr><th colspan="2">Rotation</th></tr>'
			for label, axis of {X: 'x',Y: 'y', Z: 'z'}
				html += '<tr><td colspan="2"><label>' + label + ': <input data-type="rotation" data-axis="' + axis + '" type="number" value="' + @rotation[axis] + '"></label></td></tr>'
			html += '</table>'
		html