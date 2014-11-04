app = require("../../app")
mongoose = require("mongoose")
timestamps = require('mongoose-time')()
async = require('async')
endpoints = require('../../endpoints')

name = require('../../mongoose_plugins/mongoose-name')
address = require('../../mongoose_plugins/mongoose-address')
picture = require('../../mongoose_plugins/mongoose-picture')
shipping = require('../../mongoose_plugins/mongoose-shipping')
unit = require('../../mongoose_plugins/mongoose-unit')
history = require('../../mongoose_plugins/mongoose-history')

ItemSchema = mongoose.Schema(
  itemNo:
    type: String
    required: true
    index: true
    trim: true
    label: 'Item #'

  type:
    type: String
    enum: ['Product', 'Service', 'Virtual']
    default: 'Product'
    required: true
    label: 'Type'

  upcNo:
    type: String
    index: true
    unique: true
    trim: true
    label: 'Upc #'

  skuNo:
    type: String
    index: true
    trim: true
    label: 'Sku #'

  desc:
    type: String
    trim: true
    label: 'Description'

  color:
    type: String
    trim: true
    label: 'Color'

  qty:
    type: Number
    default: 0
    label: 'Qty'

  price:
    type: mongooseCurrency
    default: 0
    required: true
    label: 'Price'

  cost:
    type: mongooseCurrency
    default: 0
    required: true
    label: 'Cost'

  status:
    type: String
    enum: ['Active', 'Inactive']
    default: 'Active'
    required: true
    label: 'Status'
,
  label: 'Items'
)

ItemSchema.plugin(picture)
ItemSchema.plugin(unit)
ItemSchema.plugin(history)
ItemSchema.plugin(timestamps)

ItemSchema.virtual('isActive', ->
  @status == 'Active'
)

ItemSchema.virtual('isProduct', ->
  @type == 'Product'
)

ItemSchema.virtual('isService', ->
  @type == 'Service'
)

ItemSchema.virtual('isVirtual', ->
  @type == 'Virtual'
)

ItemSchema.method(

#  bins: (cb) ->
#    app.model('Location').findInBins(@id, (err, bins) ->
#      if bins
#        cb(bins) if cb
#    )

#  qty: (cb) ->
#    @bins((bins) ->
#      if !bins or bins.length == 0
#        cb(@qty) if cb
#      else
#        q = 0
#        for l in bins
#          q += l.qty
#        cb(q) if cb
#    )

  qty_available: (cb) ->
    @qty_reserved((reserved) ->
      q = @qty
      if reserved?
        q -= reserved
      cb(q) if cb
    )

  qty_reserved: (cb) ->
    @reserved_lines((lines) ->
      q = 0
      if lines
        for l in lines
          q += l.qty
      cb(q) if cb
    )

  reserved_lines: (cb) ->
    app.model('Transaction', (m) ->
      if m
        m.find(
          type: 'Quote'
          status:
            $not:
              $in: ['Invoiced', 'Cancelled', 'Rejected']
        , (err, sales) ->
          pl = []
          if sales
            for s in sales
              for l in s._lines
                if l.qty
                  pl.push(l)
          cb(pl) if cb
        )
      else
        cb(null) if cb
    )

  qty_sold: (cb) ->
    @sold_lines((lines) ->
      q = 0
      if lines
        for l in lines
          q += l.qty
      cb(q) if cb
    )

  sold_lines: (cb) ->
    app.model('Transaction', (m) ->
      if m
        m.find(
          type: 'Invoice'
          status:
            $not:
              $in: ['Cancelled']
        , (err, sales) ->
          pl = []
          if sales
            for s in sales
              for l in s._lines
                if l.qty
                  pl.push(l)
          cb(pl) if cb
        )
      else
        cb(null) if cb
    )

  qty_shipped: (cb) ->
    @shipped_lines((lines)->
      q = 0
      if lines
        for l in lines
          q += l.qty
      cb(q) if cb
    )

  shipped_lines: (cb) ->
    app.model('Transaction', (m) ->
      if m
        m.find(
          type: 'Invoice'
          status:
            $not:
              $in: ['Cancelled']
        , (err, sales) ->
          pl = []
          if sales
            for s in sales
              for l in s._lines
                if l.qty
                  pl.push(l)
          cb(pl) if cb
        )
      else
        cb(null) if cb
    )

  qty_ordered: (cb) ->
    @ordered_lines((lines) ->
      q = 0
      if lines
        for l in lines
          q += l.qty
      cb(q) if cb
    )

  ordered_lines: (cb) ->
    app.model('Transaction', (m) ->
      if m
        m.find(
          item: @id
          type: 'Purchase'
          status:
            $not:
              $in: ['Cancelled']
        , (err, purchases) ->
          pl = []
          if purchases
            for s in purchases
              for l in s._lines
                if l.received_full
                  pl.push(l)
          cb(pl) if cb
        )
      else
        cb(null) if cb
    )

  qty_on_order: (cb) ->
    @on_order_lines((lines) ->
      q = 0
      if lines
        for l in lines
          q += (l.qty - l.qty_received)
      cb(q) if cb
    )

  on_order_lines: (cb) ->
    app.model('Transaction', (m) ->
      if m
        m.find(
          item: @id
          type: 'Purchase'
          status:
            $not:
              $in: ['Cancelled']
        , (err, purchases) ->
          pl = []
          if purchases
            for s in purchases
              for l in s._lines
                if !l.received_full
                  pl.push(l)
          cb(pl) if cb
        )
      else
        cb(pl) if cb
    )
)

module.exports = mongoose.model('Item', ItemSchema)
