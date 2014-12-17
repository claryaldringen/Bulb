
class Bulb.Toolbar extends CJS.Component

	click: (element) ->
		@getEvent('addCircle').fire() if element.className is 'doAddCircle'
		@getEvent('addPlane').fire() if element.className is 'doAddPlane'
		@getEvent('addCube').fire() if element.className is 'doAddCube'
		@getEvent('addSphere').fire() if element.className is 'doAddSphere'
		@getEvent('addCylinder').fire() if element.className is 'doAddCylinder'
		@getEvent('addDodecahedron').fire() if element.className is 'doAddDodecahedron'
		@getEvent('addTorus').fire() if element.className is 'doAddTorus'
		@getEvent('addLight').fire() if element.className is 'doAddLight'

	getHtml: ->
		html = '<div class="doAddCircle">Circle</div>'
		html += '<div class="doAddPlane">Plane</div>'
		html += '<div class="doAddCube">Cube</div>'
		html += '<div class="doAddSphere">Sphere</div>'
		html += '<div class="doAddCylinder">Cylinder</div>'
		html += '<div class="doAddDodecahedron">Dodecahedron</div>'
		html += '<div class="doAddTorus">Torus</div>'
		html += '<div class="doAddLight">Light</div>'