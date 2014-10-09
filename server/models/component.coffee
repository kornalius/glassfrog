app = require("../app")
mongoose = require("mongoose")
timestamps = require('mongoose-time')()
fs = require('fs');
async = require('async')
safejson = require('safejson')
filterPlugin = require('../mongoose_plugins/mongoose-filter')

#VCGlobal = require("../vc_global")
#Component = require("../vc_component")
#Node = require("../vc_node")
#Module = require("../vc_module")

ComponentSchema = mongoose.Schema(
  name:
    type: String
    index: true
    trim: true
    required: true
    label: 'Name'
    readOnly: true

  desc:
    type: String
    label: 'Description'
    readOnly: true

  extra:
    type: String
    label: 'Extra Info'
    readOnly: true

  version:
    type: mongooseVersion
    default: '0.1.0a'
    label: 'Version'
    readOnly: true
,
  label: 'Components'
  readOnly: true
)

ComponentSchema.plugin(timestamps)
ComponentSchema.plugin(filterPlugin)

ComponentSchema.method(
)

ComponentSchema.static(
  findByNameOrDesc: (n, cb) ->
    mongoose.model('Component').find({$or: [{name: {$regex: new RegExp(n, "i")}}, {desc: {$regex: new RegExp(n, "i")}}]}, (err, c) ->
      cb(c) if cb
    )

#  components: (cb) ->
#    console.log "Loading components..."
#    VCGlobal.components = {rows:[]}
#    mongoose.model('Component').find({}, (err, components) ->
#      VCGlobal.components.rows = components
#      for c in components
#        Component.make(c)
#      console.log "Loaded {0} components ({1})".format(components.length, VCGlobal.components.rows.length)
#      cb() if cb
#    )

#  components: (cb) ->
#    if _components
#      cb(_components) if cb
#    else
#      mongoose.model('Component').find({}, (err, components) ->
#        require(['../../scripts/component_data'], (Component_Data) ->
#          for c in components
#            Component_Data.makeNode(c)
#          _components = components
#          cb(components) if cb
#        )
#      )
)

module.exports = mongoose.model('Component', ComponentSchema)

setTimeout( ->
  data = []

  data = data.concat(require('../components/root'))
  data = data.concat(require('../components/literal'))
  data = data.concat(require('../components/statement'))

  data = data.concat(require('../components/database'))
  data = data.concat(require('../components/schema'))
  data = data.concat(require('../components/field'))
  data = data.concat(require('../components/query'))

  data = data.concat(require('../components/server'))

  data = data.concat(require('../components/ui/ui'))
  data = data.concat(require('../components/ui/control'))
  data = data.concat(require('../components/ui/menu'))
  data = data.concat(require('../components/ui/table'))
  data = data.concat(require('../components/ui/dashboard'))
  data = data.concat(require('../components/ui/chart'))

  data = data.concat(require('../components/ui/decorators/decorator'))
  data = data.concat(require('../components/ui/decorators/color'))
  data = data.concat(require('../components/ui/decorators/font'))

  C = mongoose.model('Component')

  properConvert = (f) ->
    if f.extra
      if f.extra.accepts
        naccepts = []
        for n in f.extra.accepts
          ca = { component: null, multi: false, unique: false, reject: false, strict: false, inherited: false }

          if n.startsWith('!')
            ca.reject = true
            n = n.substr(1)

          if n.startsWith('=')
            ca.strict = true
            n = n.substr(1)

          if n.endsWith('+')
            ca.multi = true
            ca.unique = true
            n = n.substr(0, n.length - 1)

          if n.endsWith('+')
            ca.unique = false
            n = n.substr(0, n.length - 1)

          if n == '@'
            ca.inherited = true
            n = ''

          ca.component = n
          naccepts.push(ca)
        f.extra.accepts = naccepts

      if f.extra.code
        if type(f.extra.code) != 'string'
          nc = {}
          for k of f.extra.code
            nc[k] = f.extra.code[k].toString()
          f.extra.code = nc
        else if fs.existsSync('_server/component_scripts/' + f.extra.code)
          f.extra.code = fs.readFileSync('_server/component_scripts/' + f.extra.code)
        else
          f.extra.code = null

      jsonToString(f.extra, (err, json) ->
        if !err
          f.extra = json
        else
          throw err
      )

  C.remove({}, (err) ->

    dd = data.map((d) ->
      f = _.clone(d)

      properConvert(f)

      return f
    )

    C.create(dd, (err) ->
      if err
        console.log err
      VCGlobal = require('../vc_global')
      VCGlobal.loadComponents()
    )
  )
, 500)
