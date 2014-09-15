module.exports = [

  name: 'Schemas'
  desc: 'Schema definition'
  extra:
    display: 'Schema'
    category: 'Databases'
    options: 'c'
    icon: 'cic-database'
    color: 'darkorange'
,

  name: 'Schema'
  desc: 'Schema definition'
  extra:
    category: 'Schemas'
    inherit: 'Object'
    icon: 'cic-database'
    accepts: ['Field++', 'Schema.Method++', 'Schema.Static++', 'Schema.Attribute+']
    defaults: ['Field']
    color: 'darkorange'
    args:
      'extend':
        component: 'Literal.String'
        enum: ['@Schema']
        desc: 'Extend another schema'
    code:
#      render: (node) ->
#        if node
#          e = node.element('label')
#          s = if e.attr('style') then e.attr('style') else ""
#          if s.indexOf('font-weight') == -1
#            e.attr('style', s + 'font-weight: bold; ')

      server: (node, user) ->
        Handlebars.compile('
            {{#if encryptedFields}}
              var encryptedPlugin = mongooseEncrypted.plugins.encryptedPlugin;\n
            {{/if}}

            {{#if passwordFields}}
              var passwordPlugin = require("../mongoose_plugins/mongoose-password");\n
            {{/if}}

            {{#if addressFields}}
              var addressPlugin = require("../mongoose_plugins/mongoose-address");\n
            {{/if}}

            {{#if commentsFields}}
              var commentsPlugin = require("../mongoose_plugins/mongoose-comments");\n
            {{/if}}

            {{#if likesFields}}
              var historyPlugin = require("../mongoose_plugins/mongoose-likes");\n
            {{/if}}

            {{#if orderFields}}
              var orderPlugin = require("../mongoose_plugins/mongoose-order");\n
            {{/if}}

            {{#if personFields}}
              var personPlugin = require("../mongoose_plugins/mongoose-person");\n
            {{/if}}

            {{#if pictureFields}}
              var picturePlugin = require("../mongoose_plugins/mongoose-picture");\n
            {{/if}}

            {{#if softDeleteFields}}
              var soft_delete = require("mongoose-softdelete");\n
            {{/if}}

            {{#if fullTextFields}}
              var searchPlugin = require("mongoose-search-plugin");\n
            {{/if}}

            {{#if extendSchema}}
              var {{schema}} = {{extendSchema}}.extend({\n
            {{else}}
              var {{schema}} = mongoose.Schema({\n
            {{/if}}
              {{{generate_nodes node user "Field" ",\n"}}}
            \n}
            {{#if extendSchema}}
              , { discriminatorKey : "_type" }
            {{/if}}
            );\n\n

            {{schema}}.plugin(timestampPlugin);\n

            {{#if encryptedFields}}
              {{schema}}.plugin(encryptedPlugin);\n
            {{/if}}

            {{#if passwordFields}}
              {{schema}}.plugin(passwordPlugin);\n
            {{/if}}

            {{#if addressFields}}
              {{schema}}.plugin(addressPlugin);\n
            {{/if}}

            {{#if commentsFields}}
              {{schema}}.plugin(commentsPlugin);\n
            {{/if}}

            {{#if likesFields}}
              {{schema}}.plugin(likesPlugin);\n
            {{/if}}

            {{#if orderFields}}
              {{schema}}.plugin(orderPlugin);\n
            {{/if}}

            {{#if personFields}}
              {{schema}}.plugin(personPlugin);\n
            {{/if}}

            {{#if pictureFields}}
              {{schema}}.plugin(picturePlugin);\n
            {{/if}}

            {{#if softDeleteFields}}
              {{schema}}.plugin(soft_delete);\n
            {{/if}}

            {{#if fullTextFields}}
              {{schema}}.plugin(searchPlugin, { fields: ["{{fullTextFields}}"] });
            {{/if}}

            {{{generate_nodes node user "Schema.Method" "\n"}}}

            {{{generate_nodes node user "Schema.Static" "\n"}}}

            module.exports.{{schema}} = {{schema}}\n
       ')(
          component: @
          node: node
          schema: node.className() + 'Schema'
          encryptedFields: node.childrenOfKind("Field.Encrypted", true)
          passwordFields: node.childrenOfKind("Field.Password", true)
          addressFields: node.childrenOfKind("Schema.Address", true)
          commentsFields: node.childrenOfKind("Schema.Comments", true)
          likesFields: node.childrenOfKind("Schema.Likes", true)
          orderFields: node.childrenOfKind("Schema.Order", true)
          personFields: node.childrenOfKind("Schema.Person", true)
          pictureFields: node.childrenOfKind("Schema.Picture", true)
          softDeleteFields: node.childrenOfKind("Schema.SoftDelete", true)
          moduleRefFields: node.childrenOfKind('ModuleRef')
          fullTextFields: node.childrenOfKind("Field.FullTextSearch", true).map((n) -> if n.getParent() then n.getParent().displayName() else '').join('", ')
          extendSchema: ->
            v = node.getArg('extend').getValue()
            if v
              return v.camelize(true) + 'Schema'
            else
              return null
        )
,

  name: 'Schema.Method'
  desc: 'Schema method definition'
  extra:
    inherit: 'Method'
    category: 'Schemas'
    accepts: ['Statement++', 'MethodCall++']
    icon: 'cic-cogs22'
    color: 'darkpurple'
    code:
      server: (node, user) ->
        Handlebars.compile('
          {{schema}}.methods.{{name}} = function({{{args}}}) {\n
            {{{generate_nodes node client user "*" "\n"}}}
          };\n
        ')(
          component: @
          node: node
          name: node.varName()
          schema: node.getParent().className() + 'Schema'
          args: node.argToString('parameters', user)
        )
,

  name: 'Schema.Static'
  desc: 'Schema static definition'
  extra:
    inherit: 'Method'
    category: 'Schemas'
    accepts: ['@', 'Statement++', 'MethodCall++']
    icon: 'cic-cogs22'
    color: 'lightpurple'
    code:
      server: (node, user) ->
        Handlebars.compile('
          {{schema}}.statics.{{name}} = function({{{args}}}) {\n
            {{{generate_nodes node user "*" "\n"}}}
          };\n
        ')(
          component: @
          node: node
          name: node.varName()
          schema: node.getParent().className() + 'Schema'
          args: node.argToString('parameters', user)
        )
,

  name: 'Schema.Attributes'
  desc: 'Schema Attributes'
  extra:
    category: 'Schemas'
    options: 'c'
    icon: 'cic-stack3'
,

  name: 'Schema.Attribute'
  desc: 'Schema attribute'
  extra:
    category: 'Schema.Attributes'
    inherit: 'Object'
    options: 'hp!'
    icon: 'cic-stack3'
,

  name: 'Schema.Address'
  desc: 'Add address fields to each document'
  extra:
    icon: 'cic-location'
    inherit: 'Schema.Attribute'
,

  name: 'Schema.Comments'
  desc: 'Ability to add comments to each document'
  extra:
    icon: 'cic-comments3'
    inherit: 'Schema.Attribute'
,

  name: 'Schema.Likes'
  desc: 'Ability to like/unlike a document'
  extra:
    icon: 'cic-like'
    inherit: 'Schema.Attribute'
,

  name: 'Schema.Order'
  desc: 'Ability to order documents in a collection'
  extra:
    icon: 'cic-sortbysizeascending'
    inherit: 'Schema.Attribute'
,

  name: 'Schema.Person'
  desc: 'Add personal information fields to each document'
  extra:
    icon: 'cic-user32'
    inherit: 'Schema.Attribute'
,

  name: 'Schema.Picture'
  desc: 'Add picture to each document'
  extra:
    icon: 'cic-picture2'
    inherit: 'Schema.Attribute'
,

  name: 'SchemaRef'
  desc: 'Schema reference'
  extra:
    category: 'Schema'
    options: 'h!'
    inherit: 'ObjectRef'
    icon: 'cic-database'
,

  name: 'SchemaRef.Find'
  desc: 'Find a record'
  extra:
    category: 'Schema'
    inherit: 'MethodCall'
    icon: 'cic-magnifier'
    args:
      'field':
        desc: 'Field to search on'
        component: 'FieldRef'
      'value':
        desc: 'Value to search for'
        component: 'Literal.String'

]
