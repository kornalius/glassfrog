mongoose = require("mongoose")
timestamps = require('mongoose-time')()

LogSchema = mongoose.Schema(
  action:
    type: String
    lowercase: true
    index: true
    required: true
    readOnly: true
    label: 'Action'

  schemaName:
    type: String
    lowercase: true
    readOnly: true
    label: 'Schema'

  ip:
    type: String
    readOnly: true
    label: 'IP'

  url:
    type: String
    readOnly: true
    label: 'Url'

  comment:
    type: String
    readOnly: true
    label: 'Comment'

  user:
    type: mongoose.Schema.Types.ObjectId
    ref: 'User'
    readOnly: true
    populate: true
,
  label: 'Logs'
  readOnly: true
)

LogSchema.plugin(timestamps)

#LogSchema.set('toObject', {virtuals: true})
#LogSchema.set('toJSON', {virtuals: true})

LogSchema.static(
  log: (user, action, schema, comment, ip, url) ->
    mongoose.model('Log').create(
      user: user._id
      action: action
      schemaName: schema if schema?
      comment: comment if comment?
      ip: ip if ip?
      url: url if url?
    )

  LOG_REQUEST: ->
    'R'
  LOG_LOGIN: ->
    'L'
  LOG_LOGOUT: ->
    'T'
)

module.exports = mongoose.model('Log', LogSchema)
