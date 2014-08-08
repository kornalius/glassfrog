app = require("../app")
mongoose = require("mongoose")
timestamps = require('mongoose-time')()
Currency = require('mongoose-currency')
Version = require('../mongoose_plugins/mongoose-version')()
fs = require('fs');
async = require('async')
safejson = require('safejson')

VCGlobal = require("../vc_global")
Component = require("../vc_component")
Node = require("../vc_node")
Module = require("../vc_module")

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
    type: Version
    default: '0.1.0a'
    label: 'Version'
    readOnly: true
,
  label: 'Components'
)

ComponentSchema.plugin(timestamps)

ComponentSchema.method(
)

ComponentSchema.static(
  findByNameOrDesc: (n, cb) ->
    mongoose.model('Component').find({$or: [{name: {$regex: new RegExp(n, "i")}}, {desc: {$regex: new RegExp(n, "i")}}]}, (err, c) ->
      cb(c) if cb
    )

  components: (cb) ->
    console.log "Loading components..."
    VCGlobal.components = {rows:[]}
    mongoose.model('Component').find({}, (err, components) ->
      VCGlobal.components.rows = components
      for c in components
        Component.make(c)
      console.log "Loaded {0} components ({1})".format(components.length, VCGlobal.components.rows.length)
      cb() if cb
    )

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

  data = data.concat(require('../components/schema'))
  data = data.concat(require('../components/statement'))
  data = data.concat(require('../components/query'))

  data = data.concat(require('../components/ui/ui'))
  data = data.concat(require('../components/ui/control'))
  data = data.concat(require('../components/ui/menu'))
  data = data.concat(require('../components/ui/table'))
  data = data.concat(require('../components/ui/decorators/decorator'))
  data = data.concat(require('../components/ui/decorators/color'))
  data = data.concat(require('../components/ui/decorators/font'))

  C = mongoose.model('Component')

  properConvert = (f) ->
    if f.extra
      if f.extra.accepts
        naccepts = []
        for n in f.extra.accepts
          ca = { parent: [], component: null}
          ac = n.split(':')
          if ac.length > 1
            for i in [0..ac.length - 2]
              if ac[i]
                ca.parent.push(ac[i])
            n = ac[ac.length - 1]
          ca.component = n
          naccepts.push(ca)
        f.extra.accepts = naccepts

      if f.extra.code
        if typeof f.extra.code != 'string'
          nc = {}
          for k of f.extra.code
            nc[k] = f.extra.code[k].toString()
          f.extra.code = nc
        else if fs.existsSync('_server/component_scripts/' + f.extra.code)
          f.extra.code = fs.readFileSync('_server/component_scripts/' + f.extra.code)
        else
          f.extra.code = null

      safejson.stringify(f.extra, (err, json) ->
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
    )
  )
, 500)
