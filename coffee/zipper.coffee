
class Bulb.Zipper

	constructor: ->
		zip.workerScriptsPath = 'js/'

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
