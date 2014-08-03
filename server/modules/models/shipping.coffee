app = require("../../app")
mongoose = require("../../app").mongoose
timestamps = require('mongoose-time')()
async = require('async')
endpoints = require('../../endpoints')

address = require('../../mongoose_plugins/mongoose-address')
picture = require('../../mongoose_plugins/mongoose-picture')

ShippingSchema = mongoose.Schema(
  name:
    type: String
    index: true
    trim: true
    required: true
    label: 'Shipping Service Name'

  destination_type:
    type: String
    index: true
    required: true
    enum: ['Residential', 'Commercial']
    default: 'Commercial'
    label: 'Destination Type'

  package_types:
    type: [String]
    enum: ['Letter', 'Envelop', 'Box', 'Box (Plastic)', 'Box (Wood)', 'Box (Glass)', 'Box (Metal)', 'Skid', 'Tube']
    default: ['Letter', 'Envelop', 'Box']
    label: 'Allowed Package types'

  pickup_method:
    type: String
    required: true
    enum: ['Pickup', 'Air', 'LetterBox', 'Counter']
    default: 'Pickup'

  specs: [
    name:
      type: String
      enum: ['Weight', 'Width', 'Height', 'Time', 'Value']
      label: 'Range name'

    unit:
      type: String
      enum: ['ml', 'oz', 'lb', 'kg', 't', 'mm', 'cm', 'in', 'ft', 'ea', 'case', 'basket', 'ctn', 'pkg', 'minute', 'hour', 'day', 'month', 'year']
      label: 'Unit Of Measure'

    min:
      type: Number
      label: 'Min. Unit Value'

    max:
      type: Number
      default: -1
      label: 'Max. Unit Value'

    discount:
      type: Currency
      default: 0
      label: 'Discount'

    discount_pct:
      type: Number
      default: 0
      label: 'Extra Handling Fee Percent'

    fee:
      type: Currency
      default: 0
      label: 'Discount'

    fee_pct:
      type: Number
      default: 0
      label: 'Extra Handling Fee Percent'
  ]
,
  label: 'Shipping Services'
)

ShippingSchema.plugin(address)
ShippingSchema.plugin(picture)
ShippingSchema.plugin(timestamps)

ShippingSchema.method(

  inRange: (amount, unit, weight, time, width, height) ->
    unit = unit.toLowerCase()
    for r in @specs
      if r.name == 'weight' and weight? and unit? and r.unit == unit and weight in [r.min..r.max]
        return r
      else if r.name == 'width' and width? and unit? and r.unit == unit and width in [r.min..r.max]
        return r
      else if r.name == 'height' and height? and unit? and r.unit == unit and height in [r.min..r.max]
        return r
      else if r.name == 'time' and time? and unit? and r.unit == unit and time in [r.min..r.max]
        return r
    return null

)

ShippingSchema.static(

  findBestServices: (user, amount, unit, weight, time, width, height, cb) ->
    @model.find({}, (err, services) ->
      l = []
      if services
        for s in services
          if s.inRange(amount, unit, weight, time, width, height)
            l.push(s)
      cb(l) if cb
    )

)

module.exports = mongoose.model('Shipping', ShippingSchema)
