ArgClass =

#  name
#  desc
#  component
#  options
#  enum []
#  default
#  states

  VCGlobal: null
  VCComponent: null

  setData: (k, a, node) ->
    if a.clearData
      a.clearData()

    if type(a) is not 'object'
      a = { value: _.cloneDeep(a) }

    a.$data = {}
    a.$data._node = node
    a.$data._states = ''
    a.$data._component = null
    a.$data.isArg = true

    if k? and !a.name?
      a.name = k

    if !a.component? and node?
      ad = node.getArgDef(k)
      if ad
#        if ad.enum
#          a.enum = ad.enum
        a.component = ad.getComponent().name


    a.hasData = () ->
      return @hasOwnProperty('$data')

    a.clearData = () ->
      if @hasData()
        delete @$data

    a.getName = () ->
      return (if @name then @name.toLowerCase() else "")

    a.getValue = () ->
      return @value

    a.setValue = (value) ->
      @value = value

    a.displayName = () ->
      return (if @name then @name else "")

    a.getDesc = () ->
      return (if @desc then @desc else "")

    a.getDefault = () ->
      return (if @default then @default else "")

    a.hasComponent = () ->
      return @getComponent()

    a.getComponent = () ->
      if @$data
        c = @$data._component
      else
        c = null
      if !c
        c = ArgClass.VCGlobal.findComponent(@component)
        @$data._component = c
      return c

    a.setComponent = (c) ->
      c = ArgClass.VCGlobal.findComponent(c)
      @component = c.name
      @$data._component = c
      @setModified(true)

    a.hasNode = () ->
      return @getNode()

    a.getNode = () ->
      if @$data
        n = @$data._node
      else
        n = null
      if !n
        n = ArgClass.VCGlobal.findNode(@node)
        @$data._node = n
      return n

    a.setNode = (n) ->
      n = ArgClass.VCGlobal.findNode(@module(), n)
      @node = n._id
      @$data._node = n
      @setModified(true)

    a.canEdit = () ->
      cc = @getComponent()
      @canModify() and cc and !cc.isLocked()

    a.canModify = () ->
      return !@isReadOnly()

    a.isReadOnly = () ->
      return @hasOption('r')

    a.getOptions = () ->
      if @options
        return @options
      else
        return ''

    a.hasOption = (s) ->
      o = @getOptions()
      if o?
        o.indexOf(s) > -1
      else
        return false

    a.hasState = (s) ->
      if @$data
        return @$data._states.indexOf(s) > -1
      else
        return null

    a.addState = (s) ->
      if !@hasState(s) and @$data
        @$data._states += s
        @refreshScope()

    a.delState = (s) ->
      if @$data
        i = @$data._states.indexOf(s)
        if i != -1
          @$data._states = @$data._states.substr(0, i) + @$data._states.substr(i + 1)
          @refreshScope()

    a.hasEnum = () ->
      @getEnum().length

    a.getEnum = () ->
      if @$data._node
        ad = @$data._node.getArgDef(@name)
        if ad
          e = ad.getEnum()
          if e and e.length
            return e

      else if @enum
        return ArgClass.VCGlobal.enumToList(@enum)

      c = @getComponent()
      if c
        return c.getEnum()
      else
        return []

    a.isRequired = () ->
      !@hasOption('o')

    a.isOptional = () ->
      @hasOption('o')

    a.isModified = () ->
      @hasState('m')

    a.setModified = (b) ->
      if b
        @addState('m')
      else
        @delState('m')
      if @hasNode()
        @getNode().setModified(b)

    a.isNew = () ->
      @hasState('n')

    a.setNew = (b) ->
      if b
        @addState('n')
        @setModified(true)
      else
        @delState('n')
        @setModified(true)

    a.isDeleted = () ->
      @hasState('d')

    a.setDeleted = (b) ->
      if b
        @addState('d')
        @setModified(true)
      else
        @delState('d')
        @setModified(true)

    a.kindOf = (name) ->
      if name instanceof Array
        for n in name
          if @kindOf(n)
            return true
        return false
      else
        cc = @getComponent()
        return cc and cc.kindOf(name)

    a.codeValue = () ->
      c = @getComponent()
      if c and c.hasGenerate()
        return c.doGenerate(@)
      else
        v = @getValue()
        i = parseInt(v, 10)
        if i != NaN
          return v
        else
          return '"' + v + '"'

    a.element = () ->
      e = angular.element('#node-arg-element-id_' + @name)
      if e and e.length
        return e
      else
        return null

    a.scope = () ->
      e = @element()
      if e
        scope = e.scope()
        return scope
      return null

    a.getInputType = () ->
      if @hasEnum()
        return "enum"
      c = @getComponent()
      if c
        if c.getInputType()
          return c.getInputType()
      return "string"

  make: (name, a, node) ->
    @setData(name, a, node)


if define?
  define('vc_arg', [], () ->
    require(['vc_global', 'vc_component'], (gd, cd) ->
      ArgClass.VCGlobal = gd
      ArgClass.VCComponent = cd
    )
    return ArgClass
  )
else
  ArgClass.VCGlobal = require('./vc_global')
  ArgClass.VCComponent = require('./vc_component')
  module.exports = ArgClass
