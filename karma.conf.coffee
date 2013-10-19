module.exports = (config) ->
	config.set
		basePath: './'
		frameworks: ['jasmine']
		autoWatch: yes
		autoWatchBatchDelay: 1000
		browsers: ['PhantomJS']
		files: [
			{pattern: 'bower_components/threejs/build/three.js', watched: no}
			'coffee/**/*.coffee',
			'tests/coffee/**/*.coffee'
		]