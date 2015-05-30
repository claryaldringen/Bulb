
class Bulb.ScriptControl extends CJS.Component

	constructor: (id, parent) ->
		super(id, parent)
		@actual = 0
		@scripts = [{type: 'export', label: '', extension: '', code: ''}]
		@posibilities =
			position: ['x','y','z']
			rotation: ['x','y','z']
			scale: ['x','y','z']
			userData: []

	getElTAId: -> @id + '-ta'

	getElLabelId: -> @id + '-label'

	getElExtId: -> @id + '-ext'

	getElTypeId: -> @id + '-type'

	load: ->
		json = localStorage.getItem('variables')
		variables = JSON.parse(json)
		@posibilities.userData.push(variable.name) for variable in variables
		json = localStorage.getItem('scripts')
		@scripts = JSON.parse(json) if json?
		@

	save: ->
		localStorage.setItem('scripts', JSON.stringify(@scripts))
		@

	getLastWord: (line, ch) ->
		parts = line.substring(0, ch).split(/[\,\.\;,\s,\+,\-,\=,\*,\/]/)
		parts[parts.length-2]

	renderFinish: ->
		ta = document.getElementById(@getElTAId())
		if ta?
			orig = CodeMirror.hint.javascript
			CodeMirror.hint.javascript = (cm) =>
				inner = orig(cm) || {from: cm.getCursor(), to: cm.getCursor(), list: []}
				pos = cm.getCursor()
				word = @getLastWord(cm.getDoc().getLine(pos.line), pos.ch)
				inner.list.push(posibility) for posibility in @posibilities[word] if @posibilities[word]?
				inner.list.push(command) for command in ['id', 'uuid', 'name', 'parent', 'children','position', 'rotation', 'scale', 'userData'] if not inner.list.length
				inner

			settings =
				lineNumbers: yes
				extraKeys:
					"'.'" : (cm, pred) ->
						cur = cm.getCursor()
						if not pred or pred()
							setTimeout( ->
								cm.showHint( completeSingle: no ) if not cm.state.completionActive
							, 100)
						CodeMirror.Pass
		@codemirror = CodeMirror.fromTextArea(ta, settings)
		@codemirror.setSize(800,378)
		@codemirror.on 'change', (cm) => @scripts[@actual].code = cm.getValue()
		@

	click: (element) ->
		if element.hasClass('doAdd')
			label = document.getElementById(@getElLabelId())
			ext = document.getElementById(@getElExtId())
			type = document.getElementById(@getElTypeId())
			if label.value isnt '' and ext.value isnt ''
				@scripts.push({type: ['export','import'][type.selectedIndex], label: label.value, extension: ext.value, code: ''})
				@save().render()
		if element.hasClass('doScriptChange')
			@actual = element.selectedIndex
			@render()
		if element.hasClass('doSave')
			label = document.getElementById(@getElLabelId())
			ext = document.getElementById(@getElExtId())
			type = document.getElementById(@getElTypeId())
			if label.value isnt '' and ext.value isnt ''
				@scripts[@actual].label = label.value
				@scripts[@actual].extension = ext.value
				@scripts[@actual].type = ['export','import'][type.selectedIndex]
				#console.log type
				@save().render()
		if element.hasClass('doDelete') and confirm('Really delete?')
			@scripts.splice(@actual, 1)
			@actual--
			@save().render()

	getHtml: ->
		@scripts[@actual].type = 'export' if not @scripts[@actual].type?
		html = '<select class="doScriptChange">'
		for script,i in @scripts
			if script.label isnt ''
				label = script.label + (if script.type? then ' (' + script.type + ')' else '')
			else
				label = ''
			html += '<option value="' + script.extension + '" ' + (if i is @actual then 'selected' else '') + '>' + label + '</option>'
		html += '</select>&nbsp;'
		html += '<label>Type: <select id="' + @getElTypeId() + '">'
		html += '<option value="export" ' + (if @scripts[@actual].type is 'export' then 'selected' else '') + '>Export</option>'
		html += '<option value="import" ' + (if @scripts[@actual].type is 'import' then 'selected' else '') + '>Import</option>'
		html += '</select></label>&nbsp;'
		html += '<label>Label: <input id="' + @getElLabelId() + '" type="text" value="' + @scripts[@actual].label + '"></label>&nbsp;'
		html += '<label>Extension: <input id="' + @getElExtId() + '" type="text" value="' + @scripts[@actual].extension + '"></label>&nbsp;'
		if @actual is 0
			html += '<button class="doAdd">Add</button>'
		else
			html += '<button class="doSave">Save</button>&nbsp;'
			html += '<button class="doDelete">Delete</button>'
		html += '<textarea id="' + @getElTAId() + '">' + @scripts[@actual].code + '</textarea>'