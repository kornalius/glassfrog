app = require("../../app")
mongoose = require("mongoose")
timestamps = require('mongoose-time')()
async = require('async')
endpoints = require('../../endpoints')

shipping = require('../../mongoose_plugins/mongoose-shipping')
dates = require('../../mongoose_plugins/mongoose-dates')
disc_fee = require('../../mongoose_plugins/mongoose-discount-fee')
history = require('../../mongoose_plugins/mongoose-history')
Tax = require('./tax')

TransactionLineSchema = mongoose.Schema(
  u_no:
    type: Number
    default: 1
    required: true
    index: true

  status:
    type: String
    enum: ['Approved', 'Rejected', 'Cancelled', 'New', 'Sent', 'Printed', 'Invoiced', 'Paid Full', 'Paid Partial', 'Shipped Full', 'Shipped Partial']
    default: 'New'
    required: true
    label: 'Status'

  invoice:
    type: mongoose.Schema.ObjectId
    ref: 'Transaction'
    label: 'Reference Invoice'

  item:
    type: mongoose.Schema.ObjectId
    ref: 'Item'
    populate: true
    label: 'Item'

  desc:
    type: String
    label: 'Description'

  qty:
    type: Number
    default: 1
    required: true

  qty_shipped:
    type: Number
    default: 0

  price:
    type: Currency
    default: 0
    required: true
    label: 'Price'

  cost:
    type: Currency
    default: 0
    required: true
    label: 'Cost'

  sub_total:
    type: Currency
    label: 'Sub-Total'

  taxes:
    type: [Tax]
    label: 'Taxes'

  total:
    type: Currency
    label: 'Total'
,
  label: 'Transaction Lines'
)

TransactionLineSchema.plugin(dates)
TransactionLineSchema.plugin(disc_fee)
TransactionLineSchema.plugin(history)
TransactionLineSchema.plugin(timestamps)

TransactionLineSchema.pre('save', (next) ->
  if @isModified('item')
    @desc = @item.desc
    @price = @item.price
    @cost = @item.cost

  if @isModified('qty')
    if @qty < 0
      @qty = 0

  if @isModified('qty_shipped')
    if @qty_shipped > @qty
      @qty_shipped = @qty
    if @qty_shipped < 0
      @qty_shipped = 0

  if @isModified('qty_received')
    if @qty_received > @qty
      @qty_received = @qty
    if @qty_received < 0
      @qty_received = 0

  if !@isModified('sub_total') and !@isModified('total')
    @calculateTotals()

  next()
)

TransactionLineSchema.virtual("isShippedFull").get(->
  @qty - @qty_shipped == 0
)

TransactionLineSchema.virtual("isShippedPartial").get(->
  @qty - @qty_shipped > 0
)

TransactionLineSchema.virtual("qty_to_ship").get(->
  @qty - @qty_shipped
)

TransactionLineSchema.virtual("qty_to_receive").get(->
  @qty_to_ship - @qty_received
)

TransactionLineSchema.virtual("isReceivedFull").get(->
  @qty_to_ship - @qty_received == 0
)

TransactionLineSchema.virtual("isReceivedPartial").get(->
  @qty_to_ship - @qty_received > 0
)

TransactionLineSchema.static(

  newLine: (cb) ->
    that = @
    app.model('Company').findOne({}, (err, comp) ->
      if comp
        nx = comp.next_number('')
        that.model.create({ u_no: nx, type: 'Project' }, (err, result) ->
          cb(result) if cb
        )
    )

)

TransactionLineSchema.method(

  calculateTotals: () ->
    @sub_total = @price * @qty

    t = @sub_total + @discountsFees(@sub_total)

    if @taxes
      for tx in @taxes
        t += @apply(tx.tax, tx.percent)

    @total = t

  ship: (_qty) ->
    if @isShippedPartial
      if @qty_shipped + _qty > @qty
        @qty_shipped = @qty
      else
        @qty_shipped += _qty
      @save()

  receive: (_qty) ->
    if @isReceivedPartial
      if @qty_received + _qty > @qty
        @qty_received = @qty
      else
        @qty_received += _qty
      @save()

  cancel: (reason, cb) ->

  reject: (reason, cb) ->

  invoice: (cb) ->

  approve: (cb) ->

)

module.exports = mongoose.model('TransactionLine', TransactionLineSchema)
