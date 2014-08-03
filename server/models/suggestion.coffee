mongoose = require("../app").mongoose
timestamps = require('mongoose-time')()

SuggestionSchema = mongoose.Schema(

  name:
    type: String
    required: true
    label: 'Name'

  email:
    type: String
    required: true
    label: 'Email'

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

module.exports = mongoose.model('Suggestion', SuggestionSchema)