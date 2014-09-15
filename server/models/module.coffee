app = require("../app")
mongoose = require("mongoose")
timestamps = require('mongoose-time')()
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
    required: true
    label: 'Name'

  desc:
    type: String
    label: 'Description'

  icon:
    type: String
    label: 'Icon'

  color:
    type: String
    label: 'Color'

  share:
    type: mongoose.Schema.ObjectId
    ref: 'Share'
    label: 'Share'
    populate: true

  extra:
    type: String
    label: 'Extra Info'

  version:
    type: mongooseVersion
    default: '0.1.0a'
    label: 'Version'
,
  label: 'Modules'
)

ModuleSchema.plugin(timestamps)
ModuleSchema.plugin(ownable)

ModuleSchema.method(
  sanitizedId: () ->
    require('sanitize-filename')(@_id.toString())

  modulePath: (user) ->
    user.modulesPath() + '/' + @sanitizedId() + '.js'

  isBuilt: (user) ->
    require('fs').existsSync(@modulePath(user))

  build: (syntax, user) ->
    fs = require('fs')

    mpath = app.modulesPath
    if !fs.existsSync(mpath)
      fs.mkdirSync(mpath)

    upath = user.modulesPath()
    if !fs.existsSync(upath)
      fs.mkdirSync(upath)

    path = @modulePath(user)
    if fs.existsSync(path)
      fs.unlinkSync(path)

    if !syntax.error
      fs.writeFileSync(path, syntax.code)
)

ModuleSchema.static(
  findByNameOrDesc: (n, cb) ->
    mongoose.model('Module').find({$or: [{name: {$regex: new RegExp(n, "i")}}, {desc: {$regex: new RegExp(n, "i")}}]}, (err, c) ->
      cb(c) if cb
    )

  modules: (user_id, cb) ->
    mongoose.model('User').findById(user_id, (err, user) ->
      if user
        user.modules((modules) ->
          cb(modules) if cb
        )
    )

  allModules: (cb) ->
    mongoose.model('Module').find({}, (err, modules) ->
      r = []
      if modules
        for m in modules
          mm = m.toObject()
          Module.make(mm)
          r.push(mm)
      VCGlobal.modules.rows = r
      cb(r) if cb
    )
)

module.exports = mongoose.model('Module', ModuleSchema)

module.exports.deleteBuiltModules = (user) ->
  fs = require('fs')
  path = user.modulesPath()
  if fs.existsSync(path)
    fs.readdirSync(path).forEach((file) ->
      fs.unlinkSync(path + '/' + file)
    )

module.exports.rebuildModules = (user, cb) ->
  VCModule = require("../vc_module")
  @deleteBuiltModules(user)
  user.modules(true, (modules) ->
    done = []
    for m in modules
      mm = m.toObject()
      VCModule.make(mm)
      syntax = mm.generateCode(false, user)
      m.build(syntax, user)
      if !syntax.error
        done.push(m)
    cb(done) if cb
  )

setTimeout( ->
  data = [
    name: 'Travel Reservation'
    desc: 'Make flight reservations a breeze with this amazing module'
    icon: 'cic-airplane'
    color: 'lightblue'
    extra:
      root:
        name: 'Root'
        component: 'root'
        nodes: [
          name: 'Config'
          component: 'Module.Config'
        ,
          name: 'Plane'
          component: 'Schema'
          nodes: [
            name: 'FlightNo'
            component: 'Field'
            nodes: [
              component: 'Field.Text'
            ,
              component: 'Font.Bold'
            ,
              component: 'LightBlue'
            ]
          ,
            name: 'SeatNo'
            component: 'Field'
            nodes: [
              component: 'Field.Percent'
            ,
              component: 'Field.Round'
              args:
                'round': 2
            ]
          ,
            name: 'myMethod'
            component: 'Schema.Method'
            nodes: [
              name: 'alert'
              component: 'alert'
              args:
                'Message': 'Very Nice!'
            ]
          ]
        ]
  ,
    name: 'Briefcases organizer'
    desc: 'Organizes all your briefcases to fit the most heroin possible ;)'
    icon: 'cic-suitcase6'
    color: 'darkorange'
    extra:
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
        owner = users[0]._id.toString()

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
          if err
            console.log err
        )
    )
  )

, 1000)
