app = require("../../app")
mongoose = require("mongoose")
timestamps = require('mongoose-time')()
async = require('async')
endpoints = require('../../endpoints')

payment = require('../../mongoose_plugins/mongoose-payment')
shipping = require('../../mongoose_plugins/mongoose-shipping')
dates = require('../../mongoose_plugins/mongoose-dates')
disc_fee = require('../../mongoose_plugins/mongoose-discount-fee')
history = require('../../mongoose_plugins/mongoose-history')

Tax = require('./tax')
TransactionLine = require('./transaction-line')
Contact = require('./contact')

TransactionSchema = mongoose.Schema(
  u_no:
    type: Number
    default: 1
    required: true
    index: true

  ship_to:
    type: [Contact]
    label: 'Ship To'

  bill_to:
    type: [Contact]
    label: 'Bill To'

  ship_from:
    type: [Contact]
    label: 'Ship From'

  transactionRefNo:
    type: mongoose.Schema.ObjectId
    ref: 'Transaction'
    label: 'Reference Transaction'

  type:
    type: String
    enum: ['Quote', 'Invoice', 'Purchase', 'Bill Of Lading', 'Payment', 'Project']
    default: 'Quote'
    required: true
    label: 'Type'

  status:
    type: String
    enum: ['Approved', 'Rejected', 'Cancelled', 'New', 'Sent', 'Printed', 'Invoiced', 'Paid Full', 'Paid Partial', 'Shipped Full', 'Shipped Partial']
    default: 'New'
    required: true
    label: 'Status'

  refNo:
    type: String
    label: 'Ref. #'

  lines:
    type: [TransactionLine]
    default: []
    index: true
    populate: true
    label: 'Transaction Lines'

  sub_total:
    type: mongooseCurrency
    label: 'Sub-Total'

  taxes:
    type: [Tax]
    label: 'Taxes'

  total:
    type: mongooseCurrency
    label: 'Total'

,
  label: 'Transactions'
)

TransactionSchema.plugin(shipping)
TransactionSchema.plugin(payment)
TransactionSchema.plugin(shipping)
TransactionSchema.plugin(dates)
TransactionSchema.plugin(disc_fee)
TransactionSchema.plugin(timestamps)

TransactionSchema.pre('save', (next) ->
#  if @isModified('order_date') or @isModified('ship_date') or @isModified('cancel_date') or @isModified('ship_before_date') or @isModified('ship_not_before_date')
#    if @order_date > @ship_date
#      @order_date = @ship_date

#    if @ship_date < @order_date
#      @ship_date = @order_date

#    if @ship_date > @ship_before_date
#      @ship_date = @ship_before_date

#    if @ship_date < @ship_not_before_date
#      @ship_date = @ship_not_before_date

#    if @ship_not_before_date < @order_date
#      @ship_not_before_date = @order_date

#    if @ship_not_before_date > @cancel_date
#      @ship_not_before_date = @cancel_date

#    if @ship_before_date > @ship_not_before_date
#      @ship_before_date = @ship_not_before_date

#    if @ship_before_date > @cancel_date
#      @ship_before_date = @cancel_date

#    if @cancel_date < @ship_before_date
#      @cancel_date = @ship_before_date

  next()
)

TransactionSchema.virtual('isSale').get(->
  @type in ['Quote', 'Invoice']
)

TransactionSchema.virtual('isPurchase').get(->
  @type == 'Purchase'
)

TransactionSchema.virtual('isQuote').get(->
  @type == 'Quote'
)

TransactionSchema.virtual('isInvoice').get(->
  @type == 'Invoice'
)

TransactionSchema.virtual('isBillOfLading').get(->
  @type == 'Bill Of Lading'
)

TransactionSchema.virtual('isPayment').get(->
  @type == 'Payment'
)

TransactionSchema.virtual('isProject').get(->
  @type == 'Project'
)

TransactionSchema.static(

  newProject: (cb) ->
    that = @
    app.model('Company', (m) ->
      if m
        m.findOne({}, (err, comp) ->
          if comp
            nx = comp.next_number('Project')
            that.model.create({ u_no: nx, type: 'Project' }, (err, result) ->
              cb(result) if cb
            )
          else
            cb(null) if cb
        )
      else
        cb(null) if cb
    )

  newQuote: (cb) ->
    that = @
    app.model('Company', (m) ->
      if m
        m.findOne({}, (err, comp) ->
          if comp
            nx = comp.next_number('Quote')
            that.model.create({ u_no: nx, type: 'Quote' }, (err, result) ->
              cb(result) if cb
            )
          else
            cb(null) if cb
        )
      else
        cb(null) if cb
    )

  newInvoice: (cb) ->
    that = @
    app.model('Company', (m) ->
      if m
        m.findOne({}, (err, comp) ->
          if comp
            nx = comp.next_number('Invoice')
            that.model.create({ u_no: nx, type: 'Invoice' }, (err, result) ->
              cb(result) if cb
            )
          else
            cb(null) if cb
        )
      else
        cb(null) if cb
    )

  newPurchase: (cb) ->
    that = @
    app.model('Company', (m) ->
      if m
        m.findOne({}, (err, comp) ->
          if comp
            nx = comp.next_number('Purchase')
            that.model.create({ u_no: nx, type: 'Purchase' }, (err, result) ->
              cb(result) if cb
            )
          else
            cb(null) if cb
        )
      else
        cb(null) if cb
    )

  newPayment: (cb) ->
    that = @
    app.model('Company', (m) ->
      if m
        m.findOne({}, (err, comp) ->
          if comp
            nx = comp.next_number('Payment')
            that.model.create({ u_no: nx, type: 'Payment' }, (err, result) ->
              cb(result) if cb
            )
          else
            cb(null) if cb
        )
      else
        cb(null) if cb
    )
)

TransactionSchema.method(

  calculateTotals: (cb) ->
    that = @
    @populate('lines', (err, lines) ->
      t = 0
      if lines
        for l in lines
          t += l.calculate_totals()
      that.sub_total = t

      t += that.discountsFees(t)

      @populate('taxes', (err, taxes) ->
        if taxes
          for tx in taxes
            t += tx.tax.apply(t, tx.percent)
        that.total = t
        cb(t) if cb
      )
    )

  ship: (cb) ->

  cancel: (reason, cb) ->

  reject: (reason, cb) ->

  invoice: (cb) ->

  approve: (cb) ->

  send: (cb) ->

)

module.exports = mongoose.model('Transaction', TransactionSchema)
