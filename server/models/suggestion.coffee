mongoose = require("mongoose")
timestamps = require('mongoose-time')()
filterPlugin = require('../mongoose_plugins/mongoose-filter')

SuggestionSchema = mongoose.Schema(

  name:
    type: String
    required: true
    label: 'Name'

  email:
    type: String
    required: true
    label: 'Email'

  date:
    type: Date
    required: false
    label: 'Test Date'

  message:
    type: String
    required: true
    label: 'Message'

  kind:
    type: String
    enum: ['General Question', 'Server Issues', 'Billing Question']
    default: 'General Question'
    required: true
    label: 'Type'
,
  label: 'Suggestions'
)

SuggestionSchema.plugin(timestamps)
SuggestionSchema.plugin(filterPlugin)

module.exports = mongoose.model('Suggestion', SuggestionSchema)
