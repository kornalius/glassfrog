mongoose = require("../app").mongoose
timestamps = require('mongoose-time')()
findOrCreate = require('mongoose-findorcreate')
User = require('./user')

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
    type: mongoose.Schema.ObjectId
    ref: 'User'
    readOnly: true
    populate: true
,
  label: 'Logs'
)

LogSchema.plugin(timestamps)
LogSchema.plugin(findOrCreate)

LogSchema.static(
  log: (user, action, schema, comment, ip, url) ->
    mongoose.model('Log').create(
      user: user.id
      action: action
      schemaName: schema if schema?
      comment: comment if comment?
      ip: ip if ip?
      url: url if url?
    )

  LOG_REQUEST: -> 'R'
  LOG_LOGIN: -> 'L'
  LOG_LOGOUT: -> 'T'
)

module.exports = mongoose.model('Log', LogSchema)
