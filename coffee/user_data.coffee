
class Bulb.UserData extends CJS.Component

	setObject: (@object) ->
		if not @object.userData.type? and not (@object instanceof THREE.Scene)
			@object.userData.type = 'm'
			@object.userData.reverseWinding = 0
			@object.userData.sediment = {sedimentChange: 0, criticalShear: 0}
		else if @object instanceof THREE.Scene and not @object.userData.type?
			@object.userData.type = 's'
			@object.userData.maxSedimentInParticle = 0
			@object.userData.maxNumberOfParticles = 0
			@object.userData.distanceLimitForTesselation = 0
		@

	change: (element) ->
		if element.hasClass('doTypeChange')
			value = element.options[element.selectedIndex].value
			@object.userData.type = value
			@object.userData.rate = 0 if value in ['f','w']
			if value is 'm'
				@object.userData.sediment = {sedimentChange: 0, criticalShear: 0}
				@object.userData.reverseWinding = 0
			@render()
		@object.userData.sediment.sedimentChange = element.value if element.hasClass('doSedimentChange')
		@object.userData.sediment.criticalShear = element.value if element.hasClass('doShearChange')
		@object.userData.maxSedimentInParticle = element.value if element.hasClass('doMaxSedimentChange')
		@object.userData.maxNumberOfParticles = element.value if element.hasClass('doMaxNumberOfParticlesChange')
		@object.userData.distanceLimitForTesselation = element.value if element.hasClass('doDistanceLimitChange')
		@object.userData.rate = element.value if element.hasClass('doRateChange')
		@object.userData.reverseWinding = element.checked if element.hasClass('doReverseWinding')

	getHtml: ->
		html = '<table>'
		if @object.userData.type isnt 's'
			html += '<tr><th>Type:</th><td>'
			html += '<select class="doTypeChange">'
			html += '<option value="m" ' + (if @object.userData.type is 'm' then 'selected' else '') + '>Model</option>'
			html += '<option value="f" ' + (if @object.userData.type is 'f' then 'selected' else '') + '>Fluid Source</option>'
			html += '<option value="w" ' + (if @object.userData.type is 'w' then 'selected' else '') + '>Wind Source</option>'
			html += '</select>'
			html += '</td></tr>'
		if @object.userData.type is 'm'
			sediment = @object.userData.sediment
			html += '<tr><td colspan="2"><label><input type="checkbox" class="doReverseWinding" style="width: auto;" ' + (if @object.userData.reverseWinding then 'checked' else '') + '>Reverse winding</label></td></tr>'
			html += '<tr><th>Sediment&nbsp;change:</th><td><input class="doSedimentChange" type="number" step="0.01" value="' + sediment.sedimentChange + '"></td></tr>'
			html += '<tr><th>Critical&nbsp;shear:</th><td><input class="doShearChange" type="number" step="0.01" value="' + sediment.criticalShear + '"></td></tr>'
		if @object.userData.type in ['f','w']
			html += '<tr><th>Rate:</th><td><input class="doRateChange" type="number" step="1" value="' + @object.userData.rate + '"></td></tr>'
		if @object.userData.type is 's'
			html += '<tr><th>Max&nbsp;sediment&nbsp;in&nbsp;particle:</th><td><input class="doMaxSedimentChange" type="number" step="0.1" value="' + @object.userData.maxSedimentInParticle + '"></td></tr>'
			html += '<tr><th>Max&nbsp;number&nbsp;of&nbsp;particles:</th><td><input class="doMaxNumberOfParticlesChange" type="number" step="1" value="' + @object.userData.maxNumberOfParticles + '"></td></tr>'
			html += '<tr><th>Distance&nbsp;limit&nbsp;for&nbsp;tesselation:</th><td><input class="doDistanceLimitChange" type="number" step="1" value="' + @object.userData.distanceLimitForTesselation + '"></td></tr>'
		html += '</table>'
