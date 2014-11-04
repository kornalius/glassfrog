module.exports = [

  name: 'Schema.Category'
  desc: 'Schema definition'
  extra:
    display: 'Schema'
    category: 'Database.Category'
    options: 'c'
    icon: 'cic-database'
    color: 'darkorange'
,

  name: 'Schema'
  desc: 'Schema definition'
  extra:
    category: 'Schema.Category'
    inherit: 'Object'
    icon: 'cic-database'
    accepts: ['Field++', 'Schema.Method++', 'Schema.Static++', 'Schema.Attribute+']
    defaults: ['Field']
    color: 'darkorange'
    args:
      'extend':
        component: 'Literal.String'
        enum: ['', '@Schema']
        desc: 'Extend another schema'
    code:
#      render: (node) ->
#        if node
#          e = node.element('label')
#          s = if e.attr('style') then e.attr('style') else ""
#          if s.indexOf('font-weight') == -1
#            e.attr('style', s + 'font-weight: bold; ')

      server: (out, node, user) ->
        schema = node.getClassName() + 'Schema'
        encryptedFields = node.childrenOfKind("Field.Encrypted")
        passwordFields = node.childrenOfKind("Field.Password")
        fullTextFields = node.childrenOfKind("Field.FullTextSearch")
        addressFields = node.childrenOfKind("Schema.Address")
        commentsFields = node.childrenOfKind("Schema.Comments")
        likesFields = node.childrenOfKind("Schema.Likes")
        orderFields = node.childrenOfKind("Schema.Order")
        personFields = node.childrenOfKind("Schema.Person")
        pictureFields = node.childrenOfKind("Schema.Picture")
        softDeleteFields = node.childrenOfKind("Schema.SoftDelete")
        moduleRefFields = node.childrenOfKind('Module.Ref')
        extendSchema = ->
          v = node.getArg('extend').displayValue()
          if v
            return v.camelize(true) + 'Schema'
          else
            return null

        if encryptedFields.length
          out.line "var encryptedPlugin = mongooseEncrypted.plugins.encryptedPlugin;"
        if passwordFields.length
          out.line "var passwordPlugin = require('../mongoose_plugins/mongoose-password');"
        if addressFields.length
          out.line "var addressPlugin = require('../mongoose_plugins/mongoose-address');"
        if commentsFields.length
          out.line "var commentsPlugin = require('../mongoose_plugins/mongoose-comments');"
        if likesFields.length
          out.line "var historyPlugin = require('../mongoose_plugins/mongoose-likes');"
        if orderFields.length
          out.line "var orderPlugin = require('../mongoose_plugins/mongoose-order');"
        if personFields.length
          out.line "var personPlugin = require('../mongoose_plugins/mongoose-person');"
        if pictureFields.length
          out.line "var picturePlugin = require('../mongoose_plugins/mongoose-picture');"
        if softDeleteFields.length
          out.line "var soft_delete = require('mongoose-softdelete');"
        if fullTextFields.length
          out.line "var searchPlugin = require('mongoose-search-plugin');"

        out.line()

        if extendSchema.length
          out.line "var {0} = {1}.extend({".format(schema, extendSchema)
        else
          out.line "var {0} = mongoose.Schema({".format(schema)

        out.json((out) ->
          out.nodes node, 'server', user, 'Field'
        )

        if extendSchema.length
          out.line ", { discriminatorKey : '_type' }"

        out.line "});"
        out.line()

        out.line "{0}.plugin(timestampPlugin);".format(schema)

        if encryptedFields.length
          out.line "{0}.plugin(encryptedPlugin);".format(schema)
        if passwordFields.length
          out.line "{0}.plugin(passwordPlugin);".format(schema)
        if addressFields.length
          out.line "{0}.plugin(addressPlugin);".format(schema)
        if commentsFields.length
          out.line "{0}.plugin(commentsPlugin);".format(schema)
        if likesFields.length
          out.line "{0}.plugin(likesPlugin);".format(schema)
        if orderFields.length
          out.line "{0}.plugin(orderPlugin);".format(schema)
        if personFields.length
          out.line "{0}.plugin(personPlugin);".format(schema)
        if pictureFields.length
          out.line "{0}.plugin(picturePlugin);".format(schema)
        if softDeleteFields.length
          out.line "{0}.plugin(soft_delete);".format(schema)
        if fullTextFields.length
          out.line "{0}.plugin(searchPlugin, { fields: [{1}] });".format(schema, fullTextFields.map((n) -> '"' + n.displayName() + '"').join(', '))
        out.line()

        out.nodes node, 'server', user, 'Schema.Method'
        out.nodes node, 'server', user, 'Schema.Static'

        out.line()
        out.line "module.exports.{0} = {0};".format(schema)
,

  name: 'Schema.Method'
  desc: 'Schema method definition'
  extra:
    inherit: 'Method'
    category: 'Schema.Category'
    icon: 'cic-cogs22'
    color: 'darkpurple'
    code:
      server: (out, node, user) ->
        out.append "{0}.methods.{1} = function(".format(node.getParent().getClassName() + 'Schema', node.varName())
        console.log node.childrenOfKind('Method.Argument').map((n) -> n.name)
        console.log "!", node.childrenOfKind('!Method.Argument').map((n) -> n.name)
        for a in node.childrenOfKind('Method.Argument')
          out.append a.varName()
        out.append ")"
        out.jsonBlock((out) ->
          out.nodes node, 'server', user, "!Method.Argument"
        )
,

  name: 'Schema.Static'
  desc: 'Schema static definition'
  extra:
    inherit: 'Method'
    category: 'Schema.Category'
    icon: 'cic-cogs22'
    color: 'purple'
    code:
      server: (out, node, user) ->
        out.append "{0}.statics.{1} = function(".format(node.getParent().getClassName() + 'Schema', node.varName())
        for a in node.childrenOfKind('Method.Argument')
          out.append a.varName()
        out.append ")"
        out.jsonBlock((out) ->
          out.nodes node, 'server', user, "!Method.Argument"
        )
,

  name: 'Schema.Attribute.Category'
  desc: 'Schema Attributes'
  extra:
    display: 'Attribute'
    category: 'Schema.Category'
    options: 'c'
    icon: 'cic-stack3'
    color: 'gray'
,

  name: 'Schema.Attribute'
  desc: 'Schema attribute'
  extra:
    category: 'Schema.Attribute.Category'
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

  name: 'Schema.Ref'
  desc: 'Schema reference'
  extra:
    category: 'Schema.Category'
    options: 'h!'
    inherit: 'Object.Ref'
    icon: 'cic-database'
,

  name: 'Schema.Ref.Find'
  desc: 'Find a record'
  extra:
    category: 'Schema.Category'
    inherit: 'Method.Call'
    icon: 'cic-magnifier'
    args:
      'field':
        desc: 'Field to search on'
        component: 'Field.Ref'
      'value':
        desc: 'Value to search for'
        component: 'Literal.String'

]
