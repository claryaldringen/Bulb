
class Bulb.Storage

	constructor: ->

	getIndexedDb: ->
		new Promise (resolve, reject) ->
			request = window.indexedDB.open('Bulb', 4)
			request.onupgradeneeded = (event) ->
				db = event.target.result
				db.createObjectStore('states') if not db.objectStoreNames.contains('states')
				resolve(db)
			request.onsuccess = (event) -> resolve(event.target.result)
			request.onerror = (event) -> reject('Database error: ' + event.target.errorCode)

	set: (data) ->
		@getIndexedDb().then( (db) => @save(db, data) )

	get: (obj, callback)->
		@getIndexedDb().then( (db) => @load(db, obj, callback) )

	save: (db, data, callback) ->
		json = JSON.stringify(data)
		if @lastJson isnt json
			transaction = db.transaction(['states'], 'readwrite');
			objectStore = transaction.objectStore('states')
			@id = 1 if not @id?
			request = objectStore.put(data, @id)
			request.onsuccess = =>
				@lastJson = json
				@increase()
				console.log @id


	load: (db, obj, callback) ->
		transaction = db.transaction(['states'], 'readwrite');
		objectStore = transaction.objectStore('states')
		if not @id?
			request = objectStore.get(0)
			request.onsuccess = (event) =>
				if event.target.result? and event.target.result.lastId?
					@id = event.target.result.lastId
					@load(db, obj, callback)
			return
		console.log @id
		request = objectStore.get(@id)
		request.onsuccess = (event) -> callback.call(obj,event.target.result)

	saveMetadata: (db) ->
		transaction = db.transaction(['states'], 'readwrite');
		objectStore = transaction.objectStore('states')
		request = objectStore.put({lastId: @id}, 0)

	decrease: ->
		if @id > 1
			@id--
			@getIndexedDb().then( (db) => @saveMetadata(db) )
		@

	increase: ->
		@id++
		@getIndexedDb().then( (db) => @saveMetadata(db) )
		@
