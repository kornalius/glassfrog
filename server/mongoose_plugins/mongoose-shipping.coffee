User = require('../../models/user')
moment = require('moment')

module.exports = ((schema, options) ->
  schema.add(
    shipping:
      service:
        type: mongoose.Schema.ObjectId
        ref: 'Shipping'
        populate: true
        label: 'Shipping Service'

      package_type:
        type: String
        enum: ['Envelop', 'Box', 'Skid']
        default: 'Box'
        label: 'Package type'

      handling_fee:
        type: Number
        default: 0
        label: 'Handling Fee'

      estimated_arrival:
        type: Date
        label: 'Estimated Arrival Date'
  )

)
