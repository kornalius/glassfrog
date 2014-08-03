mongoose = require("../app").mongoose
timestamps = require('mongoose-time')()
Currency = require('mongoose-currency')
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

    projects:
      type: Number
      required: true
      label: 'Max. number of projects'

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
    type: Currency
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

  canCreateRecord: (model, cb) ->
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

)

module.exports = mongoose.model('Plan', PlanSchema)

setTimeout( ->
  data = [
    name: 'Free'
    desc: ''
    price: 0.00
    limits:
      records: 100
      projects: 1
      schemas: 2
      fields: 10
  ,
    name: 'Home'
    desc: ''
    price: 9.99
    limits:
      records: 10000
      projects: 5
      schemas: 5
      fields: 25
  ,
    name: 'Freelancer'
    desc: ''
    price: 19.99
    limits:
      records: 100000
      projects: 10
      schemas: 10
      fields: 100
      options: 'l'
  ,
    name: 'Startup'
    desc: ''
    price: 49.99
    limits:
      records: 100000
      projects: 10
      schemas: 10
      fields: 100
      options: 'c'
  ,
    name: 'Business'
    desc: ''
    price: 99.99
    limits:
      records: 1000000
      projects: -1
      schemas: 25
      fields: -1
      options: 'cd'
  ,
    name: 'Unlimited'
    desc: ''
    price: 399.99
    limits:
      records: -1
      projects: -1
      schemas: -1
      fields: -1
      options: 'cde'
  ]

  N = mongoose.model('Plan')

  N.remove({}, (err) ->
    for p in data
      N.create({name: p.name, desc: p.desc, price: p.price, limits: p.limits, frequency: (if p.frequency? then p.frequency else 'monthly')}, (err) ->
      )
  )
, 1000)
