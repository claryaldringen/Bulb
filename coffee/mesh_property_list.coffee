
class Bulb.MeshPropertyList extends CJS.Component

	constructor: (id, parent) ->
		super(id, parent)
		@rotation = {x: 0, y: 0, z: 0}

	getPositionId: (axis) -> @id + '-p-' + axis

	getRotationId: (axis) -> @id + '-r-' + axis

	getScaleId: (axis) -> @id + '-s-' + axis

	setPosition: (@position) ->
		if position?
			for axis in ['x','y','z']
				value = position[axis]*1
				document.getElementById(@getPositionId(axis))?.value = Math.round(value*100)/100 if value?
		@

	getPosition: -> @position

	setRotation: (rotation) ->
		for axis,value of rotation
			@rotation[axis] = Math.round((180/Math.PI)*value*100)/100
			document.getElementById(@getRotationId(axis))?.value = @rotation[axis]
		@

	getRotation: -> {x: @rotation.x/(180/Math.PI), y: @rotation.y/(180/Math.PI), z: @rotation.z/(180/Math.PI)}

	setScale: (@scale) ->
		document.getElementById(@getScaleId(axis))?.value = Math.round(value*100)/100 for axis,value of @scale
		@

	getScale: -> @scale

	change: (element) ->
		@[element.dataset.type][element.dataset.axis] = element.value*1
		@getEvent('change').fire(@)

	focusElement: (axis, type)->
		document.getElementById(@getPositionId(axis)).focus() if type is 'translate'
		document.getElementById(@getRotationId(axis)).focus() if type is 'rotate'
		document.getElementById(@getScaleId(axis)).focus() if type is 'scale'
		@

	getHtml: ->
		html = ''
		if @position? and @rotation?
			html += '<table><tr><th>&nbsp;</th><th>Position</th><th>Rotation</th><th>Scale</th></tr>'
			for label, axis of {X: 'x',Y: 'y', Z: 'z'}
				html += '<tr><th>' + label + '</th>'
				html += '<td><input id="' + @getPositionId(axis) + '" data-type="position" data-axis="' + axis + '" type="number" step="0.01" value="' + @position[axis] + '"></td>'
				html += '<td><input id="' + @getRotationId(axis) + '" data-type="rotation" data-axis="' + axis + '" type="number" step="0.1" value="' + @rotation[axis] + '"></td>'
				html += '<td><input id="' + @getScaleId(axis) + '" data-type="scale" data-axis="' + axis + '" type="number" step="0.01" value="' + @scale[axis] + '"></td>'
				html += '</tr>'
			html += '</table>'
		html
