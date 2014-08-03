app = require("../../app")
mongoose = require("../../app").mongoose
timestamps = require('mongoose-time')()
async = require('async')
endpoints = require('../../endpoints')

TaxSchema = mongoose.Schema(
  name:
    type: String
    unique: true
    index: true
    trim: true
    required: true
    label: 'Name'

  order:
    type: Number
    default: 0
    label: 'Apply Order'

  percent:
    type: Number
    default: 0
    required: true
    label: '%'

  compound:
    type: Boolean
    default: false
    label: 'Compound ?'
,
  label: 'Taxes'
)

TaxSchema.plugin(timestamps)

TaxSchema.method(

  apply: (amount, force_pct) ->
    return amount * ((if force_pct then force_pct else @percent) / 100)

  applyAll: (amount, force_pct) ->
    a = amount
    tx = 0
    for t in @taxes
      if t.compound
        a += tx
      tx += @apply(t, a, force_pct)
    return tx

)

module.exports = mongoose.model('Tax', TaxSchema)
