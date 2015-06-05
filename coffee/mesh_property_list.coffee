
class Bulb.MeshPropertyList extends CJS.Component

	constructor: (id, parent) ->
		super(id, parent)
		@rotation = {x: 0, y: 0, z: 0}
		@data = {}

	getPositionId: (axis) -> @id + '-p-' + axis

	getRotationId: (axis) -> @id + '-r-' + axis

	getScaleId: (axis) -> @id + '-s-' + axis

	setObject: (@object) ->
		@variables = JSON.parse(localStorage.getItem('variables')) if not @variables?
		@data = @object.userData if @object.userData?
		@

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
		if element.hasClass('doSelectChange')
			@data[element.dataset.name] = element.options[element.selectedIndex].value
			@render()
		@data[element.dataset.name] = element.checked if element.hasClass('doCheckBoxChange')
		@data[element.dataset.name] = element.value if element.hasClass('doInputChange')
		@[element.dataset.type][element.dataset.axis] = element.value*1
		@getEvent('change').fire(@)

	focusElement: (axis, type)->
		document.getElementById(@getPositionId(axis)).focus() if type is 'translate'
		document.getElementById(@getRotationId(axis)).focus() if type is 'rotate'
		document.getElementById(@getScaleId(axis)).focus() if type is 'scale'
		@

	checkRules: (rules) ->
		logic = null
		prevOperator = yes
		for rule in rules
			operator = no
			operator = yes if rule.operator is 'is' and @data[rule.name] is rule.value
			operator = yes if rule.operator is 'isnt' and @data[rule.name] isnt rule.value
			if logic is 'and'
				if operator and prevOperator then prevOperator = yes else return no
				logic = rule.next
				break
			if logic is 'or'
				if operator or prevOperator then prevOperator = yes else return no
				logic = rule.next
				break
			prevOperator = operator
			logic = rule.next
		prevOperator

	getHtmlOfEnum: (variable) ->
		html = '<th>' + variable.label + ':</th><td>'
		html += '<select data-name="' + variable.name + '" class="doSelectChange">'
		for option in variable.options
			@data[variable.name] = option.value if not @data[variable.name]?
			html += '<option value="' + option.value + '" ' + (if @data[variable.name] is option.value then 'selected' else '') + '>' + option.label + '</option>'
		html += '</select></td>'

	getHtmlOfBool: (variable) -> '<td colspan="2"><label><input class="doCheckBoxChange" data-name="' + variable.name + '" type="checkbox" ' + (if @data[variable.name] then 'checked' else '') + '>' + variable.label + '</label></td>'

	getHtmlOfString: (variable) -> '<th>' + variable.label + '</th><td><input type="text" class="doInputChange" data-name="' + variable.name + '" value="' + (if @data[variable.name]? then @data[variable.name] else '') + '"></td>'

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
		html += '<table>'
		html += '<br>'
		if @object?
			for variable,index in @variables when @checkRules(variable.rules)
				html += '<tr>'
				html += @getHtmlOfEnum(variable) if variable.type is 'enum'
				html += @getHtmlOfBool(variable) if variable.type is 'bool'
				html += @getHtmlOfString(variable) if variable.type is 'string'
				html += '</tr>'
			html += '</table>'
		html
