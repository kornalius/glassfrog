app = require("../app")
mongoose = require("../app").mongoose
timestamps = require('mongoose-time')()
Currency = require('mongoose-currency')
version = require('../mongoose_plugins/mongoose-version')
_ = require('lodash')
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
,
  label: 'Components'
)

ComponentSchema.plugin(timestamps)
ComponentSchema.plugin(version)

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
  data = [
    name: 'Object'
    desc: 'Base object'
    extra:
      options: 'hl'
  ,

    name: 'Root'
    desc: 'Root'
    extra:
      accepts: ['Schema', 'Page', 'Query']
      options: 'hl'
  ,

    name: 'Schema'
    desc: 'Schema definition'
    extra:
      inherit: 'Object'
      icon: 'database'
      accepts: ['Field', 'Method', 'Static']
      default_children: 'Field'
      color: 'darkorange'
#      valueKind: 'Schema'
      properties: [
        name: 'options'
        desc: 'schema options'
        accepts: ['Object']
        type: 'array'
        default: 'default'
      ,
        name: 'numeric value'
        desc: 'second parameter'
        type: 'number'
        default: '0'
      ,
        name: 'is it ok?'
        desc: 'second parameter'
        type: 'boolean'
        default: true
      ]
      code:
        render: (node) ->
          if node
            e = angular.element('#node-label_' + node.id())
            s = if e.attr('style') then e.attr('style') else ""
            if s.indexOf('font-weight') == -1
              e.attr('style', s + 'font-weight: bold; ')

        generate: (node, client) ->
          if client
            s = "schema" + '\n'
            c = node.$data.component
            if node.$data.hasChildren()
              for n in node.$data.childrenOfKind('Field')
                if n.$data.hasClientCode()
                  c = n.$data.component
                  s += n.$data.generate() + '\n'
          else
            model = node.getName().toProperCase()
            schema = model + 'Schema'

            s =
              'var app = require("../app"),\n' +
              'mongoose = require("../app").mongoose,\n' +
              'timestamps = require("mongoose-time")(),\n' +
              'utils = require("../lib/mongoose-utils"),\n' +
              'mongooseEncrypted = require("mongoose-encrypted").loadTypes(mongoose),\n' +
              'encryptedPlugin = mongooseEncrypted.plugins.encryptedPlugin;\n'

            s += schema + ' = mongoose.Schema({\n'

            d = []
            for n in node.childrenOfKind(['Field'])
              d.push(n.generate(node, false))
            s += d.join(',\n') + '\n});\n'

            s += schema + '.plugin(timestamps);\n'
            if node.childrenOfKind('Encrypted', true)
              s += schema + '.plugin(encryptedPlugin);\n'

            s += schema + '.method({\n'
            s += '});'

            s += schema + '.static({\n'
            s += '});'

            s += 'module.exports = mongoose.model(' + model + ',' + schema + ');'

          return s

  ,

    name: 'Field'
    desc: 'Field definition'
    extra:
      inherit: 'Object'
      icon: 'uniF6CA'
      color: 'pink'
      properties: [
        name: 'type'
        desc: 'field type'
        accepts: ['Object']
        type: 'select'
        enum: '#Type'
      ,
        name: 'attributes'
        desc: 'field attributes'
        accepts: ['Attribute']
        type: 'array'
      ,
        name: 'validations'
        desc: 'field validations'
        accepts: ['Validator']
        type: 'array'
      ,
        name: 'decorations'
        desc: 'field decorators'
        accepts: ['Decorator']
        type: 'array'
      ]
      code:
        render: (node) ->
          if node
            for n in node.children()
              c = n.getComponent()
              if c and c.hasRender()
                c.doRender(node)

        generate: (node, client) ->
          s = ''
          if !client
            s = "field" + '\n'
  #          c = node.getComponent()
            if node.hasChildren()
              for n in node.childrenOfKind(['Attribute', 'Validator'])
  #              c = n.getComponent()
                s += n.doGenerate() + '\n'
          return s
  ,

    name: 'Type'
    desc: 'Field or Input data type'
    extra:
      inherit: 'Object'
      options: 'hpl'
      color: 'lightpink'
      icon: 'type2'
  ,

    name: 'Text'
    desc: 'Text type'
    extra:
      icon: 'uniF4E8'
      inherit: 'Type'
#      code: 'text.js'
  ,

    name: 'Number'
    desc: 'Number type'
    extra:
      icon: 'hash'
      inherit: 'Type'
      code: 'number.js'
  ,

    name: 'Currency'
    desc: 'Currency type'
    extra:
      icon: 'dollar32'
      inherit: 'Type'
      code: 'currency.js'
  ,

    name: 'Percent'
    desc: 'Percent type'
    extra:
      icon: 'coupon'
      inherit: 'Type'
      code: 'percent.js'
  ,

    name: 'Email'
    desc: 'Email type'
    extra:
      icon: 'email22'
      inherit: 'Type'
      code: 'email.js'
  ,

    name: 'Date'
    desc: 'Date type'
    extra:
      icon: 'calendar32'
      inherit: 'Type'
      code: 'date.js'
  ,

    name: 'Time'
    desc: 'Time type'
    extra:
      icon: 'clock22'
      inherit: 'Type'
      code: 'time.js'
  ,

    name: 'Validator'
    desc: 'Field validator'
    extra:
      inherit: 'Object'
      options: 'hpl'
      icon: 'check'
      color: 'red'
  ,

    name: 'Required'
    desc: 'Required'
    extra:
      icon: 'spam2'
      inherit: 'Validator'
      code: 'required.js'
  ,

    name: 'ReadOnly'
    desc: 'Read-only'
    extra:
      icon: 'lock32'
      inherit: 'Validator'
      code: 'readonly.js'
  ,

    name: 'Attribute'
    desc: 'Field attribute'
    extra:
      inherit: 'Object'
      options: 'hpl'
      icon: 'tools'
      color: 'lightgreen'
  ,

    name: 'Encrypted'
    desc: 'Encrypt field'
    extra:
      icon: 'security2'
      inherit: 'Attribute'
      code: 'encrypted.js'
  ,

    name: 'Populate'
    desc: 'Populate field'
    extra:
      icon: 'document-fill'
      inherit: 'Attribute'
      code: 'populate.js'
  ,

    name: 'UI'
    desc: 'UI element'
    extra:
      options: 'hpl'
#      accepts: ['View', 'Menubar']
      color: 'lightpurple'
  ,

    name: 'Page'
    desc: 'Page that contains view(s)'
    extra:
      inherit: 'UI'
      icon: 'canvasrulers'
      accepts: ['View', 'Menubar']
      default_children: 'View, Menubar'
      color: 'lightpurple'
  ,

    name: 'View'
    desc: 'View definition'
    extra:
      inherit: 'UI'
      icon: 'article2'
      accepts: ['Control']
      default_children: 'Label'
      color: 'blue'
  ,

    name: 'Menubar'
    desc: 'Navigation menu bar'
    extra:
      inherit: 'UI'
      options: 'l'
      icon: 'dropmenu'
      accepts: ['Menu']
      default_children: 'Menu'
  ,

    name: 'Menu'
    desc: 'Menu item'
    extra:
      inherit: 'UI'
      icon: 'menu2'
      accepts: ['Control']
  ,

    name: 'Control'
    desc: 'Control to place on view'
    extra:
      inherit: 'UI'
      options: 'hp'
      icon: 'pointer'
      accepts: ['Decorator']
      color: 'lightorange'
  ,

    name: 'Label'
    desc: 'Label'
    extra:
      icon: 'uniF4E8'
      inherit: 'Control'
  ,

    name: 'Icon'
    desc: 'Icon'
    extra:
      icon: 'picture22'
      inherit: 'Control'
  ,

    name: 'Input'
    desc: 'Input control'
    extra:
      inherit: 'Control'
      options: 'hp'
      icon: 'uniF5D5'
  ,

    name: 'Button'
    desc: 'Action button'
    extra:
      icon: 'progress-0'
      inherit: 'Control'
      accepts: ['Icon', 'Label']
  ,

    name: 'Table'
    desc: 'Table display'
    extra:
      icon: 'table2'
      options: 'l'
      inherit: 'Control'
      accepts: ['Column', 'Header']
  ,

    name: 'Header'
    desc: 'Table header'
    icon: 'tag8'
    extra:
      options: 'l'
      inherit: 'Control'
      accepts: ['Icon']
  ,

    name: 'Column'
    desc: 'Table column'
    extra:
      icon: 'columns'
      inherit: 'Control'
      accepts: ['Column', 'Field']
  ,

    name: 'Decorator'
    desc: 'Control decoration'
    extra:
      inherit: 'Object'
      options: 'hpl'
      icon: 'palette'
      color: 'lightbrown'
  ,

    name: 'Bold'
    desc: 'Bold text appearance'
    extra:
      icon: 'bold'
      inherit: 'Decorator'
      code:
        render: (node) ->
          if node
            e = angular.element('#node-label_' + node.id())
          else
            e = angular.element('#component-label_' + this.id())
          e.addClass('bold')
  ,

    name: 'Italic'
    desc: 'Italic text appearance'
    extra:
      icon: 'italic'
      inherit: 'Decorator'
      code:
        render: (node) ->
          if node
            e = angular.element('#node-label_' + node.id())
          else
            e = angular.element('#component-label_' + this.id())
          e.addClass('italic')
  ,

    name: 'Underline'
    desc: 'Underline text appearance'
    extra:
      icon: 'underline'
      inherit: 'Decorator'
      code:
        render: (node) ->
          if node
            e = angular.element('#node-label_' + node.id())
          else
            e = angular.element('#component-label_' + this.id())
          e.addClass('underline')
  ,

    name: 'Strike'
    desc: 'Strike through text appearance'
    extra:
      icon: 'strikethrough'
      inherit: 'Decorator'
      code:
        render: (node) ->
          if node
            e = angular.element('#node-label_' + node.id())
          else
            e = angular.element('#component-label_' + this.id())
          e.addClass('strikethrough')
  ,

    name: 'Red'
    desc: 'Red colored text appearance'
    extra:
      inherit: 'Decorator'
      color: 'red'
      code:
        render: (node) ->
          if node
            e = angular.element('#node-label_' + node.id())
          else
            e = angular.element('#component-icon_' + this.id())
          e.addClass('red')
  ,

    name: 'Blue'
    desc: 'Blue colored text appearance'
    extra:
      inherit: 'Decorator'
      color: 'blue'
      code:
        render: (node) ->
          if node
            e = angular.element('#node-label_' + node.id())
          else
            e = angular.element('#component-icon_' + this.id())
          e.addClass('blue')
  ,

    name: 'LightBlue'
    desc: 'Light-blue colored text appearance'
    extra:
      inherit: 'Decorator'
      color: 'lightblue'
      code:
        render: (node) ->
          if node
            e = angular.element('#node-label_' + node.id())
          else
            e = angular.element('#component-icon_' + this.id())
          e.addClass('lightblue')
  ,

    name: 'Orange'
    desc: 'Orange colored text appearance'
    extra:
      inherit: 'Decorator'
      color: 'orange'
      code:
        render: (node) ->
          if node
            e = angular.element('#node-label_' + node.id())
          else
            e = angular.element('#component-icon_' + this.id())
          e.addClass('orange')
  ,

    name: 'Purple'
    desc: 'Purple colored text appearance'
    extra:
      inherit: 'Decorator'
      color: 'purple'
      code:
        render: (node) ->
          if node
            e = angular.element('#node-label_' + node.id())
          else
            e = angular.element('#component-icon_' + this.id())
          e.addClass('purple')
  ,

    name: 'Pink'
    desc: 'Pink colored text appearance'
    extra:
      inherit: 'Decorator'
      color: 'pink'
      code:
        render: (node) ->
          if node
            e = angular.element('#node-label_' + node.id())
          else
            e = angular.element('#component-icon_' + this.id())
          e.addClass('pink')
  ,

    name: 'Yellow'
    desc: 'Yellow colored text appearance'
    extra:
      inherit: 'Decorator'
      color: 'yellow'
      code:
        render: (node) ->
          if node
            e = angular.element('#node-label_' + node.id())
          else
            e = angular.element('#component-icon_' + this.id())
          e.addClass('yellow')
  ,

    name: 'DarkGray'
    desc: 'Dark-gray colored text appearance'
    extra:
      inherit: 'Decorator'
      color: 'darkgray'
      code:
        render: (node) ->
          if node
            e = angular.element('#node-label_' + node.id())
          else
            e = angular.element('#component-icon_' + this.id())
          e.addClass('darkgray')
  ,

    name: 'Gray'
    desc: 'Gray colored text appearance'
    extra:
      inherit: 'Decorator'
      color: 'gray'
      code:
        render: (node) ->
          if node
            e = angular.element('#node-label_' + node.id())
          else
            e = angular.element('#component-icon_' + this.id())
          e.addClass('gray')
  ,

    name: 'LightGray'
    desc: 'Light-gray colored text appearance'
    extra:
      inherit: 'Decorator'
      color: 'lightgray'
      code:
        render: (node) ->
          if node
            e = angular.element('#node-label_' + node.id())
          else
            e = angular.element('#component-icon_' + this.id())
          e.addClass('lightgray')
  ,

    name: 'Query'
    desc: 'Query'
    extra:
      inherit: 'Object'
      icon: 'filter'
      default_children: 'Select,Where,OrderBy,Limit'
      accepts: ['QueryAction']
      color: 'lightgray'
      code: 'query.js'
  ,

    name: 'QueryAction'
    desc: 'Query action'
    extra:
      inherit: 'Statement'
      options: 'hp'
      icon: 'filter'
      color: 'darkgray'
  ,

    name: 'Select'
    desc: 'Selected fields'
    extra:
      icon: 'selectionadd'
      accepts: ['Field']
      inherit: 'QueryAction'
      code: 'queryselect.js'
  ,

    name: 'Where'
    desc: 'Query conditions'
    extra:
      icon: 'search5'
      accepts: ['If', 'And', 'Or']
      inherit: 'QueryAction'
      code: 'querywhere.js'
  ,

    name: 'OrderBy'
    desc: 'Order fields'
    extra:
      icon: 'sort-by-attributes'
      accepts: ['Field']
      inherit: 'QueryAction'
      code: 'queryorderby.js'
  ,

    name: 'Query Page'
    desc: 'Page to retrieve'
    extra:
      icon: 'pagebreak'
      inherit: 'QueryAction'
      code: 'querypage.js'
  ,

    name: 'Limit'
    desc: 'Maximum number of rows to fetch'
    extra:
      icon: 'stop23'
      inherit: 'QueryAction'
      code: 'querylimit.js'
  ,

    name: 'Statement'
    desc: 'Statement'
    extra:
      options: 'hp'
      icon: 'code32'
      color: 'orange'
  ,

    name: 'Expression'
    desc: 'Expression'
    extra:
      inherit: 'Statement'
      icon: 'sum'
      color: 'darkyellow'
      code: 'expression.js'
  ,

    name: 'Method'
    desc: 'Schema method'
    extra:
      inherit: 'Statement'
      accepts: ['Statement']
      icon: 'cogs22'
      code: 'method.js'
  ,

    name: 'Static'
    desc: 'Schema static'
    extra:
      inherit: 'Statement'
      accepts: ['Statement']
      icon: 'cogs'
      code: 'static.js'
  ,

    name: 'If'
    desc: 'If condition'
    extra:
      inherit: 'Statement'
      default_children: 'True,False'
      icon: 'flow-cascade'
      code: 'if.js'
  ,

    name: 'And'
    desc: 'And condition'
    extra:
      inherit: 'Statement'
      accepts: ['Statement']
      icon: 'ampersand'
      code: 'and.js'
  ,

    name: 'Or'
    desc: 'Or condition'
    extra:
      inherit: 'Statement'
      accepts: ['Statement']
      icon: 'flow-line'
      code: 'or.js'
  ,

    name: 'Loop'
    desc: 'Loop until condition'
    extra:
      inherit: 'Statement'
      accepts: ['Statement']
      icon: 'repeat'
      code: 'loop.js'
  ,

    name: 'Foreach'
    desc: 'Loop each element'
    extra:
      inherit: 'Statement'
      accepts: ['Statement']
      icon: 'loop22'
      code: 'foreach.js'

  ]

  C = mongoose.model('Component')

  C.remove({}, (err) ->

    dd = data.map((d) ->
      f = _.clone(d)

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

        if f.extra.properties
          for p in f.extra.properties
            if p.accepts
              naccepts = []
              for n in p.accepts
                ca = { parent: [], component: null}
                ac = n.split(':')
                if ac.length > 1
                  for i in [0..ac.length - 2]
                    if ac[i]
                      ca.parent.push(ac[i])
                  n = ac[ac.length - 1]
                ca.component = n
                naccepts.push(ca)
              p.accepts = naccepts

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

      return f
    )

    C.create(dd, (err) ->
    )
  )
, 500)
