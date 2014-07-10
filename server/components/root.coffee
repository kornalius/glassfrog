module.exports = [

  name: 'Root'
  desc: 'Root'
  extra:
    accepts: ['Schema', 'Page', 'ObjectRef']
    options: 'hl'
,

  name: 'Object'
  desc: 'Base object'
  extra:
    accepts: ['Property', 'Method']
    options: 'h'
    icon: 'atom'
,

  name: 'ObjectRef'
  desc: 'Base reference object'
  extra:
    accepts: ['MethodCall']
#    options: 'h'
    enum: ['@Object']
    icon: 'forward2'
,

  name: 'String'
  desc: 'String object'
  extra:
    inherit: 'Object'
    accepts: []
    icon: 'quote-right'
,

  name: 'Number'
  desc: 'Number object'
  extra:
    inherit: 'Object'
    accepts: []
    icon: 'hash'
,

  name: 'Boolean'
  desc: 'Boolean object'
  extra:
    inherit: 'Object'
    accepts: []
    enum: ['True', 'False']
    icon: 'switchon'
,

  name: 'Property'
  desc: 'Object property'
  extra:
    inherit: 'Object'
    icon: 'tag2'
,

  name: 'Method'
  desc: 'Method definition'
  extra:
    accepts: ['Statement']
    icon: 'cogs22'
,

  name: 'MethodCall'
  desc: 'Method call'
  extra:
    inherit: 'Statement'
    icon: 'cogs22'
,

  name: 'ModuleRef'
  desc: 'Module reference'
  extra:
    inherit: 'ObjectRef'
    icon: 'box4'
    enum: ['@Module']

]

