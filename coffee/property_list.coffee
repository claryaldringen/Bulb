
class Bulb.PropertyList extends CJS.Component

	setPosition: (@position) -> @

	getPosition: -> @position

	setRotation: (@rotation) -> @

	getRotation: -> @rotation

	setScale: (@scale) -> @

	getScale: -> @scale

	setGeometry: (@geometry) -> @

	getGeometry: -> @geometry

	change: (element) ->
		@[element.dataset.type][element.dataset.axis] = element.value
		if element.dataset.type is 'geometry' then @getEvent('changeGeometry').fire(@) else @getEvent('change').fire(@)

	getRotationSectionHtml: ->
		html = '<tr><th>Rotation</th></tr>'
		html += '<tr><td><label>X: <input data-type="rotation" data-axis="x" type="number" value="' + @rotation.x + '"></label></td></tr>'
		html += '<tr><td><label>Y: <input data-type="rotation" data-axis="y" type="number" value="' + @rotation.y + '"></label></td></tr>'
		html += '<tr><td><label>Z: <input data-type="rotation" data-axis="z" type="number" value="' + @rotation.z + '"></label></td></tr>'

	getPositionSectionHtml: ->
		html = '<tr><th>Position</th></tr>'
		html += '<tr><td><label>X: <input data-type="position" data-axis="x" type="number" value="' + @position.x + '"></label></td></tr>'
		html += '<tr><td><label>Y: <input data-type="position" data-axis="y" type="number" value="' + @position.y + '"></label></td></tr>'
		html += '<tr><td><label>Z: <input data-type="position" data-axis="z" type="number" value="' + @position.z + '"></label></td></tr>'

	getScaleSectionHtml: ->
		html = '<tr><th>Scale</th></tr>'
		html += '<tr><td><label>X: <input data-type="scale" data-axis="x" type="number" value="' + @scale.x + '"></label></td></tr>'
		html += '<tr><td><label>Y: <input data-type="scale" data-axis="y" type="number" value="' + @scale.y + '"></label></td></tr>'
		html += '<tr><td><label>Z: <input data-type="scale" data-axis="z" type="number" value="' + @scale.z + '"></label></td></tr>'

	getHtml: ->
		html = ''
		if @position? and @rotation?
			html += '<table>'
			html += @getPositionSectionHtml()
			html += @getRotationSectionHtml()
			html += @getScaleSectionHtml()
			html += @getGeometrySectionHtml()
			html += '</table>'
		html