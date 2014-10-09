ArgClass =

#  name
#  label
#  desc
#  component
#  options
#  enum []
#  multi []
#  default
#  states

  VCGlobal: null

  setData: (k, a, node) ->
    if a.clearData
      a.clearData()

    if type(a) != 'object'
      a = { value: _.cloneDeep(a) }

    a.$data = {}
    a.$data._node = node
    a.$data._states = ''
    a.$data._component = null
    a.$data._link = null
    a.$data.isArg = true

    if k? and !a.name?
      a.name = k

    if !a.component? and node?
      ad = node.getArgDef(k)
      if ad
#        if ad.enum
#          a.enum = ad.enum
        cc = ad.getComponent()
        if !cc
          cc = ArgClass.VCGlobal.findComponent('Literal.String')
        if cc
          a.component = cc.name


    a.hasData = () ->
      return @hasOwnProperty('$data')

    a.clearData = () ->
      if @hasData()
        delete @$data

    a.getName = () ->
      return (if @name then @name.toLowerCase() else "")

    a.getLabel = () ->
      if @hasLabel()
        if @label?
          return (if @label then @label.toLowerCase() else "")
        else
          return (if @name then @name.toLowerCase() else "")
      else
        return null

    a.displayValue = () ->
      t = @getInputType()
      if t == 'icon'
        return ''
      else
        @toString()

    a.getValue = () ->
      if @isLink()
        v = @getLink()
      else
        v = @value
      return v

    a.toString = () ->
      v = @getValue()
      t = type(v)
      if v and v.$data and v.displayName
        return v.displayName()
      else if t is 'boolean'
        return (if v then 'true' else 'false')
      else if t is 'number'
        return (if Number.isNaN(v) then '0' else v.toString())
      else if t is 'moment'
        return v.format('L LT')
      else if t is 'date'
        return moment(v).format('L LT')
      else if t is 'array'
        return v.join(', ')
      else if t is 'regexp'
        return v.toString()
      else if t is 'tinycolor'
        return v.toHex8String()
      else if t is 'function'
        return v.toString()
      else
        return v

    a.getValueOrDefault = () ->
      v = @getValue()
      if !v?
        v = @getDefault()
      if !v?
        v = 'null'
      return v

    a.is = (value) ->
      _.contains(@getValue().map((v) -> v.toLowerCase()), value.toLowerCase())

    a.isLink = () ->
      @hasState('l')

    a.getLink = () ->
      if @isLink()
        return (if @$data and @$data._link then @$data._link else null)
      else
        return null

    a.setLink = (n) ->
      if @$data
        if !n
          @delState('l')
          @$data._link = null
          delete @value
          @setModified(true)
          return true
        else
          n = ArgClass.VCGlobal.find(n)
          if n and @$data and n != @$data._link
            @addState('l')
            @value = n.id()
            @$data._link = n
            @setModified(true)
            return true
      return false

    a.setValue = (value) ->
      if value and value.$data?
        @setLink(value)
      else if ArgClass.VCGlobal.isValidId(value)
        @setLink(value)
      else
        if @isLink()
          @setLink(null)
        if !_.isEqual(@value, value)
          @value = value
          @setModified(true)

    a.displayName = () ->
      return (if @name then @name else "")

    a.getDesc = () ->
      return (if @desc then @desc else "")

    a.getDefault = () ->
      if @default?
        return @default
      else
        c = @getComponent()
        if c
          return c.getDefault()
        else
          return null

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
      @$data._node

    a.setNode = (n) ->
      n = ArgClass.VCGlobal.findNode(@module(), n)
      @$data._node = n
      @setModified(true)

    a.canEdit = () ->
      cc = @getComponent()
      @canModify() and cc and !cc.isLocked()

    a.canModify = () ->
      return !@isReadOnly()

    a.isReadOnly = () ->
      return @hasOption('r')

    a.refreshScope = () ->
      s = @scope()
      if s
        setTimeout(->
          s.$apply()
        )

    a.hasOption = (s) ->
      if @options?
        @options.indexOf(s) > -1
      else
        return false

    a.addOption = (s) ->
      if !@hasOption(s)
        if !@options?
          @options = s
        else
          @options += s
        @setModified(true)
        @refreshScope()

    a.delOption = (s) ->
      if @options?
        i = @options.indexOf(s)
      else
        i = -1
      if i != -1
        @options = @options.substr(0, i) + @options.substr(i + 1)
        @setModified(true)

    a.hasState = (s) ->
      if @$data
        return @$data._states.indexOf(s) > -1
      else
        return null

    a.addState = (s) ->
      if !@hasState(s) and @$data
        @$data._states += s

    a.delState = (s) ->
      if @$data
        i = @$data._states.indexOf(s)
        if i != -1
          @$data._states = @$data._states.substr(0, i) + @$data._states.substr(i + 1)

    a.hasEnum = () ->
      node = @getNode()
      if node
        ad = node.getArgDef(@name)
        if ad
          return ad.hasEnum()

      else if @enum
        return true

      c = @getComponent()
      if c
        return c.hasEnum()
      else
        return false

    a.getEnum = (node, asObject) ->
      if type(node) is 'boolean'
        asObject = node
        node = null

      if @getNode()
        ad = @getNode().getArgDef(@name)
        if ad
          e = ad.getEnum(node, asObject)
          if e and e.length
            return e

      else if @enum
        return ArgClass.VCGlobal.enumToList(@enum, node, asObject)

      c = @getComponent()
      if c
        return c.getEnum(node, asObject)
      else
        return []

    a.hasMulti = () ->
      @getMulti(false).length

    a.getMulti = (asObject) ->
      node = @getNode()
      if node
        ad = node.getArgDef(@name)
        if ad
          m = ad.getMulti(node, asObject)
          if m and m.length
            return m

      else if @multi
        return ArgClass.VCGlobal.enumToList(@multi, node, asObject, true)

      return []

    a.isRequired = () ->
      !@hasOption('o')

    a.isOptional = () ->
      @hasOption('o')

    a.hasLabel = () ->
      !@hasOption('h')

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

    a.codeValue = (client, user) ->
      c = @getComponent()
      if c
        return c.generateCode(@, client, user)
      else
        return @getValue()

    a.domName = (type) ->
      if !type?
        type = 'element'
      n = @getNode()
      if n
        id = n.id()
      else
        id = '0'
      'node-arg-' + type + '_' + id + "_" + @getName()

    a.domId = (type) ->
      if !type?
        type = 'element'
      n = @getNode()
      if n
        id = n.id()
      else
        id = '0'
      'node-arg-' + type + '-id_' + id + "_" + @getName()

    a.element = (type) ->
      e = angular.element('#' + @domId(type))
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

    a.getLabelStyles = () ->
      t = @getInputType()
      s = {}
      if t == 'color'
        s = _.extend({}, {'background-color': tinycolor(a.getValue()).toRgbString()})
      return s

    a.getLabelClass = () ->
      t = @getInputType()
      scope = @scope('label')
      c = 'node-arg-label-' + t
      if scope.isOver(@)
        c += ' highlighted'
      if scope.isSelection(@)
        c += ' selected'
      if t == 'icon'
        c += ' cic ' + @getValueOrDefault()
      return c

    a.getInputType = () ->
      if @hasEnum()
        return "enum"
      else if @hasMulti()
        return "multi"
      c = @getComponent()
      if c
        it = c.getInputType()
        if it
          return it
      return "string"


  make: (name, a, node) ->
    @setData(name, a, node)


if define?
  define('vc_arg', [], () ->
    require(['vc_global'], (gd) ->
      ArgClass.VCGlobal = gd
    )
    return ArgClass
  )
else
  ArgClass.VCGlobal = require('./vc_global')
  module.exports = ArgClass
  return ArgClass
