
class Bulb.Zipper

	constructor: ->
		zip.workerScriptsPath = 'js/'
		@events = {}

	getEvent: (event) ->
		if not @events[event]
			@events[event] = new CJS.Event()
		@events[event]

	addFiles: (files, callback) ->
		zip.createWriter(
			new zip.BlobWriter("application/zip")
			(zipWriter) ->
				addIndex = 0
				nextFile = ->
					file = files[addIndex]
					zipWriter.add(
						file.name,
						new zip.BlobReader(file.content)
						->
							addIndex++
							if (addIndex < files.length)
								nextFile()
							else
								zipWriter.close(callback)
				)
				nextFile()
			(message) -> console.log message
		)

	readFiles: (zipFile) ->
		zip.createReader(
			new zip.BlobReader(zipFile)
			(zipReader) =>
				zipReader.getEntries(
					(entries) =>
						@getEntryFile(entry, i, entries.length-1) for entry,i in entries
				)
		)

	getEntryFile: (entry, index, max) ->
		name = entry.filename.split('.')
		ext = name.splice(name.length-1, 1)[0]
		name = name.join('.')
		entry.getData(new zip.TextWriter(), (text) =>
			@getEvent('read').fire(text, name, ext)
			@getEvent('readEnd').fire() if index is max
		)
