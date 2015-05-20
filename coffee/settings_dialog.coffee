
class Bulb.SettingsDialog extends CJS.Component

	constructor: (id, parent) ->
		super(id, parent)
		@tool = 'typedef'

	getElTCId: -> @id + '_tc'

	getElSSCId: -> @id + '_ssc'

	getElPCId: -> @id + '_pc'

	getTypedefControl: ->
		id = @getElTCId()
		child = @getChildById(id)
		if not child?
			child = new Bulb.TypedefControl(id, @)
			child.load()
		child

	getScriptControl: ->
		id = @getElSSCId()
		child = @getChildById(id)
		if not child?
			child = new Bulb.ScriptControl(id, @)
			child.load()
		child

	getPackControl: ->
		id = @getElPCId()
		child = @getChildById(id)
		if not child?
			child = new Bulb.PackControl(id, @)
			child.load()
		child

	save: ->
		@getTypedefControl().save()
		@getScriptControl().save()
		@getPackControl().save()
		@

	click: (element) ->
		@close() if element.hasClass('doClose')
		@save() if element.hasClass('doApply')
		@save().close() if element.hasClass('doSave')
		if element.hasClass('doChangeTool')
			@tool = element.dataset.tool
			@render()

	getHtml: ->
		html = '<div class="settings_toolbar">'
		html += '<div class="doChangeTool" data-tool="typedef"><img src="./images/tools.png" data-tool="typedef"><br>Typedef Settings</div><br>'
		html += '<div class="doChangeTool" data-tool="saveScript"><img src="./images/disc.png" data-tool="saveScript"><br>Save Scripts</div><br>'
		html += '<div class="doChangeTool" data-tool="pack"><img src="./images/box.png" data-tool="pack"><br>ZIP Settings</div><br>'
		html += '</div>'
		switch @tool
			when 'typedef' then html += '<div class="settings_content" id="' + @getElTCId() + '">' + @getTypedefControl().getHtml() + '</div>'
			when 'saveScript' then html += '<div class="settings_content" id="' + @getElSSCId() + '">' + @getScriptControl().getHtml() + '</div>'
			when 'pack' then html += '<div class="settings_content" id="' + @getElPCId() + '">' + @getPackControl().getHtml() + '</div>'
		html += '<div class="window_buttons">'
		html += '<button class="doClose">Close</button>&nbsp;'
		html += '<button class="doApply">Apply</button>&nbsp;'
		html += '<button class="doSave">Save</button>'
		html += '</div>'
