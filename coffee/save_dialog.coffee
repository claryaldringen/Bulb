
class Bulb.SaveDialog extends Bulb.Dialog

	constructor: (id, parent) ->
		super(id, parent)
		@saveTypes = []
		@index = 0

	getElExtId: -> @id + '-ext'

	getElNameId: -> @id + '-name'

	addSaveType: (label, extension) ->
		@saveTypes.push({label: label, extension: extension})
		@

	change: (element) ->
		if element.hasClass('doChange')
			@index = element.selectedIndex
			document.getElementById(@getElExtId()).innerHTML = @saveTypes[@index].extension

	click: (element) ->
		@close() if element.hasClass('doClose')
		if element.hasClass('doSave')
			@getEvent('save').fire(@index, document.getElementById(@getElNameId()).value)
			@close()

	getHtml: ->
		html = '<table>'
		html += '<tr><td colspan="2"><label>Save type: <select class="doChange">'
		html += '<option value="' + index + '">' + type.label + ' (*.' + type.extension + ')</option>' for type, index in @saveTypes
		html += '</select></label></td></tr>'
		html += '<tr><td colspan="2"><label>Filename: <input id="' + @getElNameId() + '" type="text"></label>.<span id="' + @getElExtId() + '">' + @saveTypes[@index].extension + '</span></td></tr>'
		html += '<tr style="text-align: center"><td><button class="doClose">Cancel</button></td>'
		html += '<td><button class="doSave">Download</button></td></tr>'
		html += '</table>'