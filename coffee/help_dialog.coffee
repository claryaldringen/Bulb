
class Bulb.HelpDialog extends Bulb.Dialog

	click: (element) ->
		@close() if element.hasClass('doClose')

	getHtml: ->
		"""
		<h3>Shortkeys</h3>
		<ul>
			<li><b>m</b> - Change mode (Mesh/Vertices)</li>
			<li><b>x</b> - Set actual axis to X.</li>
			<li><b>y</b> - Set actual axis to Y.</li>
			<li><b>z</b> - Set actual axis to Z.</li>
			<li><b>n</b> - Set actual vertex move order parallel to normal vector.</li>
			<li><b>Arrow Key Up/Right</b> - if actual axis is set, moves mesh/vertex parallel to the actual axis in a positive order.</li>
			<li><b>Arrow Key Down/Left</b> - if actual axis is set, moves mesh/vertex parallel to the actual axis in a negative order.</li>
			<li><b>Arrow Key Down/Left/Right/Up + Shift</b> - move is more quickly than without Shift key.</li>
			<li><b>t</b> - Set actual transformation to translation.</li>
			<li><b>r</b> - Set actual transformation to rotation.</li>
			<li><b>s</b> - Set actual transformation to scale.</li>
			<li><b>p</b> - Toggle selection context between select and move.</li>
			<li><b>f</b> - Click to the vertex after f key pressed, selects all vertices in a closed area.</li>
		</ul>
		<button class="doClose">Close</button>
		"""