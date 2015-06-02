$(document).ready ->
	localStorage.setItem('scripts', JSON.stringify(Bulb.data.scripts)) if not localStorage.getItem('scripts')?
	localStorage.setItem('variables', JSON.stringify(Bulb.data.variables)) if not localStorage.getItem('variables')?
	localStorage.setItem('zip_rules', JSON.stringify(Bulb.data.zip_rules)) if not localStorage.getItem('zip_rules')?
	doc = new Bulb.Document('document')
	doc.render()