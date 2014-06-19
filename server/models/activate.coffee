mongoose = require("../app").mongoose
timestamps = require('mongoose-time')()
findOrCreate = require('mongoose-findorcreate')

ActivateSchema = mongoose.Schema(
  email:
    type: String
    unique: true
    required: true

  hashedEmail:
    type: String
    unique: true
    required: true

  verifyStatus:
    type: Boolean
,
  label: 'Activations'
)

ActivateSchema.plugin(timestamps)
ActivateSchema.plugin(findOrCreate)

ActivateSchema.method(
)

module.exports = mongoose.model('Activate', ActivateSchema)
