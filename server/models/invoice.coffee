mongoose = require("mongoose")
timestamps = require('mongoose-time')()
payment = require('../mongoose_plugins/mongoose-payment')
autoIncrement = require('mongoose-auto-increment')
User = require('./user')

InvoiceSchema = mongoose.Schema(
  invoiceNo:
    type: Number
    index: true
    required: true
    readOnly: true
    label: 'Invoice #'

  user:
    type: mongoose.Schema.ObjectId
    ref: 'User'
    required: true
    label: 'User'
    readOnly: true
    populate: true

  plan:
    type: mongoose.Schema.ObjectId
    ref: 'Plan'
    required: true
    label: 'Plan'
    readOnly: true
    populate: true

,
  label: 'Invoices'
)

InvoiceSchema.set('toObject', {virtuals: true})

InvoiceSchema.plugin(timestamps)
InvoiceSchema.plugin(payment)
InvoiceSchema.plugin(autoIncrement.plugin,
  model: 'Invoice'
  field: 'invoiceNo'
  startAt: 0
  incrementBy: 1
)

InvoiceSchema.virtual('amount').get( ->
  @payment.amount
)

InvoiceSchema.static(
  invoice: (user, payment, cb) ->
    if user.payment.kind? or (payment and payment.kind?)
      mongoose.model('Invoice').create({ user: user._id, plan: user.plan, payment: (if payment then payment else user.payment) }, (err, inv) ->
        cb(err, inv) if cb
      )
)

module.exports = mongoose.model('Invoice', InvoiceSchema)
