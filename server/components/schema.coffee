module.exports = [

  name: 'Schema'
  desc: 'Schema definition'
  extra:
    inherit: 'Object'
    icon: 'database'
    accepts: ['Field+', 'Method+']
    defaults: ['Field']
    color: 'darkorange'
    code:
#      render: (node) ->
#        if node
#          e = angular.element('#node-label_' + node.id())
#          s = if e.attr('style') then e.attr('style') else ""
#          if s.indexOf('font-weight') == -1
#            e.attr('style', s + 'font-weight: bold; ')

      generate: (node, client) ->
        c = new cg()

        if client

        else
          model = node.varName()
          schema = model + 'Schema'

          c.line('var app = require("../app")')
          c.line('var mongoose = require("mongoose")')
          c.line('var timestamps = require("mongoose-time")()')
          c.line('var utils = require("../lib/mongoose-utils")')
          c.line('var Moment = require("mongoose-moment")(mongoose)')
          c.line('var history = require("mongoose-history")')
          c.line('var Currency = require("mongoose-currency")')

          if node.childrenOfKind('Encrypted', true)
            c.line('var mongooseEncrypted = require("mongoose-encrypted").loadTypes(mongoose)')
            c.line('var encryptedPlugin = mongooseEncrypted.plugins.encryptedPlugin')

          if node.childrenOfKind('SoftDelete', true)
            c.line('var soft_delete = require("mongoose-softdelete")')

#          c.variable(schema, ->
#            @member_expr('mongoose', 'Schema', ->
#              @block_expr(() ->
#                modules = node.childrenOfKind('ModuleRef')
#                if modules.length
#                  for m in modules
#                    for n in m.getRoot().childrenOfKind(['Field'])
#                      @sequence(n.doGenerate(client))
#
#                fields = node.childrenOfKind(['Field'])
#                if fields.length
#                  for n in fields
#                    @sequence(n.doGenerate(client))
#              )
#            )
#          )

          c.line('{{&schema}}.plugin(timestamps)', {schema: schema})
          c.line('{{&schema}}.plugin(history, \{indexes: [{"t": -1, "d._id": 1\}], customCollectionName: null})', {schema: schema})

          if node.childrenOfKind('Encrypted', true)
            c.line('{{schema}}.plugin(encryptedPlugin)', {schema: schema})

          if node.childrenOfKind('SoftDelete', true)
            c.line('{{&schema}}.plugin(soft_delete)', {schema: schema})

          methods = node.childrenOfKind(['Method'])
          if methods.length
            for m in methods
              c.line('{{schema}}.method("{{&name}}", function({{&params}}) { {{&code}} })',
                schema: schema
                name: node.varName()
                params: node.argToString('parameters')
                code: ->
                  cc = c.cg(c.lvl + 1).cr(true)
                  for n in m.children()
                    cc.out(n.doGenerate(client))
                  return cc.code
              )

          c.line('module.exports = mongoose.model({{&schema}})', {schema: schema})

        return c.code
,

  name: 'SchemaRef'
  desc: 'Schema reference'
  extra:
    options: 'h!'
    inherit: 'ObjectRef'
    icon: 'database'
,

  name: 'SchemaRef.Find'
  desc: 'Find a record'
  extra:
    inherit: 'Method'
    icon: 'magnifier'
    args:
      'field':
        desc: 'Field to search on'
        component: 'FieldRef'
      'value':
        desc: 'Value to search for'
        component: 'String'
    accepts: []
    code:
      generate: (node, client) ->
        if client
          s = ''
        else
          s = ''
        return s
,

  name: 'Field'
  desc: 'Field definition'
  extra:
    inherit: 'Object'
    accepts: ['Validator+', 'Color', 'Font', 'Field.Type']
    icon: 'uniF6CA'
    color: 'pink'
    code:
      render: (node) ->
        if node
          for n in node.children()
            c = n.getComponent()
            if c and c.hasRender()
              c.doRender(node)

      generate: (node, client) ->
        if !client
          return new cg().label("field" + node.varName(), ->
            @block_expr(() ->
              @code = "FIELD " + node.name
              return @
    #          for n in node.childrenOfKind(['Attribute', 'Validator'])
    #            s += n.doGenerate(client) + '\n'
            ).cr()
          ).code
        else
          return ""
,

  name: 'FieldRef'
  desc: 'Field reference'
  extra:
    options: 'h!'
    inherit: 'ObjectRef'
    icon: 'uniF6CA'
,

  name: 'Field.Type'
  desc: 'Field or Input data type'
  extra:
    inherit: 'Object'
    options: 'hp!'
    color: 'lightpink'
    icon: 'type2'
,

  name: 'Field.Text'
  desc: 'Text type'
  extra:
    icon: 'uniF4E8'
    inherit: 'Field.Type'
,

  name: 'Field.Number'
  desc: 'Number type'
  extra:
    icon: 'hash'
    inherit: 'Field.Type'
,

  name: 'Field.Boolean'
  desc: 'Boolean type'
  extra:
    icon: 'switchon'
    inherit: 'Field.Type'
,

  name: 'Field.Currency'
  desc: 'Currency type'
  extra:
    icon: 'dollar32'
    inherit: 'Field.Type'
,

  name: 'Field.Percent'
  desc: 'Percent type'
  extra:
    icon: 'coupon'
    inherit: 'Field.Type'
,

  name: 'Field.Email'
  desc: 'Email type'
  extra:
    icon: 'email22'
    inherit: 'Field.Type'
,

  name: 'Field.Date'
  desc: 'Date type'
  extra:
    icon: 'calendar32'
    inherit: 'Field.Type'
,

  name: 'Field.Time'
  desc: 'Time type'
  extra:
    icon: 'clock22'
    inherit: 'Field.Type'
,

  name: 'Validator'
  desc: 'Field validator'
  extra:
    inherit: 'Object'
    options: 'hp!'
    icon: 'check'
    color: 'red'
,

  name: 'Required'
  desc: 'Required'
  extra:
    icon: 'spam2'
    inherit: 'Validator'
,

  name: 'ReadOnly'
  desc: 'Read-only'
  extra:
    icon: 'lock32'
    inherit: 'Validator'
,

  name: 'Attribute'
  desc: 'Field attribute'
  extra:
    inherit: 'Object'
    options: 'hp!'
    icon: 'tools'
,

  name: 'Encrypted'
  desc: 'Encrypt field'
  extra:
    icon: 'security2'
    inherit: 'Attribute'
,

  name: 'Populate'
  desc: 'Populate field'
  extra:
    icon: 'document-fill'
    inherit: 'Attribute'

]
