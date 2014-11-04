module.exports = [

  name: 'Root'
  desc: 'Root'
  extra:
    accepts: ['Schema++', 'Page++', '=Object++', 'Module.Config']
    defaults: ['Module.Config']
    options: 'h!'
    code:
      client: (out, node, user) ->
          out.line "'use strict';"
          out.line()

          out.block('(function()', ')();', (out) ->
            mod = node.module().getClassName()
            deps = node.linkedModules(true).map((m) -> '\'' + m.getClassName() + '\'')
            if deps.length
              deps = ', ' + deps.join(', ')
            ctrl = mod + 'Ctrl'

            out.line "angular.module('{0}', ['app'{1}])".format(mod, deps)

            out.block(".controller('{0}', ['$scope', 'Globals', 'Rest', 'dynForm', function($scope, globals, Rest, dynForm)".format(ctrl), "])", (out) ->
            )

            out.nodes node, 'client', user, "Page"

            out.block(".config(['$stateProvider', function ($stateProvider)", "]);", (out) ->
              out.group("$stateProvider", ";", (out) ->
                out.jsonBlock(".state('{0}',".format(mod.toLowerCase()), ")", (out) ->
                  out.line "abstract: true"
                  out.line "url:'/{0}'".format(mod.toLowerCase())
                  out.line "templateUrl: '/partials/{0}.html'".format(mod.toLowerCase())
                  out.line "controller: '{0}'".format(ctrl)
                )

                for p in node.childrenOfKind('Page')
                  out.jsonBlock(".state('{0}.{1}',".format(mod.toLowerCase(), p.varName().toLowerCase()), ")", (out) ->
                    out.line "url:''"
                    if p.getArgValue('icon')
                      out.line "icon: {0}".format(p.getArgValue('icon'))
                    out.jsonBlock("data:", (out) ->
                      out.line "root: '{0}'".format(mod.toLowerCase())
                      out.line "ncyBreadcrumbLabel: '{0}'".format(mod.humanize())
                    )
                    out.jsonBlock("views:", (out) ->
                      for v in p.childrenOfKind('View')
                        out.jsonBlock("{0}_{1}:".format(p.varName().toLowerCase(), v.varName().toLowerCase()), (out) ->
                          out.line "templateUrl: '{0}_{1}_{2}.html'".format(mod.toLowerCase(), p.varName().toLowerCase(), v.varName().toLowerCase())
                          out.line "controller: '{0}{1}{2}Ctrl'".format(mod, p.getClassName(), v.getClassName())
                        )
                    )
                  )
              )
            )

#        out.block("define('{0}', [{1}], function ({2})".format(node.module().varName(), node.linkedModules(true).map((m) -> m.varName().join(', ')), node.linkedModules(true).map((m) -> m.varName()).join(', ')), (out) ->
#            out.nodes node, 'client', user, "Page"
#          )

         )

      server: (out, node, user) ->
        out.line "'use strict';"
        out.line()

        out.block("(function()", ").call(this);", (out) ->
          for m in node.linkedModules(true)
            out.line "require('{0}');".format(m.varName())

          out.line "var app = require('../app');"
          out.line "var mongoose = require('mongoose');"
          out.line "var timestampPlugin = require('mongoose-time')();"
          out.line "var mongooseCurrency = require('mongoose-currency').loadType(mongoose);"
          out.line "var mongooseSetter = require('mongoose-setter')(mongoose);"
          out.line "var mongoosePercent = require('../mongoose_plugins/mongoose-percent')(mongoose);"
          out.line "// var mongooseMoment = require('mongoose-moment')(mongoose);"
          out.line "var mongooseEncrypted = require('mongoose-encrypted').loadTypes(mongoose);"
          out.line "var mongooseVersion = require('../mongoose_plugins/mongoose-version')();"
          out.line "var schemaExtend = require('mongoose-schema-extend');"
          out.line()
          out.nodes node, 'server', user, "Schema"
          out.line()
          out.line "exports.schemas = [{0}]".format(node.childrenOfKind('Schema', true).map((n) -> n.varName()).join(', '))
          out.line "exports.queries = [{0}]".format(node.childrenOfKind('Query', true).map((n) -> n.varName()).join(', '))
          out.line "exports.pages = [{0}]".format(node.childrenOfKind('Page', true).map((n) -> n.varName()).join(', '))
          out.line "exports.views = [{0}]".format(node.childrenOfKind('View', true).map((n) -> n.varName()).join(', '))
          out.line "exports.forms = [{0}]".format(node.childrenOfKind('Form', true).map((n) -> n.varName()).join(', '))
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
    options: 's'
    color: 'lightgreen'
    args:
      'color':
        label: 'color'
        desc: 'Module color'
        component: 'Literal.Color'
      'icon':
        desc: 'Module version'
        component: 'Literal.Icon'
        default: 'cic-ruler3'
      'desc':
        label: 'description'
        desc: 'Module description'
        component: 'Literal.String'
      'tags':
        label: 'tags'
        desc: 'Module tags'
        component: 'Literal.String'
        default: ['module']
        options: 't'
      'version':
        desc: 'Module version'
        component: 'Literal.String'
        default: '0.0.1a'
,

  name: 'Object.Category'
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
    category: 'Object.Category'
    accepts: ['=Object++', 'Method++', 'Event++']
    color: 'gray'
    icon: 'cic-atom'
    code:
      client_server: (out, node, user) ->
        out.append node.varName()
,

  name: 'Object.Ref'
  desc: 'Base reference object'
  extra:
    display: 'Object Ref'
    category: 'Object.Ref.Category'
    options: 'h!'
    icon: 'cic-forward2'
    code:
      client_server: (out, node, user) ->
        out.append node.varName()
,

  name: 'Object.Ref.Category'
  desc: 'Available modules objects'
  extra:
    display: 'Object Ref'
    options: 'c'
    icon: 'cic-forward2'
    color: 'gray'
,

  name: 'Module.Ref.Category'
  desc: 'Available modules'
  extra:
    display: 'Module Ref'
    options: 'c'
    icon: 'cic-ruler3'
    color: 'gray'
,

  name: 'Module.Ref'
  desc: 'Module reference'
  extra:
    display: 'Module Ref'
    category: 'Module.Ref.Category'
    options: 'h!'
    inherit: 'Object.Ref'
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
#  name: 'Property.Ref'
#  desc: 'Object property reference'
#  extra:
#    options: 'h!'
#    inherit: 'Object.Ref'
#    icon: 'cic-tag2'
#,

  name: 'Method'
  desc: 'Method definition'
  extra:
    accepts: ['Method.Argument++', 'Statement++']
    inherit: 'Object'
    icon: 'cic-cogs22'
    color: 'darkpurple'
    code:
      client: (out, node, user) ->
        out.append "$scope.{0} = function (".format(node.varName())
        for a in node.childrenOfKind('Method.Argument')
          out.append a.varName()
        out.append ")"
        out.jsonBlock((out) ->
          out.nodes node, 'client', user, "!Method.Argument"
        )

      server: (out, node, user) ->
        out.append "function {0} (".format(node.varName())
        for a in node.childrenOfKind('Method.Argument')
          out.append a.varName()
        out.append ")"
        out.jsonBlock((out) ->
          out.nodes node, 'server', user, "!Method.Argument"
        )
,

  name: 'Method.Argument'
  desc: 'Method argument definition'
  extra:
    inherit: 'Object'
    color: 'darkpurple'
    icon: 'cic-parentheses'
    args:
      'type':
        enum: ['String', 'Number', 'Boolean', 'Date', 'Time', 'DateTime', 'Color', 'Enum', 'Multi']
        desc: 'Argument type'
        default: 'String'
      'default':
        desc: 'Argument default value'
      'enum':
        'when': (node) ->
          node.argIsEqual('type', 'Enum')
        desc: 'Argument enumerations'
      'multi':
        'when': (node) ->
          node.argIsEqual('type', 'Multi')
        desc: 'Argument multiple enumerations'
      'desc':
        desc: 'Argument description'
,

  name: 'Method.Ref'
  desc: 'Method reference'
  extra:
    display: 'Method Ref'
    options: 'h!'
    inherit: 'Object.Ref'
    icon: 'cic-cogs22'
,

  name: 'Method.Call'
  desc: 'Method call'
  extra:
    display: 'Method Call'
    options: 'h!'
    inherit: 'Statement'
    icon: 'cic-cogs22'
    code:
      client: (out, node, user) ->
        out.line "{0}({1});".format(node.varName(), node.argsToString('client', user))

      server: (out, node, user) ->
        out.line "{0}({1});".format(node.varName(), node.argsToString('server', user))
,

  name: 'Log'
  desc: 'Log stuff to the console'
  extra:
    inherit: 'Method.Call'
    icon: 'cic-rawaccesslogs'
    args:
      'Message':
        desc: 'Message to display'
        component: 'Literal.String'
    code:
      client: (out, node, user) ->
        out.line "console.log({0});".format(node.argsToString('client', user))

      server: (out, node, user) ->
        out.line "console.log({0});".format(node.argsToString('server', user))
,

  name: 'Alert'
  desc: 'Show standard alert modal box'
  extra:
    inherit: 'Method.Call'
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
      client: (out, node, user) ->
        out.line "alert({0});".format(node.argsToString('client', user))

      server: (out, node, user) ->
        out.line "console.log({0});".format(node.argsToString('server', user))

]

