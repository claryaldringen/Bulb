
class Bulb.ObjectCollection

	constructor: ->
		@objects = {}
		@asArray = {}

	set: (key, object) ->
		@objects[key] = object
		@

	get: (key) -> @objects[key]

	pop: (key) ->
		object = @get(key)
		delete(@objects[key])
		object

	add: (collectionType, object) ->
		if not @objects[collectionType]?
			@objects[collectionType] = {}
			@asArray[collectionType] = []
		@objects[collectionType][object.id] = object
		@asArray[collectionType].push(object)
		@

	remove: (collectionType, object) ->
		if @objects[collectionType]?
			delete(@objects[collectionType][object.id])
			@asArray[collectionType] = []
			@asArray[collectionType].push(object) for objectId, object of @objects[collectionType]
		@

	getAsArray: (collectionType) -> if @asArray[collectionType]? then @asArray[collectionType] else []
