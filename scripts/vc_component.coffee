ComponentClass =

#  @name
#  @desc
#  @extra
#    inherit
#    icon
#    color
#    options
#    accepts []
#    default_children
#    valueKind
#    code
#    properties []
#    dependencies []

  VCGlobal: null
  ComponentProperty: null

  setData: (c) ->
    if c.clearData
      c.clearData()

    c.$data = {}
    c.$data._inherit = null
    c.$data._accepts = null
    c.$data._valueKind = null
    c.$data._json = {}
    c.$data._code = {}
    c.$data.isComponent = true

    if c.extra?
      c.$data._json = JSON.parse(c.extra)

      code = c.$data._json.code
      if code?
        for k of code
          try
            c.$data._code[k] = eval('(' + code[k] + ')')
          catch e
            console.log e

      if !c.$data._json.properties
        c.$data._json.properties = []

      if !c.$data._json.dependencies
        c.$data._json.dependencies = []


    c.hasData = () ->
      return @hasOwnProperty('$data')

    c.clearData = () ->
      if @hasData()
        delete @$data

    c.id = () ->
      @_id

    c.getName = () ->
      @name.toLowerCase()

    c.options = () ->
      if @$data._json.options
        return @$data._json.options
#      else if @isInherit()
#        return @inherit().options()
      else
        return ''

    c.hasOption = (s) ->
      o = @options()
      if o?
        o.indexOf(s) > -1
      else
        return false

    c.getInherit = () ->
      if @$data._inherit
        return @$data._inherit
      else if @$data._json.inherit
        c = ComponentClass.VCGlobal.findComponent(@$data._json.inherit)
        @$data._inherit = c
        return c
      else
        return null

    c.isInherit = () ->
      return @getInherit()

    c.isValueKind = () ->
      @valueKind()

    c.valueKind = () ->
      if @$data._valueKind
        return @$data._valueKind
      else if @isInherit()
        return @getInherit().valueKind()
      else
        if @$data._json.valueKind
          c = ComponentClass.VCGlobal.findComponent(@$data._json.valueKind)
          @$data._valueKind = c
        else
          c = null
        return c

    c.getAccepts = () ->
      if @$data._accepts
        return @$data._accepts
      else if @isInherit()
        return @getInherit().getAccepts()
      else
        na = []
        if @$data._json.accepts
          for i in @$data._json.accepts
            a = { parent: [], component: ComponentClass.VCGlobal.findComponent(i.component)}
            if i.parent and i.parent.length
              for pi in i.parent
                ppi = ComponentClass.VCGlobal.findComponent(pi)
                if ppi
                  a.parent.push(ppi)
                else
                  console.log "Component '{0}' not found".format(pi)
            na.push(a)
        @$data._accepts = na
        return na

    c.inheritedAccepts = () ->
      l = [].concat(@getAccepts())
      if @isInherit()
        l = l.concat(@getInherit().getAccepts())
      return l

    c.doAccept = (node, cc) ->
      cc = ComponentClass.VCGlobal.findComponent(cc)
      if cc
        for a in @inheritedAccepts()
          if a.component
            ok = cc.kindOf(a.component.name) or (!a.component and !node)
            cp = a.parent
            if ok and node and cp.length
              p = node.getParent()
              i = cp.length - 1
              while p and i >= 0
                if cp[i] and p.getComponent().kindOf(cp[i].name)
                  i--
  #                if pc.kindOf('Module')
  #                  break
                else
                  break
                p = p.getParent()
              ok = (i == -1)

            if ok
              return true

      return false

    c.isLocked = () ->
      if @hasOption('l')
        return true
      else if @isInherit()
        return @getInherit().isLocked()
      else
        return false

    c.isVisible = () ->
      if !@hasOption('h')
        return true
      else if @isInherit()
        return @getInherit().isVisible()
      else
        return false

    c.isParentIcons = () ->
      if @hasOption('p')
        return true
      else if @isInherit()
        return @getInherit().isParentIcons()
      else
        return false

    c.canEdit = () ->
      return !@isLocked()

    c.kindOf = (name) ->
      if name instanceof Array
        for n in name
          if @kindOf(n)
            return true
        return false
      else
        return @getName() == name.toLowerCase() or (@isInherit() and @getInherit().kindOf(name))

    c.getColor = () ->
      if @$data._json.color
        return @$data._json.color
      else if @isInherit()
        return @getInherit().getColor()

    c.getIcon = () ->
      if @$data._json.icon
        return @$data._json.icon
      else if @isInherit()
        return @getInherit().getIcon()

    c.parentIcon = () ->
      if @hasOption('p')
        return true
      else if @isInherit()
        return @getInherit().parentIcon()

    c.code = () ->
      if @$data._code
        return @$data._code
      else if @isInherit()
        return @getInherit().code()
      else
        return {}

    c.hasCode = () ->
      c = @code()
      return (typeof c is 'object') and Object.keys(c).length > 0

    c.string = () ->
      if @hasCode()
        @code().string
      else
        return null

    c.hasString = () ->
      @string() != null

    c.render = () ->
      if @hasCode()
        @code().render
      else
        return null

    c.hasRender = () ->
      @render() != null

    c.doRender = (node) ->
      r = @render()
      if r
        that = @
        window.setTimeout(->
          r.call(that, node)
        , 0.1)

    c.generate = () ->
      if @hasCode()
        @code().generate
      else
        return null

    c.hasGenerate = () ->
      @generate() != null

    c.doGenerate = (node) ->
      g = @generate()
      if g
        g.call(@, node)

    c.hasProperty = (name) ->
      @getProperty(name)?

    c.getProperty = (name) ->
      name = name.toLowerCase()
      for cp in @getProperties()
        if cp.getName() == name
          return cp
      return null

    c.getProperties = () ->
      @$data._json.properties

    c.hasProperties = () ->
      @getProperties().length

    c.foreachProperty = (f) ->
      if @hasProperties()
        for p in @getProperties()
          f(p)

    c.getIn = () ->
      @foreachProperty((p) ->
        if p.isIn()
          return p
      )
      return null

    c.getOut = () ->
      @foreachProperty((p) ->
        if p.isOut()
          return p
      )
      return null

    c.getInAccepts = () ->
      i = @getIn()
      if i
        return i.inheritedAccepts()
      else
        return []

    c.getOutAccepts = () ->
      o = @getOut()
      if o
        return o.inheritedAccepts()
      else
        return []

    c.acceptsMatch = (ia, oa) ->
      for i in ia
        for o in oa
          if i.component.kindOf(o.component.name)
            return true
      return false


  make: (c) ->
    @setData(c)
    that = @
    c.foreachProperty((p) ->
      that.ComponentProperty.make(p, c)
    )

  list: (selected) ->
    l = []
    if @VCGlobal.components
      for c in @VCGlobal.components
        if c.$data and c.isVisible() and (!selected or selected.component.doAccept(selected, c))
          l.push(c)
    return l


if define?
  define('vc_component', ['vc_global', 'vc_componentproperty'], (gd, cpd) ->
    ComponentClass.VCGlobal = gd
    ComponentClass.ComponentProperty = cpd
    return ComponentClass
  )
else
  ComponentClass.VCGlobal = require('./vc_global')
  ComponentClass.ComponentProperty = require('./vc_componentproperty')
  module.exports = ComponentClass
