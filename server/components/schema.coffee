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
        Handlebars.compile('{{> schema_server}}')(
          component: @
          node: node
          schema: node.getClassName() + 'Schema'
          encryptedFields: node.childrenOfKind("Field").filter((n) -> n.is("options", "encrypted"))
          passwordFields: node.childrenOfKind("Field").filter((n) -> n.is("options", "password"))
          fullTextFields: node.childrenOfKind("Field").filter((n) -> n.is("options", "fulltextsearch")).map((n) -> "'" + n.getParent().displayName() + "'").join(', ')
          addressFields: node.childrenOfKind("Schema.Address")
          commentsFields: node.childrenOfKind("Schema.Comments")
          likesFields: node.childrenOfKind("Schema.Likes")
          orderFields: node.childrenOfKind("Schema.Order")
          personFields: node.childrenOfKind("Schema.Person")
          pictureFields: node.childrenOfKind("Schema.Picture")
          softDeleteFields: node.childrenOfKind("Schema.SoftDelete")
          moduleRefFields: node.childrenOfKind('ModuleRef')
          extendSchema: ->
            v = node.getArg('extend').displayValue()
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
            {{{generate_nodes node false user "*" "\n"}}}
          };\n
        ')(
          component: @
          node: node
          name: node.varName()
          schema: node.getParent().getClassName() + 'Schema'
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
            {{{generate_nodes node false user "*" "\n"}}}
          };\n
        ')(
          component: @
          node: node
          name: node.varName()
          schema: node.getParent().getClassName() + 'Schema'
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
