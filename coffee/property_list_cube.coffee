
class Bulb.PropertyListCube extends Bulb.PropertyList

	getGeometrySectionHtml: ->
		html = '<tr><th>Geometry</th></tr>'
		for property,value of @geometry
			html += '<tr><td><label>' + property + ': <input data-type="geometry" data-axis="' + property + '" type="number" value="' + value + '"></label></td></tr>'
		html

		#html += '<tr><td><label>Y: <input data-type="geometry" data-axis="height" type="number" value="' + @geometry.height + '"></label></td></tr>'
		#html += '<tr><td><label>Z: <input data-type="geometry" data-axis="depth" type="number" value="' + @geometry.depth + '"></label></td></tr>'
		#html += '<tr><td><label>X: <input data-type="geometry" data-axis="widthSegments" type="number" value="' + @geometry.widthSegments + '"></label></td></tr>'
		#html += '<tr><td><label>Y: <input data-type="geometry" data-axis="heightSegments" type="number" value="' + @geometry.heightSegments + '"></label></td></tr>'
		#html += '<tr><td><label>Z: <input data-type="geometry" data-axis="depthSegments" type="number" value="' + @geometry.depthSegments + '"></label></td></tr>'
