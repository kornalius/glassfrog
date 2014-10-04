mongoose = require("mongoose")
timestamps = require('mongoose-time')()
filterPlugin = require('../mongoose_plugins/mongoose-filter')

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
ActivateSchema.plugin(filterPlugin)

ActivateSchema.method(
)

module.exports = mongoose.model('Activate', ActivateSchema)
