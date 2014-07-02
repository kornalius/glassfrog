
ComponentPropertyClass =

#  name
#  desc
#  icon
#  color
#  type (string, number, boolean, date, color, select, label, array)
#  default
#  accepts []
#  enum []
#  options
#  code

  VCGlobal: null

  setData: (p, component) ->
    if p.clearData
      p.clearData()

    p.$data = {}
    p.$data._component = component
    p.$data._accepts = null
    p.$data._code = {}
    p.$data.isComponentProperty = true

    code = p.code
    if code?
      for k of code
        try
          p.$data._code[k] = eval('(' + code[k] + ')')
        catch e
          console.log e


    p.hasData = () ->
      @hasOwnProperty('$data')

    p.clearData = () ->
      if @hasData()
        delete @$data

    p.hasEnum = () ->
      @getEnum().length

    p.getEnum = (module) ->
      if @enum
        l = @enum.split(',')
        for e in l
          if e.startsWith('#')
            cl = ComponentPropertyClass.VCGlobal.findComponentsOfKind(e.substring(1))
            for c in cl
              l.push(c.name)
          else if e.startsWith('@') and module
            r = module.getRoot()
            if r
              cl = r.childrenOfKind(e.substring(1))
              for c in cl
                l.push(c.path(true))
          else
            l.push(e)
      else
        return []

    p.hasOption = (s) ->
      if @options?
        @options.indexOf(s) > -1
      else
        return false

    p.getName = () ->
      @name.toLowerCase()

    p.getDesc = () ->
      @desc

    p.getType = () ->
      @type.toLowerCase()

    p.getColor = () ->
      @color

    p.getIcon = () ->
      @icon

    p.getDefault = () ->
      @default

    p.isOptional = () ->
      @hasOption('o')

    p.isInline = () ->
      @hasOption('i')

    p.isSelect = () ->
      @getType() == 'select'

    p.isString = () ->
      @getType() == 'string'

    p.isNumber = () ->
      @getType() == 'number'

    p.isBoolean = () ->
      @getType() == 'boolean'

    p.isDate = () ->
      @getType() == 'date'

    p.isColor = () ->
      @getType() == 'color'

    p.isArray = () ->
      @getType() == 'array'

    p.isExpr = () ->
      @getType() == 'expr'

    p.isLabel = () ->
      @getType() == 'label'

    p.getLabel = () ->
      if @isLabel()
        return @getDefault()
      else
        return ''

    p.isInput = () ->
      return @isString() or @isNumber() or @isSelect() or @isExpr() or @isArray()

    p.isIn = () ->
      @hasOption('i')

    p.isOut = () ->
      @hasOption('o')

    p.showValue = () ->
      !@isExpr() and !@isArray()

    p.showInput = () ->
      @isInput()

    p.showIcons = () ->
      @isExpr() or @isArray()

    p.showExpand = () ->
      @isExpr() or @isArray()

    p.getAccepts = () ->
      if @$data._accepts
        return @$data._accepts
      else
        na = []
        if @accepts
          for i in @accepts
            a = { parent: [], component: ComponentPropertyClass.VCGlobal.findComponent(i.component)}
            if i.parent and i.parent.length
              for pi in i.parent
                ppi = ComponentPropertyClass.VCGlobal.findComponent(pi)
                if ppi
                  a.parent.push(ppi)
                else
                  console.log "Component '{0}' not found".format(pi)
            na.push(a)
        @$data._accepts = na
        return na

    p.doAccept = (cc) ->
      console.log "ComponentProperty.doAccept()", @, cc
      if cc.$data and cc.$data.isNode
        return @doAccept(cc.getComponent())
      else if typeof cc is 'string' or (cc.$data and cc.$data.isComponent)
        cc = ComponentPropertyClass.VCGlobal.findComponent(cc)
        if cc
          for a in @getAccepts()
            if cc.kindOf(a.component.name) or a.component.getName() == 'object'
              return true
        return false

    p.code = () ->
      if @$data._code
        return @$data._code
      else
        return {}

    p.hasCode = () ->
      c = @code()
      return (typeof c is 'object') and Object.keys(c).length > 0

    p.string = () ->
      if @hasCode()
        @code().string
      else
        return null

    p.hasString = () ->
      @string() != null

    p.render = () ->
      if @hasCode()
        @code().render
      else
        return null

    p.hasRender = () ->
      @render() != null

    p.doRender = (nodeProperty) ->
      r = @render()
      if r
        that = @
        window.setTimeout(->
          r.call(that, nodeProperty)
        , 0.1)

    p.generate = () ->
      if @hasCode()
        @code().generate
      else
        return null

    p.hasGenerate = () ->
      @generate() != null

    p.doGenerate = (nodeProperty) ->
      g = @generate()
      if g
        g.call(@, nodeProperty)


  make: (p, component) ->
    @setData(p, component)


if define?
  define('vc_componentproperty', ['vc_global'], (gd) ->
    ComponentPropertyClass.VCGlobal = gd
    return ComponentPropertyClass
  )
else
  ComponentPropertyClass.VCGlobal = require('./vc_global')
  module.exports = ComponentPropertyClass
