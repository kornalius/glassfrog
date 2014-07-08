module.exports = [

  name: 'Schema'
  desc: 'Schema definition'
  extra:
    inherit: 'Object'
    icon: 'database'
    accepts: ['Field', 'Method', 'Static']
    default_children: 'Field'
    color: 'darkorange'
    code:
#      render: (node) ->
#        if node
#          e = angular.element('#node-label_' + node.id())
#          s = if e.attr('style') then e.attr('style') else ""
#          if s.indexOf('font-weight') == -1
#            e.attr('style', s + 'font-weight: bold; ')

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
    accepts: ['Validator', 'Decorator', 'Type']
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

]
