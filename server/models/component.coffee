app = require("../app")
mongoose = require("../app").mongoose
timestamps = require('mongoose-time')()
findOrCreate = require('mongoose-findorcreate')
Currency = require('mongoose-currency')
version = require('../mongoose_plugins/mongoose-version')
_ = require('lodash')
fs = require('fs');
async = require('async')
Component_Data = require("../app").Component_Data

Node = require('./node')

_components = null

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

  inherit:
    type: mongoose.Schema.ObjectId
    ref: 'Component'
    label: 'Inherit'
    readOnly: true

  icon:
    type: String
    label: 'Icon'
    readOnly: true

  color:
    type: String
    label: 'Color'
    readOnly: true

  valueKind:
    type: mongoose.Schema.ObjectId
    ref: 'Component'

  accepts:
    type: [
      parent: [
        type: mongoose.Schema.ObjectId
        ref: 'Component'
      ]
      component:
        type: mongoose.Schema.ObjectId
        ref: 'Component'
    ]
    label: 'Accepts'
    readOnly: true

  _options:
    type: String
    default: 'v'  # v:visible, p:parentIcons, l:lock
    label: 'Options'
    readOnly: true

  clientCode:
    type: String
    label: 'Code'
    readOnly: true

  serverCode:
    type: String
    label: 'Server code'
    private: true
    readOnly: true

  default_children:
    type: String
    label: 'Default children nodes'
    readOnly: true
,
  label: 'Components'
)

ComponentSchema.plugin(timestamps)
ComponentSchema.plugin(findOrCreate)
ComponentSchema.plugin(version)

ComponentSchema.method(
  populateFields: (cb) ->
    @populate('inherit accepts valueKind', (err) ->
      cb() if cb
    )

  getServerCode: () ->
    if @serverCode?
      return @serverCode
    else if @inherit
      return @inherit.getServerCode()
    else
      return ""

  hasServerCode: () ->
    return @getServerCode()?
)

