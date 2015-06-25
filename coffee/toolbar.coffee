
class Bulb.Toolbar extends CJS.Component

	click: (element) ->
		@getEvent('doNew').fire() if element.hasClass('doNew')
		@getEvent('doSave').fire() if element.hasClass('doSave')
		@getEvent('doLoad').fire() if element.hasClass('doLoad')
		@getEvent('doUndo').fire() if element.hasClass('doUndo')
		@getEvent('doRedo').fire() if element.hasClass('doRedo')
		@getEvent('doSettings').fire() if element.hasClass('doSettings')
		@getEvent('doHelp').fire() if element.hasClass('doHelp')
		@getEvent('addVector').fire() if element.hasClass('doAddVector')
		@getEvent('addCircle').fire() if element.hasClass('doAddCircle')
		@getEvent('addPlane').fire() if element.hasClass('doAddPlane')
		@getEvent('addCube').fire() if element.hasClass('doAddCube')
		@getEvent('addSphere').fire() if element.hasClass('doAddSphere')
		@getEvent('addCylinder').fire() if element.hasClass('doAddCylinder')
		@getEvent('addTorus').fire() if element.hasClass('doAddTorus')
		@getEvent('addFluid').fire() if element.hasClass('doAddFluid')
		@getEvent('addWind').fire() if element.hasClass('doAddWind')
		@getEvent('changeTransformMode').fire(element.value) if element.hasClass('doChangeMode')
		@getEvent('changeTransformSpace').fire(element.value) if element.hasClass('doChangeSpace')

	checkTransform: (transform) ->
		for element in document.querySelectorAll('#' + @id + ' .doChangeMode')
			element.checked = no
			element.checked = yes if element.value is transform
		@

	checkSpace: (space) ->
		for element in document.querySelectorAll('#' + @id + ' .doChangeSpace')
			element.checked = no
			element.checked = yes if element.value is space
		@

	getHtml: ->
		html = '<div class="title">Toolbar</div>'
		html += '<div class="button doNew" title="New"><img src="./images/page_white.png" width="16" height="16"></div>'
		html += '<div class="button doLoad" title="Import Object"><img src="./images/folder.png" width="16" height="16"></div>'
		html += '<div class="button doSave" title="Export..."><img src="./images/disk.png" width="16" height="16"></div>'
		html += '<div class="button doUndo" title="Undo (Ctrl+Z)"><img src="./images/arrow_undo.png" width="16" height="16"></div>'
		html += '<div class="button doRedo" title="Redo (Ctrl+Shift+Z)"><img src="./images/arrow_redo.png" width="16" height="16"></div>'
		html += '<div class="button doSettings" title="Settings"><img src="./images/wrench.png" width="16" height="16"></div>'
		html += '<div class="button doHelp" title="Help"><img src="./images/help.png" width="16" height="16"></div>'
		html += '<div class="button doAddVector" title="Vector"><img src="./images/vector.png" width="16" height="16"></div>'
		html += '<div class="button doAddCircle" title="Circle"><img src="./images/circle.png" width="16" height="16"></div>'
		html += '<div class="button doAddPlane" title="Plane"><img src="./images/plane.png" width="16" height="16"></div>'
		html += '<div class="button doAddCube" title="Cube"><img src="./images/cube.png" width="16" height="16"></div>'
		html += '<div class="button doAddSphere" title="Sphere"><img src="./images/sphere.png" width="16" height="16"></div>'
		html += '<div class="button doAddCylinder" title="Cylinder"><img src="./images/cylinder.png" width="16" height="16"></div>'
		html += '<div class="button doAddTorus" title="Torus"><img src="./images/torus.png" width="16" height="16"></div>'
		html += '<br>'
		html += '<div class="button doAddFluid" title="Fluid Source"><img src="./images/water.png" width="16" height="16"></div>'
		html += '<div class="button doAddWind" title="Wind Source"><img src="./images/wind.png" width="16" height="16"></div>'
		html += '<div style="clear: both;"></div>'
		html += '<fieldset><legend>Transform Mode</legend>'
		html += '<label><input class="doChangeMode" type="radio" name="mode" value="translate" checked>Translate</label><br>'
		html += '<label><input class="doChangeMode" type="radio" name="mode" value="rotate">Rotate</label><br>'
		html += '<label><input class="doChangeMode" type="radio" name="mode" value="scale">Scale</label>'
		html += '</fieldset>'
		html += '<fieldset><legend>Transform Space</legend>'
		html += '<label><input class="doChangeSpace" type="radio" name="space" value="world" checked>World</label><br>'
		html += '<label><input class="doChangeSpace" type="radio" name="space" value="local">Local</label><br>'
		html += '</fieldset>'
