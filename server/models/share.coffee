mongoose = require("../app").mongoose
timestamps = require('mongoose-time')()
findOrCreate = require('mongoose-findorcreate')
Node_Data = require("../app").Node_Data

ShareSchema = mongoose.Schema(
  owner:
    type: mongoose.Schema.ObjectId
    ref: 'User'
    required: true
    label: 'From user'

  node:
    type: mongoose.Schema.ObjectId
    ref: 'Node'
    required: true
    label: 'Project'
    populate: true

  hostData:
    type: Boolean
    required: true
    default: false
    label: 'Should you host the data on your plan'

  users:
    type: [
      user:
        type: mongoose.Schema.ObjectId
        ref: 'User'
        required: true
        label: 'User'
        populate: true

      state:
        type: String
        enum: ['active', 'disabled']
        default: 'disabled'
        required: true
        label: 'Share state'
    ]
    label: 'User(s)'
    populate: true

,
  label: 'Shares'
)

ShareSchema.plugin(timestamps)
ShareSchema.plugin(findOrCreate)

ShareSchema.post('save', (doc) ->
  mongoose.model('Share').refreshShares()
)

ShareSchema.post('remove', (doc) ->
  mongoose.model('Share').refreshShares()
)

ShareSchema.method(

  accept: (userId, cb) ->
    that = @
    if userId in that.users and that.state != 'active'
      that.state = 'active'
      that.save()
      cb(true) if cb
    else
      cb(false) if cb

)

ShareSchema.static(

  share: (userId, host, nodeId, userIds, cb) ->
    console.log "share()", "userId", userId, "host", host, "nodeId", nodeId, "userIds", userIds
    mongoose.model('Share').findById(nodeId, (err, node) ->
      if node
        if node.owner_id? and node.owner_id.toString() == userId.toString()
          mongoose.model('Share').create({ owner: userId, hostData: host, users: userIds.map((u) -> {user: u, state: 'disabled'}), node: nodeId }, (err, share) ->
            cb(err, share) if cb
          )
        else
          cb(new Error('You must be the owner of the node to share it'), null) if cb
      else
        cb(new Error('Node not found'), null) if cb
    )
)

module.exports = mongoose.model('Share', ShareSchema)
