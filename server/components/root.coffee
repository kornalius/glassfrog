module.exports = [

  name: 'Root'
  desc: 'Root'
  extra:
    accepts: ['Schema', 'Menubar', 'Page', 'Method', 'Object', 'ObjectRef']
    options: 'h!'
,

  name: 'Object'
  desc: 'Base object'
  extra:
    accepts: ['Property', 'Method', 'Event']
    options: 'h'
    icon: 'atom'
    code:
      generate: (node, client) ->
        return ""
,

  name: 'ObjectRef'
  desc: 'Base reference object'
  extra:
    accepts: ['MethodRef', 'PropertyRef']
    options: 'h!'
    icon: 'forward2'
    code:
      generate: (node, client) ->
        return ""
,

  name: 'ModuleRef'
  desc: 'Module reference'
  extra:
    options: 'h!'
    inherit: 'ObjectRef'
    icon: 'ruler3'
,

  name: 'Property'
  desc: 'Object property'
  extra:
    inherit: 'Object'
    icon: 'tag2'
    code:
      generate: (node, client) ->
        return ""
,

  name: 'PropertyRef'
  desc: 'Object property reference'
  extra:
    options: 'h!'
    inherit: 'ObjectRef'
    icon: 'tag2'
    code:
      generate: (node, client) ->
        return ""
,

  name: 'Method'
  desc: 'Method definition'
  extra:
    accepts: ['Object']
    icon: 'cogs22'
    code:
      generate: (node, client) ->
        args = ""
        if node.args.length
          d = []
          for n in node.args
            d.push(n.doGenerate(client))
          args = d.join(', ')
        s = node.varName() + ': function (' + args + ') {\n'
        for n in node.children()
          s += n.doGenerate(client)
        s + '};\n'
        return s
,

  name: 'MethodRef'
  desc: 'Method reference'
  extra:
    options: 'h!'
    inherit: 'ObjectRef'
    icon: 'cogs22'
    code:
      generate: (node, client) ->
        return ""
,

  name: 'MethodCall'
  desc: 'Method call'
  extra:
    options: 'h!'
    inherit: 'Statement'
    icon: 'cogs22'
    code:
      generate: (node, client) ->
        return ""
,

  name: 'Log'
  desc: 'Log stuff to the console'
  extra:
    inherit: 'Statement'
    icon: 'rawaccesslogs'
    args:
      'Message':
        desc: 'Message to display'
        component: 'String'
    code:
      generate: (node, client) ->
        return 'console.log(' + node.argsToString() + ');\n'
,

  name: 'Alert'
  desc: 'Show standard alert modal box'
  extra:
    inherit: 'Statement'
    icon: 'window2'
    options: 'm'
    args:
      'Message':
        desc: 'Message to display'
        component: 'String'
      'boolean':
        component: 'Boolean'
      'number':
        component: 'Number'
      'date':
        component: 'Date'
      'color':
        component: 'Color'
      'enum':
        enum: ['Option A', 'Option B', 'Option C']
        component: 'String'
    code:
      generate: (node, client) ->
        if client
          return 'alert(' + node.argsToString() + ');\n'
        else
          return 'console.log(' + node.argsToString() + ');\n'

]

