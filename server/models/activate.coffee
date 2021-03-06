mongoose = require("mongoose")
timestamps = require('mongoose-time')()

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
  readOnly: true
)

ActivateSchema.plugin(timestamps)

ActivateSchema.method(
)

module.exports = mongoose.model('Activate', ActivateSchema)
