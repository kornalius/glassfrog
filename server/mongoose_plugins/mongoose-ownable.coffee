module.exports = ((schema, options) ->

  if options and options.path?
    path = options.path + '.'
  else
    path = ''

  owner = path + 'owner_id'

  schema.add(
    owner_id:
      type: String
      required: true
  , path)

  if options && options.index
    schema.path(owner).index(options.index)

  schema.static(

    findByIdAndOwnerId: (id, ownerId, callback)->
      @findById(id, (err, item) ->
        return callback err if err?
        return callback( new Error("#{id} not found")) unless item
        return callback( new Error("#{id} permission denied")) unless item.owner_id is ownerId
        return callback(null, item)
      )

    findAllByOwnerId: (ownerId, callback)->
      @find(owner_id:ownerId, callback)

    countByOwnerId: (ownerId, callback)->
      @count({owner_id: ownerId}, callback)
  )
)
