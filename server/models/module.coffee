app = require("../app")
mongoose = require("../app").mongoose
timestamps = require('mongoose-time')()
version = require('../mongoose_plugins/mongoose-version')
ownable = require('mongoose-ownable')
async = require('async')
safejson = require('safejson')

VCGlobal = require("../vc_global")
Module = require("../vc_module")
Node = require("../vc_node")
Component = require("../vc_component")

ModuleSchema = mongoose.Schema(
  name:
    type: String
    label: 'Name'

  desc:
    type: String
    label: 'Description'

  share:
    type: mongoose.Schema.ObjectId
    ref: 'Share'
    label: 'Share'
    populate: true

  extra:
    type: String
    label: 'Extra Info'
,
  label: 'Modules'
)

ModuleSchema.plugin(timestamps)
ModuleSchema.plugin(version)
ModuleSchema.plugin(ownable)

ModuleSchema.method(
)

ModuleSchema.static(
  findByNameOrDesc: (n, cb) ->
    mongoose.model('Module').find({$or: [{name: {$regex: new RegExp(n, "i")}}, {desc: {$regex: new RegExp(n, "i")}}]}, (err, c) ->
      cb(c) if cb
    )

  modules: (userId, cb) ->
    mongoose.model('User').findById(userId, (err, user) ->
      user.modules((modules) ->
        VCGlobal.modules.rows = modules
        for m in modules
          Module.make(m)
        cb(modules) if cb
      )
    )

  allModules: (cb) ->
    mongoose.model('Module').find({}, (err, modules) ->
      VCGlobal.modules.rows = modules
      for m in modules
        Module.make(m)
      cb(modules) if cb
    )
)

module.exports = mongoose.model('Module', ModuleSchema)

setTimeout( ->
  data = [
    name: 'Travel Reservation'
    desc: 'Make flight reservations a breeze with this amazing module'
    extra:
      icon: 'airplane'
      color: 'lightblue'
      root:
        name: 'Root'
        component: 'root'
        nodes: [
          name: 'Plane'
          component: 'Schema'
          nodes: [
            name: 'FlightNo'
            component: 'Field'
            nodes: [
              component: 'Text'
            ,
              component: 'Bold'
            ,
              component: 'LightBlue'
            ]
          ,
            name: 'myMethod'
            component: 'Method'
            nodes: [
              name: 'alert'
              component: 'alert'
              args: [
                name: 'Hello'
                component: 'String'
              ,
                name: 'World'
                component: 'String'
              ]
            ]
          ]
        ]
  ,
    name: 'Briefcases organizer'
    desc: 'Organizes all your briefcases to fit the most heroin possible ;)'
    extra:
      icon: 'suitcase6'
      color: 'darkorange'
      root:
        name: 'Root'
        component: 'root'
        nodes: [
          name: 'Briefcase'
          component: 'Schema'
          nodes: [
            name: 'Kg'
            component: 'Field'
            nodes: [
              component: 'Number'
            ]
          ]
        ]
  ,
    name: 'Another Module'
    desc: 'This is my second test module'
    extra:
      root:
        name: 'Root'
        component: 'root'
        nodes: [
        ]
  ]

  M = mongoose.model('Module')

  M.remove({}, (err) ->

    mongoose.model('User').find({}, (err, users) ->
      if users
        owner = users[0].id

        dd = data.map((d) ->
          f = _.clone(d)

          f.name = _.str.classify(f.name)
          f.owner_id = owner

          if f.extra
            safejson.stringify(f.extra, (err, json) ->
              if !err
                f.extra = json
              else
                throw err
            )

          return f
        )

        M.create(dd, (err) ->
        )
    )
  )

, 1000)
