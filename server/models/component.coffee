app = require("../app")
mongoose = require("mongoose")
timestamps = require('mongoose-time')()
fs = require('fs');
async = require('async')

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

if true
  setTimeout( ->
    data = []

    fs = require("fs")
    path = require("path")

    components_path_root = path.resolve('_server/components')

    files = []
    addComponents = (dir) ->
      fs.readdirSync(components_path_root + '/' + dir).forEach((file) ->
        if fs.statSync(components_path_root + '/' + dir + file).isDirectory()
          addComponents(dir + file + '/')
        else
          ext = path.extname(file)
          if ext == '.js'
            files.push(dir + file.replace(/(\.js)$/, ''))
      )

    addComponents('')

    for f in ['root', 'literal', 'statement']
      i = files.indexOf(f)
      if i != -1
        files.splice(i, 1)
      console.log "Adding components {0}...".format(f)
      data = data.concat(require(components_path_root + '/' + f))

    for f in files
      console.log "Adding components {0}...".format(f)
      data = data.concat(require(components_path_root + '/' + f))

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

        if f.extra.args
          for k of f.extra.args
            if f.extra.args[k]
              for pk of f.extra.args[k]
                if type(f.extra.args[k][pk]) == 'function'
                  f.extra.args[k][pk] = f.extra.args[k][pk].toString()

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
