
class Bulb.TypedefControl extends CJS.Component

	constructor: (id, parent) ->
		super(id, parent)
		@variables = [{name: '', label: '', type: 'string', rules: []}]

	load: ->
		json = localStorage.getItem('variables')
		@variables = JSON.parse(json) if json?
		@

	save: ->
		localStorage.setItem('variables', JSON.stringify(@variables))
		@

	change: (element) ->
		@variables[element.dataset.index].name = element.value if element.hasClass('doNameChange')
		@variables[element.dataset.index].label = element.value if element.hasClass('doLabelChange')
		if element.hasClass('doTypeChange')
			@variables[element.dataset.index].type = ['string','bool','enum'][element.selectedIndex]
			@variables[element.dataset.index].options = [{value: '', label: ''}]
			@render()
		@variables[element.dataset.index].options[element.dataset.oi].value = element.value if element.hasClass('doOptionValueChange')
		@variables[element.dataset.index].options[element.dataset.oi].label = element.value if element.hasClass('doOptionLabelChange')
		@variables[element.dataset.index].rules[element.dataset.ri].name = element.options[element.selectedIndex].value if element.hasClass('doRuleNameChange')
		@variables[element.dataset.index].rules[element.dataset.ri].operator = element.options[element.selectedIndex].value if element.hasClass('doRuleOperatorChange')
		@variables[element.dataset.index].rules[element.dataset.ri].value = element.options[element.selectedIndex].value if element.hasClass('doRuleValueChange')
		@variables[element.dataset.index].rules[element.dataset.ri].next = element.options[element.selectedIndex].value if element.hasClass('doRuleNextChange')

	click: (element) ->
		if element.hasClass('doOptionAdd')
			@variables[element.dataset.index].options.push({value: '', label: ''})
			@render()
		if element.hasClass('doOptionDelete')
			@variables[element.dataset.index].options.splice(element.dataset.oi, 1)
			@render()
		if element.hasClass('doDelete')
			@variables.splice(element.dataset.index, 1)
			@render()
		if element.hasClass('doAddVariable')
			@variables.push({name: '', label: '', type: 'string', rules: []})
			@render()
		if element.hasClass('doAddRule')
			@variables[element.dataset.index].rules.push({name: '', operator: 'is', value: '', next: 'and'})
			@render()
		if element.hasClass('doRemoveRule')
			@variables[element.dataset.index].rules.splice(@variables[element.dataset.index].rules.length-1, 1)
			@render()
		if element.hasClass('doMoveDown')
			index = element.dataset.index*1
			variable = @variables[index]
			@variables[index] = @variables[index+1]
			@variables[index+1] = variable
			@render()
		if element.hasClass('doMoveUp')
			index = element.dataset.index*1
			variable = @variables[index]
			@variables[index] = @variables[index-1]
			@variables[index-1] = variable
			@render()
		if element.hasClass('doRestore') and confirm('Really restore defaults?')
			localStorage.removeItem('variables')
			localStorage.setItem('variables', JSON.stringify(Bulb.data.variables))
			@load().render()

	getHtml: ->
		html = ''
		for variable,i in @variables
			html += '<table>'
			html += '<tr><th>Name</th><th>Label</th><th>Type</th><th>Actions</th></tr>'
			html += '<tr>'
			html += '<td><input type="text" data-index="' + i + '" class="doNameChange" value="' + variable.name + '"></td>'
			html += '<td><input type="text" data-index="' + i + '" class="doLabelChange" value="' + variable.label + '"></td>'
			html += '<td><select data-index="' + i + '" class="doTypeChange">'
			html += '<option value="string" ' + (if variable.type is 'string' then 'selected' else '') + '>String</option>'
			html += '<option value="bool" ' + (if variable.type is 'bool' then 'selected' else '') + '>Boolean</option>'
			html += '<option value="enum" ' + (if variable.type is 'enum' then 'selected' else '') + '>Enumerable</option>'
			html += '</select></td>'
			html += '<td>'
			html += '<img src="./images/cross.png" title="Delete" data-index="' + i + '" class="doDelete">&nbsp;'
			html += '<img src="./images/add.png" title="Add Option" data-index="' + i + '" class="doOptionAdd">&nbsp;' if variable.type is 'enum'
			html += '<img src="./images/page_add.png" title="Add Rule" data-index="' + i + '" class="doAddRule">'
			html += '<img src="./images/page_delete.png" title="Remove Rule" data-index="' + i + '" class="doRemoveRule">'
			html += '<img src="./images/arrow_down.png" title="Move down" data-index="' + i + '" class="doMoveDown">' if i < @variables.length-1
			html += '<img src="./images/arrow_up.png" title="Move up" data-index="' + i + '" class="doMoveUp">' if i > 0
			html += '</td>'
			if variable.type is 'enum'
				html += '</tr><tr><td colspan="4">'
				html += '<table class="options"><tr>'
				html += '<th>Name:<br>Label:</th>'
				for option,oi in variable.options
					html += '<td>'
					html += '<input type="text" value="' + option.value + '" data-index="' + i + '" data-oi="' + oi + '" class="doOptionValueChange"><br>'
					html += '<img src="./images/cross.png" title="Delete" data-index="' + i + '" data-oi="' + oi + '" class="doOptionDelete">'
					html += '<input class="option_label" type="text" value="' + option.label + '" data-index="' + i + '" data-oi="' + oi + '" class="doOptionLabelChange"></td>'
				html += '</tr></table>'
				html += '</td>'
			html += '</tr>'
			html += '<tr><td colspan="4">'
			html += 'Visible if ' if variable.rules.length
			for rule,ri in variable.rules
				options = []
				html += '<select data-index="' + i + '" data-ri="' + ri + '" class="doRuleNameChange">'
				for othervar,otherIndex in @variables when othervar.type is 'enum' and otherIndex isnt i
					rule.name = othervar.name if rule.name is ''
					selected = ''
					if rule.name is othervar.name
						selected = 'selected'
						options = othervar.options
					html += '<option value="' + othervar.name + '" ' + selected + '>' + othervar.label + '</option>'
				html += '</select>'
				html += '<select data-index="' + i + '" data-ri="' + ri + '" class="doRuleOperatorChange">'
				html += '<option value="is" ' + (if rule.operator is 'is' then 'selected' else '') + '>is</option>'
				html += '<option value="isnt" ' + (if rule.operator is 'isnt' then 'selected' else '') + '>isn\'t</option>'
				html += '</select>'
				html += '<select data-index="' + i + '" data-ri="' + ri + '" class="doRuleValueChange">'
				for option in options
					rule.value = option.value if rule.value is ''
					html += '<option value="' + option.value + '" ' + (if rule.value is option.value then 'selected' else '') + '>' + option.label + '</option>'
				html += '</select>'
				if ri < variable.rules.length-1
					html += '<select data-index="' + i + '" data-ri="' + ri + '" class="doRuleNextChange">'
					html += '<option value="and" ' + (if rule.next is 'and' then 'selected' else '') + '>and</option>'
					html += '<option value="or" ' + (if rule.next is 'or' then 'selected' else '') + '>or</option>'
					html += '</select>'
			html+='</td></tr>'
			html += '</table>'
		html += '<table><tr>'
		html += '<td class="button"><button class="doAddVariable">Add Variable</button></td>'
		html += '<td class="button"><button class="doRestore">Restore Defaults</button></td>'
		html += '</tr></table>'