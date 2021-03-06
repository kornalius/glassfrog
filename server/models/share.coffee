mongoose = require("mongoose")
timestamps = require('mongoose-time')()
roles = require('../mongoose_plugins/mongoose-roles')

ShareSchema = mongoose.Schema(
  module:
    type: mongoose.Schema.Types.ObjectId
    ref: 'Module'
    required: true
    label: 'Module'
    populate: true

  host:
    type: Boolean
    required: true
    default: false
    label: 'Should you host the data on your plan'

  users: [
    user_id:
      type: mongoose.Schema.Types.ObjectId
      ref: 'User'
      required: true
      label: 'User'
      populate: true
  ]
,
  label: 'Shares'
  readOnly: true
)

ShareSchema.plugin(timestamps)
ShareSchema.plugin(roles, {path: 'users'})

#ShareSchema.set('toObject', {virtuals: true})
#ShareSchema.set('toJSON', {virtuals: true})

#ShareSchema.post('save', (doc) ->
#  mongoose.model('Share').refreshShares()
#)
#
#ShareSchema.post('remove', (doc) ->
#  mongoose.model('Share').refreshShares()
#)

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

  share: (userId, host, moduleId, userIds, cb) ->
    console.log "share()", "userId", userId, "host", host, "module", module, "userIds", userIds
    mongoose.model('Share').find({module: moduleId}, (err, share) ->
      if !share
        mongoose.model('Module').findById(moduleId, (err, module) ->
          if module
            if module.owner_id? and module.owner_id.toString() == userId.toString()
              mongoose.model('Share').create({ module: moduleId, hostData: host, users: userIds.map((u) -> {user: u, state: 'disabled'}) }, (err, share) ->
                if share
                  module.share = share.id
                  module.save()
                cb(err, share) if cb
              )
            else
              cb(new Error('You must be the owner of the module to share it'), null) if cb
          else
            cb(new Error('Module not found'), null) if cb
        )
      else
        cb(new Error('Module already shared'), null) if cb
    )
)

module.exports = mongoose.model('Share', ShareSchema)