ComponentSchema.static(
  findByName: (n, cb) ->
    mongoose.model('Component').findOne({ name: new RegExp(n, "i") }, (err, c) ->
      cb(err, c) if cb
    )

  findByInherit: (n, cb) ->
    mongoose.model('Component').populate('inherit').where({ 'inherit.name': new RegExp(n, "i") }).find((err, c) ->
      cb(err, c) if cb
    )

  components: (cb) ->
    console.log "Loading components..."
    Component_Data.rest = {rows:[]}
    mongoose.model('Component').find({}, (err, components) ->
      Component_Data.rest.rows = components
      for c in components
        Component_Data.makeComponent(c)
      console.log "Loaded {0} components ({1})".format(components.length, Component_Data.rest.rows.length)
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
    name: 'Root'
    desc: 'Root'
    icon: 'flow-tree'
    _options: 'l'
    accepts: ['Projects']
    default_children: ['Projects']
  ,
    name: 'Projects'
    desc: 'Contains all modules'
    icon: 'uniF654'
    _options: 'l'
    accepts: ['Module']
    default_children: 'Module'
    color: 'purple'
    clientCode: 'project.js'
  ,
    name: 'SharedModules'
    desc: 'Contains all shared modules'
    icon: 'share52'
    _options: 'l'
    accepts: ['Module']
    default_children: 'Module'
    color: 'darkyellow'
    clientCode: 'sharedmodule.js'
  ,
    name: 'Module'
    desc: 'Base module component'
    icon: 'box'
    accepts: ['Schema', 'Page', 'Query', 'Method']
    default_children: 'Schema, Page, Query'
    color: 'green'
    clientCode: 'module.js'
    serverCode: 'module.js'
  ,
    name: 'Schema'
    desc: 'Schema definition'
    icon: 'database'
    accepts: ['Field', 'Method', 'Static']
    default_children: 'Field'
    color: 'darkorange'
    valueKind: 'View'
    clientCode: 'schema.js'
    serverCode: 'schema.js'
  ,
    name: 'Field'
    desc: 'Field definition'
    icon: 'uniF6CA'
    accepts: ['Module:Schema:Type', 'Module:Schema:Decorator', 'Module:Schema:Attribute', 'Module:Schema:Validator', 'Query:Schema:Expression']
    default_children: 'Text'
    color: 'pink'
    clientCode: 'field.js'
    serverCode: 'field.js'
  ,
    name: 'Type'
    desc: 'Field or Input data type'
    _options: 'pl'
    color: 'lightpink'
    icon: 'type2'
  ,
    name: 'Text'
    desc: 'Text type'
    icon: 'uniF4E8'
    inherit: 'Type'
    serverCode: 'text.js'
  ,
    name: 'Number'
    desc: 'Number type'
    icon: 'hash'
    inherit: 'Type'
    serverCode: 'number.js'
  ,
    name: 'Currency'
    desc: 'Currency type'
    icon: 'dollar32'
    inherit: 'Type'
    serverCode: 'currency.js'
  ,
    name: 'Percent'
    desc: 'Percent type'
    icon: 'coupon'
    inherit: 'Type'
    serverCode: 'percent.js'
  ,
    name: 'Email'
    desc: 'Email type'
    icon: 'email22'
    inherit: 'Type'
    serverCode: 'email.js'
  ,
    name: 'Date'
    desc: 'Date type'
    icon: 'calendar32'
    inherit: 'Type'
    serverCode: 'date.js'
  ,
    name: 'Time'
    desc: 'Time type'
    icon: 'clock22'
    inherit: 'Type'
    serverCode: 'time.js'
  ,
    name: 'Validator'
    desc: 'Field validator'
    _options: 'pl'
    icon: 'check'
    color: 'red'
  ,
    name: 'Required'
    desc: 'Required'
    icon: 'spam2'
    inherit: 'Validator'
    serverCode: 'required.js'
  ,
    name: 'ReadOnly'
    desc: 'Read-only'
    icon: 'lock32'
    inherit: 'Validator'
    serverCode: 'readonly.js'
  ,
    name: 'Attribute'
    desc: 'Field attribute'
    _options: 'pl'
    icon: 'tools'
    color: 'lightgreen'
  ,
    name: 'Encrypted'
    desc: 'Encrypt field'
    icon: 'security2'
    inherit: 'Attribute'
    serverCode: 'encrypted.js'
  ,
    name: 'Populate'
    desc: 'Populate field'
    icon: 'document-fill'
    inherit: 'Attribute'
    serverCode: 'populate.js'
  ,
    name: 'Page'
    desc: 'Page that contains view(s)'
    icon: 'canvasrulers'
    accepts: ['View', 'Menubar']
    default_children: 'View, Menubar'
    color: 'lightpurple'
  ,
    name: 'View'
    desc: 'View definition'
    icon: 'article2'
    accepts: ['Control']
    default_children: 'Label'
    color: 'blue'
  ,
    name: 'Menubar'
    desc: 'Navigation menu bar'
    _options: 'l'
    icon: 'dropmenu'
    accepts: ['Menu']
    default_children: 'Menu'
  ,
    name: 'Menu'
    desc: 'Menu item'
    icon: 'menu2'
    accepts: ['Control']
  ,
    name: 'Control'
    desc: 'Control to place on view'
    _options: 'p'
    icon: 'pointer'
    accepts: ['Decorator']
    color: 'lightorange'
  ,
    name: 'Label'
    desc: 'Label'
    icon: 'uniF4E8'
    inherit: 'Control'
  ,
    name: 'Icon'
    desc: 'Icon'
    icon: 'picture22'
    inherit: 'Control'
  ,
    name: 'Input'
    desc: 'Input control'
    _options: 'p'
    icon: 'uniF5D5'
  ,
    name: 'Button'
    desc: 'Action button'
    icon: 'progress-0'
    inherit: 'Control'
    accepts: ['Icon', 'Label']
  ,
    name: 'Table'
    desc: 'Table display'
    icon: 'table2'
    _options: 'l'
    inherit: 'Control'
    accepts: ['Column', 'Header']
  ,
    name: 'Header'
    desc: 'Table header'
    icon: 'tag8'
    _options: 'l'
    inherit: 'Control'
    accepts: ['Icon']
  ,
    name: 'Column'
    desc: 'Table column'
    icon: 'columns'
    inherit: 'Control'
    accepts: ['Column', 'Field']
  ,
    name: 'Decorator'
    desc: 'Control decoration'
    _options: 'pl'
    icon: 'palette'
    color: 'lightbrown'
  ,
    name: 'Bold'
    desc: 'Bold text appearance'
    icon: 'bold'
    inherit: 'Decorator'
    clientCode: 'bold.js'
  ,
    name: 'Italic'
    desc: 'Italic text appearance'
    icon: 'italic'
    inherit: 'Decorator'
    clientCode: 'italic.js'
  ,
    name: 'Underline'
    desc: 'Underline text appearance'
    icon: 'underline'
    inherit: 'Decorator'
    clientCode: 'underline.js'
  ,
    name: 'Strike'
    desc: 'Strike through text appearance'
    icon: 'strikethrough'
    inherit: 'Decorator'
    clientCode: 'strikethrough.js'
  ,
    name: 'Red'
    desc: 'Red colored text appearance'
    inherit: 'Decorator'
    color: 'red'
    clientCode: 'red.js'
  ,
    name: 'Blue'
    desc: 'Blue colored text appearance'
    inherit: 'Decorator'
    color: 'blue'
    clientCode: 'blue.js'
  ,
    name: 'LightBlue'
    desc: 'Light-blue colored text appearance'
    inherit: 'Decorator'
    color: 'lightblue'
    clientCode: 'lightblue.js'
  ,
    name: 'Orange'
    desc: 'Orange colored text appearance'
    inherit: 'Decorator'
    color: 'orange'
    clientCode: 'orange.js'
  ,
    name: 'Purple'
    desc: 'Purple colored text appearance'
    inherit: 'Decorator'
    color: 'purple'
    clientCode: 'purple.js'
  ,
    name: 'Pink'
    desc: 'Pink colored text appearance'
    inherit: 'Decorator'
    color: 'pink'
    clientCode: 'pink.js'
  ,
    name: 'Yellow'
    desc: 'Yellow colored text appearance'
    inherit: 'Decorator'
    color: 'yellow'
    clientCode: 'yellow.js'
  ,
    name: 'DarkGray'
    desc: 'Dark-gray colored text appearance'
    inherit: 'Decorator'
    color: 'darkgray'
    clientCode: 'darkgray.js'
  ,
    name: 'Gray'
    desc: 'Gray colored text appearance'
    inherit: 'Decorator'
    color: 'gray'
    clientCode: 'gray.js'
  ,
    name: 'LightGray'
    desc: 'Light-gray colored text appearance'
    inherit: 'Decorator'
    color: 'lightgray'
    clientCode: 'lightgray.js'
  ,
    name: 'Query'
    desc: 'Query'
    icon: 'filter'
    default_children: 'Select,Where,OrderBy,Limit'
    accepts: ['QueryAction']
    color: 'lightgray'
    serverCode: 'query.js'
  ,
    name: 'QueryAction'
    desc: 'Query action'
    _options: 'p'
    icon: 'filter'
    color: 'darkgray'
  ,
    name: 'Select'
    desc: 'Selected fields'
    icon: 'selectionadd'
    accepts: ['Field']
    inherit: 'QueryAction'
    serverCode: 'queryselect.js'
  ,
    name: 'Where'
    desc: 'Query conditions'
    icon: 'search5'
    accepts: ['If', 'And', 'Or']
    inherit: 'QueryAction'
    serverCode: 'querywhere.js'
  ,
    name: 'OrderBy'
    desc: 'Order fields'
    icon: 'sort-by-attributes'
    accepts: ['Field']
    inherit: 'QueryAction'
    serverCode: 'queryorderby.js'
  ,
    name: 'Query Page'
    desc: 'Page to retrieve'
    icon: 'pagebreak'
    inherit: 'QueryAction'
    serverCode: 'querypage.js'
  ,
    name: 'Limit'
    desc: 'Maximum number of rows to fetch'
    icon: 'stop23'
    inherit: 'QueryAction'
    serverCode: 'querylimit.js'
  ,
    name: 'Code'
    desc: 'Code'
    _options: 'p'
    icon: 'code32'
    color: 'orange'
  ,
    name: 'Expression'
    desc: 'Expression'
    inherit: 'Code'
    icon: 'sum'
    color: 'darkyellow'
    serverCode: 'expression.js'
  ,
    name: 'Method'
    desc: 'Schema method'
    inherit: 'Code'
    accepts: ['Code']
    icon: 'cogs22'
    serverCode: 'method.js'
  ,
    name: 'Static'
    desc: 'Schema static'
    inherit: 'Code'
    accepts: ['Code']
    icon: 'cogs'
    serverCode: 'static.js'
  ,
    name: 'If'
    desc: 'If condition'
    inherit: 'Code'
    default_children: 'True,False'
    accepts: ['And', 'Or', 'True']
    icon: 'flow-cascade'
    serverCode: 'if.js'
  ,
    name: 'And'
    desc: 'And condition'
    inherit: 'Code'
    accepts: ['Code']
    icon: 'ampersand'
    serverCode: 'and.js'
  ,
    name: 'Or'
    desc: 'Or condition'
    inherit: 'Code'
    accepts: ['Code']
    icon: 'flow-line'
    serverCode: 'or.js'
  ,
    name: 'True'
    desc: 'If condition evaluates to true'
    inherit: 'Code'
    accepts: ['Code']
    icon: 'folder-check'
    serverCode: 'true.js'
  ,
    name: 'False'
    desc: 'If condition evaluates to false'
    inherit: 'Code'
    accepts: ['Code']
    icon: 'folder4'
    serverCode: 'false.js'
  ,
    name: 'Loop'
    desc: 'Loop until condition'
    inherit: 'Code'
    accepts: ['Code']
    icon: 'repeat'
    serverCode: 'loop.js'
  ,
    name: 'Foreach'
    desc: 'Loop each element'
    inherit: 'Code'
    accepts: ['Code']
    icon: 'loop22'
    serverCode: 'foreach.js'
  ]

  C = mongoose.model('Component')

  C.remove({}, (err) ->

    if Component_Data.rest
      Component_Data.rest.rows = []

    dd = data.map((d) ->
      f = _.clone(d)
      delete f.valueKind
      delete f.inherit
      delete f.accepts
      if f.clientCode
        if fs.existsSync('_server/component_scripts/client/' + f.clientCode)
          f.clientCode = fs.readFileSync('_server/component_scripts/client/' + f.clientCode)
      if f.serverCode
        if fs.existsSync('_server/component_scripts/server/' + f.serverCode)
          f.serverCode = fs.readFileSync('_server/component_scripts/server/' + f.serverCode)
      return f
    )

    C.create(dd, (err) ->
      C.find((err, components) ->
        for d in data

          for c in components
            if c.name.toLowerCase() == d.name.toLowerCase()

              if d.accepts
                for n in d.accepts
                  ca = { parent: [], component: null}

                  ac = n.split(':')
                  if ac.length > 1
                    for i in [0..ac.length - 2]
                      a = ac[i]
                      for cc in components
                        if cc.name.toLowerCase() == a.toLowerCase()
                          ca.parent.push(cc.id)
                          break
                    n = ac[ac.length - 1]

                  for cc in components
                    if cc.name.toLowerCase() == n.toLowerCase()
                      ca.component = cc.id
                      break

                  c.accepts.push(ca)
                  c.save()

              if d.inherit
                for cc in components
                  if cc.name.toLowerCase() == d.inherit.toLowerCase()
                    c.inherit = cc.id
                    c.save()
                    break

              if d.valueKind
                for cc in components
                  if cc.name.toLowerCase() == d.valueKind.toLowerCase()
                    c.valueKind = cc.id
                    c.save()
                    break

              if d.dependencies
                for n in d.dependencies
                  for cc in components
                    if cc.name.toLowerCase() == n.toLowerCase()
                      c.dependencies.push(cc.id)
                      c.save()
                      break

              break

        C.components(() ->
          mongoose.model('Node').nodes()
        )
      )
    )
  )
, 500)
