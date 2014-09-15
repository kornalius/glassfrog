module.exports = [

  name: 'Root'
  desc: 'Root'
  extra:
    accepts: ['Schema++', 'Page++', '=Object++', 'Module.Config']
    defaults: ['Module.Config']
    options: 'h!'
    code:
      client: (node) ->
        Handlebars.compile('
          define("{{module}}", [{{join modules.paths ", "}}], function ({{join modules.vars ", "}}) {\n
          \n});
        ')(
          component: @
          node: node
          module: node.varName()
          modules:
            nodes: node.linkedModules(true)
            paths: node.linkedModules(true).map((m) -> m.modulePath(user))
            vars: node.linkedModules(true).map((m) -> m.varName())
        )

      server: (node, user) ->
        console.log node.linkedModules(true)
        console.log node.linkedModules(true).map((m) -> m.modulePath(user))
        console.log node.linkedModules(true).map((m) -> m.varName())

        Handlebars.compile('
          (function() {\n
            {{#each modules.nodes}}
              require("{{varName}}");
            {{/each}}
            var app = require("../app");\n
            var mongoose = require("mongoose");\n
            var timestampPlugin = require("mongoose-time")();\n
            var mongooseCurrency = require("mongoose-currency").loadType(mongoose);\n
            var mongooseSetter = require("mongoose-setter")(mongoose);\n
            var mongoosePercent = require("../mongoose_plugins/mongoose-percent")(mongoose);\n
            //var mongooseMoment = require("mongoose-moment")(mongoose);\n
            var mongooseEncrypted = require("mongoose-encrypted").loadTypes(mongoose);\n
            var mongooseVersion = require("../mongoose_plugins/mongoose-version")();\n
            var schemaExtend = require("mongoose-schema-extend");\n
            \n
            {{{generate_nodes node user "Schema" "\n"}}}
          \n}).call(this);
        ')(
          component: @
          node: node
          module: node.varName()
          modules:
            nodes: node.linkedModules(true)
            paths: node.linkedModules(true).map((m) -> m.modulePath(user))
            vars: node.linkedModules(true).map((m) -> m.varName())
        )
,

  name: 'Null'
  desc: 'No output is produce by this object'
  extra:
    options: 'h!'
,

  name: 'Module.Config'
  desc: 'Module configuration options'
  extra:
    accepts: ['Module.Argument++']
    icon: 'cic-cog22'
    options: '!'
    color: 'lightgreen'
    args:
      'icon':
        desc: 'Module version'
        component: 'Literal.Icon'
        default: 'cic-ruler3'
      'desc':
        label: 'description'
        desc: 'Module description'
        component: 'Literal.String'
      'version':
        desc: 'Module version'
        component: 'Literal.String'
        default: '1.0.0'
,

  name: 'Module.Argument'
  desc: 'Module argument'
  extra:
    inherit: 'Object'
    icon: 'cic-tag3'
,

  name: 'Objects'
  desc: 'Objects'
  extra:
    display: 'Object'
    options: 'c'
    color: 'gray'
    icon: 'cic-atom'
,

  name: 'Object'
  desc: 'Base object'
  extra:
    category: 'Objects'
    accepts: ['=Object++', 'Method++', 'Event++']
    color: 'gray'
    icon: 'cic-atom'
    code:
      both: (node, user) ->
        node.varName()
,

  name: 'ObjectRef'
  desc: 'Base reference object'
  extra:
    category: 'ObjectsRef'
    options: 'h!'
    icon: 'cic-forward2'
    code:
      both: (node, user) ->
        node.varName()
,

  name: 'ObjectsRef'
  desc: 'Available modules objects'
  extra:
    options: 'c'
    icon: 'cic-forward2'
    color: 'gray'
,

  name: 'ModulesRef'
  desc: 'Available modules'
  extra:
    options: 'c'
    icon: 'cic-ruler3'
    color: 'gray'
,

  name: 'ModuleRef'
  desc: 'Module reference'
  extra:
    category: 'ModulesRef'
    options: 'h!'
    inherit: 'ObjectRef'
    icon: 'cic-ruler3'
,

#  name: 'Property'
#  desc: 'Object property'
#  extra:
#    inherit: 'Object'
#    accepts: ['Property++']
#    icon: 'cic-tag2'
#    color: 'darkpurple'
#,
#
#  name: 'PropertyRef'
#  desc: 'Object property reference'
#  extra:
#    options: 'h!'
#    inherit: 'ObjectRef'
#    icon: 'cic-tag2'
#,

  name: 'Method'
  desc: 'Method definition'
  extra:
    accepts: ['Statement++', 'MethodCall++']
    inherit: 'Object'
    icon: 'cic-cogs22'
    color: 'darkpurple'
    code:
      client: (node) ->
        Handlebars.compile('
          function {{name}} ({{{args}}}) {\n
            {{{generate_nodes true node null "*" "\n"}}}
          };\n
        ')(
          component: @
          node: node
          name: node.varName()
          args: node.argToString('parameters', user)
        )

      server: (node, user) ->
        Handlebars.compile('
          function {{name}} ({{{args}}}) {\n
            {{{generate_nodes false node user "*" "\n"}}}
          };\n
        ')(
          component: @
          node: node
          name: node.varName()
          args: node.argToString('parameters', user)
        )
,

  name: 'MethodRef'
  desc: 'Method reference'
  extra:
    options: 'h!'
    inherit: 'ObjectRef'
    icon: 'cic-cogs22'
,

  name: 'MethodCall'
  desc: 'Method call'
  extra:
    options: 'h!'
    inherit: 'Statement'
    icon: 'cic-cogs22'
    code:
      both: (node, user) ->
        Handlebars.compile('{{name}}({{{args}}});\n')(
          component: @
          node: node
          name: node.varName()
          args: node.argsToString(user)
        )
,

  name: 'Log'
  desc: 'Log stuff to the console'
  extra:
    inherit: 'MethodCall'
    icon: 'cic-rawaccesslogs'
    args:
      'Message':
        desc: 'Message to display'
        component: 'Literal.String'
    code:
      both: (node, user) ->
        Handlebars.compile('console.log({{{args}}});\n')(
          component: @
          node: node
          args: node.argsToString(user)
        )
,

  name: 'Alert'
  desc: 'Show standard alert modal box'
  extra:
    inherit: 'MethodCall'
    icon: 'cic-window2'
    args:
      'Message':
        desc: 'Message to display'
        component: 'Literal.String'
      'boolean':
        component: 'Literal.Boolean'
      'number':
        component: 'Literal.Number'
        default: 10
      'date':
        component: 'Literal.Date'
      'time':
        component: 'Literal.Time'
      'datetime':
        component: 'Literal.DateTime'
      'color':
        component: 'Literal.Color'
      'enum':
        enum: ['Option A', 'Option B', 'Option C']
        component: 'Literal.String'
    code:
      client: (node) ->
        Handlebars.compile('alert({{{args}}});\n')(
          component: @
          node: node
          args: node.argsToString(user)
        )

      server: (node, user) ->
        Handlebars.compile('console.log({{{args}}});\n')(
          component: @
          node: node
          args: node.argsToString(user)
        )

]

