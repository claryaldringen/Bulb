
class Bulb.Toolbar extends CJS.Component

	click: (element) ->
		@getEvent('doSave').fire() if element.hasClass('doSave')
		@getEvent('doSaveAll').fire() if element.hasClass('doSaveAll')
		@getEvent('doLoad').fire() if element.hasClass('doLoad')
		@getEvent('addVector').fire() if element.hasClass('doAddVector')
		@getEvent('addCircle').fire() if element.hasClass('doAddCircle')
		@getEvent('addPlane').fire() if element.hasClass('doAddPlane')
		@getEvent('addCube').fire() if element.hasClass('doAddCube')
		@getEvent('addSphere').fire() if element.hasClass('doAddSphere')
		@getEvent('addCylinder').fire() if element.hasClass('doAddCylinder')
		@getEvent('addTorus').fire() if element.hasClass('doAddTorus')
		@getEvent('changeTransformMode').fire(element.value) if element.hasClass('doChangeMode')
		@getEvent('changeTransformSpace').fire(element.value) if element.hasClass('doChangeSpace')

	getHtml: ->
		html = '<div class="title">Toolbar</div>'
		html += '<div class="button doNew" title="New"><img src="./images/page_white.png" width="16" height="16"></div>'
		html += '<div class="button doLoad" title="Import Object"><img src="./images/folder.png" width="16" height="16"></div>'
		html += '<div class="button doSave" title="Export Object"><img src="./images/disk.png" width="16" height="16"></div>'
		html += '<div class="button doSaveAll" title="Export Scene"><img src="./images/disk_multiple.png" width="16" height="16"></div>'
		html += '<div class="button doAddVector" title="Vector"><img src="./images/vector.png" width="16" height="16"></div>'
		html += '<div class="button doAddCircle" title="Circle"><img src="./images/circle.png" width="16" height="16"></div>'
		html += '<div class="button doAddPlane" title="Plane"><img src="./images/plane.png" width="16" height="16"></div>'
		html += '<div class="button doAddCube" title="Cube"><img src="./images/cube.png" width="16" height="16"></div>'
		html += '<div class="button doAddSphere" title="Sphere"><img src="./images/sphere.png" width="16" height="16"></div>'
		html += '<div class="button doAddCylinder" title="Cylinder"><img src="./images/cylinder.png" width="16" height="16"></div>'
		html += '<div class="button  doAddTorus" title="Torus"><img src="./images/torus.png" width="16" height="16"></div>'
		html += '<fieldset><legend>Transform Mode</legend>'
		html += '<label><input class="doChangeMode" type="radio" name="mode" value="translate" checked>Translate</label><br>'
		html += '<label><input class="doChangeMode" type="radio" name="mode" value="rotate">Rotate</label><br>'
		html += '<label><input class="doChangeMode" type="radio" name="mode" value="scale">Scale</label>'
		html += '</fieldset>'
		html += '<fieldset><legend>Transform Space</legend>'
		html += '<label><input class="doChangeSpace" type="radio" name="space" value="world" checked>World</label><br>'
		html += '<label><input class="doChangeSpace" type="radio" name="space" value="local">Local</label><br>'
		html += '</fieldset>'
