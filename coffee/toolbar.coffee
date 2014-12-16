
class Bulb.Toolbar extends CJS.Component

	click: (element) ->
		@getEvent('addCube').fire() if element.className is 'doAddCube'
		@getEvent('addSphere').fire() if element.className is 'doAddSphere'
		@getEvent('addLight').fire() if element.className is 'doAddLight'

	getHtml: ->
		html = '<div class="doAddCube">Cube</div>'
		html += '<div class="doAddSphere">Sphere</div>'
		html += '<div class="doAddLight">Light</div>'