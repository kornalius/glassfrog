app = require("../../app")
mongoose = require("../../app").mongoose
timestamps = require('mongoose-time')()
async = require('async')
endpoints = require('../../endpoints')

address = require('../../mongoose_plugins/mongoose-address')
picture = require('../../mongoose_plugins/mongoose-picture')

CompanySchema = mongoose.Schema(
  name:
    type: String
    required: true
    trim: true
    label: 'Name'

  numbering: [
    name:
      type: String
      required: true
      trim: true
      lowercase: true
      label: 'Custom # Name'

    start:
      type: Number
      required: true
      default: 1000
      label: 'Custom # Start'

    increment:
      type: Number
      required: true
      default: 1
      label: 'Custom # Increment'

    next:
      type: Number
      default: 1000
      label: 'Next #'
  ]

  legal:
    notice:
      type: String
      label: 'Legal Notice'

    terms:
      type: String
      label: 'Legal Terms'

    regNo:
      type: String
      label: 'Registration #'

  taxes: [
    tax:
      type: mongoose.Schema.ObjectId
      ref: 'Contact'
      label: 'Tax'

    regNo:
      type: String
      label: 'Registration #'
  ]

  currency:
    type: String
    enum: ['CAD', 'USD']
    default: 'USD'
    required: true
,
  label: 'Company'
)

CompanySchema.plugin(address)
CompanySchema.plugin(picture)
CompanySchema.plugin(timestamps)

CompanySchema.method(

  next_number: (name) ->
    name = name.toLowerCase()
    for n in @numbering
      if n.name == name
        nx = n.next
        n.next += n.increment
        @save()
        return nx
    return 0

)

module.exports = mongoose.model('Company', CompanySchema)
