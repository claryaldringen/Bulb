
class Bulb.PackControl extends CJS.Component

	constructor: (id, parent) ->
		super(id, parent)
		@variables = []
		@rules = []

	load: ->
		json = localStorage.getItem('variables')
		@variables = JSON.parse(json) if json?
		json = localStorage.getItem('zip_rules')
		@rules = JSON.parse(json) if json?
		@

	save: ->
		localStorage.setItem('zip_rules', JSON.stringify(@rules))
		@

	change: (element) ->
		@rules[element.dataset.index].name = element.options[element.selectedIndex].value if element.hasClass('doRuleNameChange')
		@rules[element.dataset.index].operator = element.options[element.selectedIndex].value if element.hasClass('doRuleOperatorChange')
		@rules[element.dataset.index].value = element.options[element.selectedIndex].value if element.hasClass('doRuleValueChange')
		@rules[element.dataset.index].next = element.options[element.selectedIndex].value if element.hasClass('doRuleNextChange')

	click: (element) ->
		if element.hasClass('doAddRule')
			@rules.push({name: '', operator: 'is', value: '', next: 'and'})
			@render()
		if element.hasClass('doRemoveRule')
			@rules.splice(@variables[element.dataset.index].rules.length-1, 1)
			@render()

	getHtml: ->
		html = 'Add object to ZIP if '
		for rule,ri in @rules
			options = []
			html += '<select data-index="' + ri + '" class="doRuleNameChange">'
			for othervar,otherIndex in @variables when othervar.type is 'enum'
				rule.name = othervar.name if rule.name is ''
				selected = ''
				if rule.name is othervar.name
					selected = 'selected'
					options = othervar.options
				html += '<option value="' + othervar.name + '" ' + selected + '>' + othervar.label + '</option>'
			html += '</select>'
			html += '<select data-index="' + ri + '" class="doRuleOperatorChange">'
			html += '<option value="is" ' + (if rule.operator is 'is' then 'selected' else '') + '>is</option>'
			html += '<option value="isnt" ' + (if rule.operator is 'isnt' then 'selected' else '') + '>isn\'t</option>'
			html += '</select>'
			html += '<select data-index="' + ri + '" class="doRuleValueChange">'
			for option in options
				rule.value = option.value if rule.value is ''
				html += '<option value="' + option.value + '" ' + (if rule.value is option.value then 'selected' else '') + '>' + option.label + '</option>'
			html += '</select>'
			if ri < @rules.length-1
				html += '<select data-index="' + ri + '" class="doRuleNextChange">'
				html += '<option value="and" ' + (if rule.next is 'and' then 'selected' else '') + '>and</option>'
				html += '<option value="or" ' + (if rule.next is 'or' then 'selected' else '') + '>or</option>'
				html += '</select>'
		html += '<img src="./images/page_add.png" title="Add Rule" class="doAddRule">'
		html += '<img src="./images/page_delete.png" title="Remove Rule" class="doRemoveRule">'
