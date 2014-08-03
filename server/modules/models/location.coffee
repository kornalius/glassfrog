app = require("../../app")
mongoose = require("../../app").mongoose
timestamps = require('mongoose-time')()
async = require('async')
endpoints = require('../../endpoints')

address = require('../../mongoose_plugins/mongoose-address')
picture = require('../../mongoose_plugins/mongoose-picture')
history = require('../../mongoose_plugins/mongoose-history')

LocationSchema = mongoose.Schema(
  name:
    type: String
    required: true
    label: 'Name'

  bins: [
    binNo:
      type: String
      required: true
      label: 'Bin #'

    item:
      type: mongoose.Schema.ObjectId
      ref: 'Item'
      label: 'Item'

    qty:
      type: Number
      default: 0
      label: 'Qty'
  ]
,
  label: 'Location'
)

LocationSchema.plugin(address)
LocationSchema.plugin(picture)
LocationSchema.plugin(history)
LocationSchema.plugin(timestamps)

LocationSchema.static(

  findBins: (itemId, cb) ->
    @model.find({'bins.item': itemId}, (err, bins) ->
      cb(err, bins)
    )
)

module.exports = mongoose.model('Location', LocationSchema)
