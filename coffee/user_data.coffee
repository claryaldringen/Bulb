
class Bulb.UserData extends CJS.Component

	setObject: (@object) ->
		if not @object.userData.type?
			@object.userData.type = 'm'
			@object.userData.sediment = {sedimentChange: 0, maxSedimentInParticle: 0, criticalShear: 0}
		@

	change: (element) ->
		if element.hasClass('doTypeChange')
			value = element.options[element.selectedIndex].value
			@object.userData.type = value
			@object.userData.rate = 0 if value in ['f','w']
			@render()
		@object.userData.sediment.sedimentChange = element.value if element.hasClass('doSedimentChange')
		@object.userData.sediment.maxSedimentInParticle = element.value if element.hasClass('doMaxSedimentChange')
		@object.userData.sediment.criticalShear = element.value if element.hasClass('doShearChange')
		@object.userData.rate = element.value if element.hasClass('doRateChange')

	getHtml: ->
		html = '<table>'
		html += '<tr><th>Type:</th><td>'
		html += '<select class="doTypeChange">'
		html += '<option value="m" ' + (if @object.userData.type is 'm' then 'selected' else '') + '>Model</option>'
		html += '<option value="f" ' + (if @object.userData.type is 'f' then 'selected' else '') + '>Fluid Source</option>'
		html += '<option value="w" ' + (if @object.userData.type is 'w' then 'selected' else '') + '>Wind Source</option>'
		html += '</select>'
		html += '</td></tr>'
		if @object.userData.type is 'm'
			sediment = @object.userData.sediment
			html += '<tr><th>Sediment change:</th><td><input class="doSedimentChange" type="number" step="0.01" value="' + sediment.sedimentChange + '"></td></tr>'
			html += '<tr><th>Max&nbsp;sediment&nbsp;in&nbsp;particle:</th><td><input class="doMaxSedimentChange" type="number" step="0.1" value="' + sediment.maxSedimentInParticle + '"></td></tr>'
			html += '<tr><th>Critical shear:</th><td><input class="doShearChange" type="number" step="0.01" value="' + sediment.criticalShear + '"></td></tr>'
		if @object.userData.type in ['f','w']
			html += '<tr><th>Rate:</th><td><input class="doRateChange" type="number" step="1" value="' + @object.userData.rate + '"></td></tr>'
		html += '</table>'
