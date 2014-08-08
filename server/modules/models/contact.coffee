app = require("../../app")
mongoose = require("mongoose")
timestamps = require('mongoose-time')()
async = require('async')
endpoints = require('../../endpoints')

person = require('../../mongoose_plugins/mongoose-person')
address = require('../../mongoose_plugins/mongoose-address')
dates = require('../../mongoose_plugins/mongoose-dates')
picture = require('../../mongoose_plugins/mongoose-picture')
shipping = require('../../mongoose_plugins/mongoose-shipping')

ContactSchema = mongoose.Schema(
  company_name:
    type: String
    trim: true
    label: 'Company Name'

  type:
    type: String
    enum: ['Employe', 'Customer', 'Supplier']
    default: 'Customer'
    required: true
    label: 'Type'

  status:
    type: String
    enum: ['Active', 'Inactive']
    default: 'Active'
    required: true
    label: 'Status'

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
  label: 'Contacts'
)

ContactSchema.plugin(person)
ContactSchema.plugin(address)
ContactSchema.plugin(picture)
ContactSchema.plugin(dates)
ContactSchema.plugin(shipping)
ContactSchema.plugin(timestamps)

ContactSchema.virtual('isCustomer').get(->
  @type == 'Customer'
)

ContactSchema.virtual('isSupplier').get(->
  @type == 'Supplier'
)

ContactSchema.virtual('isCompany').get(->
  @company_name?
)

module.exports = mongoose.model('Contact', ContactSchema)
