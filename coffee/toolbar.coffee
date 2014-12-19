
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
		html = '<div class="doAddCircle" title="Circle">Ci</div>'
		html += '<div class="doAddPlane" title="Plane">Pl</div>'
		html += '<div class="doAddCube" title="Cube">Cu</div>'
		html += '<div class="doAddSphere" title="Sphere">Sp</div>'
		html += '<div class="doAddCylinder" title="Cylinder">Cy</div>'
		html += '<div class="doAddDodecahedron" title="Dodecahedron">Do</div>'
		html += '<div class="doAddTorus" title="Torus">To</div>'
		html += '<div class="doAddLight" title="Light">Li</div>'