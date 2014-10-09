mongoose = require("mongoose")
timestamps = require('mongoose-time')()
filterPlugin = require('../mongoose_plugins/mongoose-filter')
User = require('./user')

PlanSchema = mongoose.Schema(
  name:
    type: String
    required: true
    label: 'Name'

  desc:
    type: String
    required: true
    label: 'Description'

  limits:
    records:
      type: Number
      required: true
      label: 'Max. number of records per database'

    fieldSize:
      type: Number
      required: true
      label: 'Max. size for a field\'s value'

    modules:
      type: Number
      required: true
      label: 'Max. number of modules'

    schemas:
      type: Number
      required: true
      label: 'Max. number of schemas per project'

    fields:
      type: Number
      required: true
      label: 'Max. number of fields per schema'

    options:
      type: String
      default: ''
      label: 'Various options related to the plan'

  price:
    type: mongooseCurrency
    label: 'Price'

  frequency:
    type: String
    enum: ['monthly', 'yearly']
    default: 'monthly'
    label: 'Frequency'

,
  label: 'Plans'
)

PlanSchema.plugin(timestamps)
PlanSchema.plugin(filterPlugin)

PlanSchema.method(

  hasOption: (s) ->
    @limits.options.indexOf(s) > -1

  canUseOwnCollection: () ->
    @hasOption('l')

  canCreateConnection: () ->
    @hasOption('c')

  canHaveOwnDatabase: () ->
    @hasOption('c') and @hasOption('d')

  canUseExternalConnection: () ->
    @hasOption('c') and @hasOption('d') and @hasOption('e')

  isFreePlan: () ->
    @name == 'Free' and @price == 0

  isBasicPlan: () ->
    @name == 'Basic' and @price != 0

  isDeveloperPlan: () ->
    @name == 'Developer' and @price != 0

  isBusinessPlan: () ->
    @name == 'Business' and @price != 0

  isEnterprisePlan: () ->
    @name == 'Enterprise' and @price != 0

  isPaidPlan: () ->
    !@isFreePlan()

  verifyRecordsLimits: (user, model, rows, cb) ->
    if @limits.records == -1
      cb(true) if cb
    else
      that = @
      mongoose.model(model).count((err, c) ->
        if !err
          cb(c + 1 >= that.limits.records) if cb
        else
          cb(false) if cb
      )

  verifyFieldsLimits: (user, model, cb) ->
    if @limits.fields == -1
      cb(true) if cb
    else
      cb(model) if cb

  verifyFieldsSizeLimits: (user, model, rows, cb) ->
    if @limits.fieldSize == -1
      cb(true) if cb
    else
      that = @
      for r in rows
        for k of r
          try
            j = jsonToString(r[k])
            if j.length > that.limits.fieldSize
              cb(false) if cb
              return
          catch e
            console.log e
      cb(true) if cb

  verifyModulesLimits: (user, cb) ->
    if @limits.modules == -1
      cb(true) if cb
    else
      that = @
      user.modules((modules) ->
        if modules
          cb(modules.length + 1 >= that.limits.modules) if cb
        else
          cb(false) if cb
      )

  verifySchemasLimits: (user, cb) ->
    if @limits.schemas == -1
      cb(true) if cb
    else
      that = @
      user.modules((modules) ->
        if modules
          cb(modules.schemas().length + 1 >= that.limits.schemas) if cb
        else
          cb(false) if cb
      )

  verifyLimits: (user, action, model, rows, cb) ->
    that = @

    if action == 'create'
      that.verifyRecordsLimits(user, action, model, rows, (ok) ->
        if ok
          that.verifyFieldsSizeLimits(user, model, rows, (ok) ->
            cb(ok) if cb
          )
        else
          cb(false) if cb
      )

    else if action == 'write'
      that.verifyFieldsSizeLimits(user, model, rows, (ok) ->
        cb(ok) if cb
      )

    else
      cb(false) if cb
)

module.exports = mongoose.model('Plan', PlanSchema)

setTimeout( ->
  data = [
    name: 'Free'
    desc: 'Free plan'
    price: 0.00
    limits:
      records: 100
      fieldSize: 1024
      modules: 1
      schemas: 2
      fields: 10
  ,
    name: 'Home'
    desc: 'Home plan'
    price: 9.99
    limits:
      records: 10000
      fieldSize: -1
      modules: 5
      schemas: 5
      fields: 25
  ,
    name: 'Freelancer'
    desc: 'Freelancer module'
    price: 19.99
    limits:
      records: 100000
      fieldSize: -1
      modules: 10
      schemas: 10
      fields: 100
      options: 'l'
  ,
    name: 'Startup'
    desc: 'Startup plan'
    price: 49.99
    limits:
      records: 100000
      fieldSize: -1
      modules: 10
      schemas: 10
      fields: 100
      options: 'c'
  ,
    name: 'Business'
    desc: 'Business plan'
    price: 99.99
    limits:
      records: 1000000
      fieldSize: -1
      modules: -1
      schemas: 25
      fields: -1
      options: 'cd'
  ,
    name: 'Unlimited'
    desc: 'Unlimited plan'
    price: 399.99
    limits:
      records: -1
      fieldSize: -1
      modules: -1
      schemas: -1
      fields: -1
      options: 'cde'
  ]

  N = mongoose.model('Plan')

  N.remove({}, (err) ->
    if err
      console.log err
    for p in data
      N.create({name: p.name, desc: p.desc, price: p.price, limits: p.limits, frequency: (if p.frequency? then p.frequency else 'monthly')}, (err) ->
      )
  )
, 1000)
