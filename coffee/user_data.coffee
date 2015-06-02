
class Bulb.UserData extends CJS.Component

	constructor: (id, parent) ->
		super(id, parent)
		@data = {}

	setObject: (@object) ->
		@variables = JSON.parse(localStorage.getItem('variables')) if not @variables?
		@data = @object.userData
		@

	change: (element) ->
		if element.hasClass('doSelectChange')
			@data[element.dataset.name] = element.options[element.selectedIndex].value
			@render()
		@data[element.dataset.name] = element.checked if element.hasClass('doCheckBoxChange')
		@data[element.dataset.name] = element.value if element.hasClass('doInputChange')

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
		html = '<table>'
		for variable,index in @variables when @checkRules(variable.rules)
			html += '<tr>'
			html += @getHtmlOfEnum(variable) if variable.type is 'enum'
			html += @getHtmlOfBool(variable) if variable.type is 'bool'
			html += @getHtmlOfString(variable) if variable.type is 'string'
			html += '</tr>'
		html += '</table>'
