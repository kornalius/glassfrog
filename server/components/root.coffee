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

  name: 'Literal'
  desc: 'Literal value'
  extra:
    options: 'h!'
    icon: 'tag8'
,

  name: 'String'
  desc: 'String object'
  extra:
    inherit: 'Literal'
    icon: 'quote-right'
    code:
      generate: (node, client) ->
        return '"' + (if node.name then node.name else '') + '"'
,

  name: 'Number'
  desc: 'Number object'
  extra:
    inherit: 'Literal'
    icon: 'hash'
    code:
      generate: (node, client) ->
        return (if node.name then node.name else '0')
,

  name: 'Boolean'
  desc: 'Boolean object'
  extra:
    inherit: 'Literal'
    enum: ['True', 'False']
    icon: 'switchon'
    code:
      generate: (node, client) ->
        return ""
,

  name: 'Date'
  desc: 'Date object'
  extra:
    inherit: 'Literal'
    icon: 'calendar32'
    code:
      generate: (node, client) ->
        return ""
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
    args: '*'
    code:
      generate: (node, client) ->
        args = ""
        if node.args.length
          d = []
          for n in node.args
            d.push(n.doGenerate(client))
          args = d.join(', ')
        return 'console.log(' + args + ');\n'
,

  name: 'Alert'
  desc: 'Show standard alert modal box'
  extra:
    inherit: 'Statement'
    icon: 'window2'
    options: 'm'
    code:
      generate: (node, client) ->
        args = ""
        if node.args.length
          d = []
          for n in node.args
            d.push(n.doGenerate(client))
          args = d.join(', ')
        if client
          return 'alert(' + args + ');\n'
        else
          return 'console.log(' + args + ');\n'

]

