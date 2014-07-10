ComponentClass =

#  @name
#  @desc
#  @extra
#    inherit
#    icon
#    color
#    options
#    accepts []
#    enum []
#    default_children []
#    dependencies []
#    code

  VCGlobal: null

  setData: (c) ->
    if c.clearData
      c.clearData()

    c.$data = {}
    c.$data._inherit = null
    c.$data._accepts = null
    c.$data._default_children = null
    c.$data._parent = null
    c.$data._json = {}
    c.$data._code = {}
    c.$data.isComponent = true

    if c.extra?
      if typeof c.extra is 'string'
        c.$data._json = JSON.parse(c.extra)
      else
        c.$data._json = _.cloneDeep(c.extra)

      code = c.$data._json.code
      if code?
        for k of code
          try
            c.$data._code[k] = eval('(' + code[k] + ')')
          catch e
            console.log e

      if !c.$data._json.default_children
        c.$data._json.default_children = []

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
      return (if @name then @name.toLowerCase() else "")

    c.displayName = () ->
      if @name
        return @name
      else if @getInherit()
        return @getInherit().displayName()
      else
        return "Untitled"

    c.options = () ->
      if @$data and @$data._json.options
        return @$data and @$data._json.options
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
      if @$data and @$data._inherit
        return @$data._inherit
      else if @$data and @$data._json.inherit
        c = ComponentClass.VCGlobal.findComponent(@$data._json.inherit)
        @$data._inherit = c
        return c
      else
        return null

    c.isInherit = () ->
      @getInherit() != null

    c.hasParent = () ->
      @getParent() != null

    c.getParent = () ->
      if @$data
        return @$data._parent
      else
        return null

    c.hasEnum = () ->
      @getEnum().length

    c.getEnum = () ->
      l = []

      e = @$data and @$data._json.enum
      if e
        if typeof e is 'string'
          l = e.split(',')
        else if e instanceof Array
          l = e
      else if @isInherit()
        l = @getInherit().getEnum()

      nl = []

      for i in [0..l.length - 1]
        ii = l[i]
        if ii
          if ii.startsWith('#')
            nl = nl.concat(ComponentClass.VCGlobal.findComponentsOfKind(ii.substr(1)))
          else if ii.toLowerCase() == '@module'
            nl = nl.concat(ComponentClass.VCGlobal.modules.rows)
          else if ii.startsWith('@')
            nl = nl.concat(ComponentClass.VCGlobal.findNodesOfKind(ii.substr(1)))
          else
            nl.push(ii)

      return nl

    c.getAccepts = () ->
      if @$data and @$data._accepts
        r = @$data._accepts
#      else if @isInherit()
#        return @getInherit().getAccepts()
      else
        na = []
        if @$data and @$data._json.accepts
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
        if @$data
          @$data._accepts = na
        r = na

#      for cc in ComponentClass.VCGlobal.components
#        if cc.hasParent()
#          if cc.getParent() == @
#            r.push({ parent: [], component: cc})

      return r

    c.getInheritedAccepts = () ->
      l = [].concat(@getAccepts())
      if @isInherit()
        l = l.concat(@getInherit().getAccepts())
      return l

    c.doAccept = (node, cc) ->
      cc = ComponentClass.VCGlobal.findComponent(cc)
      if cc
        for a in @getInheritedAccepts()
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

    c.getDefaultChildren = () ->
      if @$data and @$data._default_children
        return @$data._default_children
      else if @isInherit()
        return @getInherit().getDefaultChildren()
      else
        na = []
        if @$data and @$data._json.default_children
          for i in @$data._json.default_children
            na.push(ComponentClass.VCGlobal.findComponent(i.component))
        if @$data
          @$data._default_children = na
        return na

    c.hasDefaultChildren = () ->
      @getDefaultChildren().length

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
      if @$data and @$data._json.color
        return @$data._json.color
      else if @isInherit()
        return @getInherit().getColor()

    c.getIcon = () ->
      if @$data and @$data._json.icon
        return @$data._json.icon
      else if @isInherit()
        return @getInherit().getIcon()

    c.parentIcon = () ->
      if @hasOption('p')
        return true
      else if @isInherit()
        return @getInherit().parentIcon()

    c.code = () ->
      if @$data and @$data._code
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

    c.doGenerate = (node, client) ->
      g = @generate()
      if g
        g.call(@, node, (if client? then client else false))

    c.element = () ->
      e = angular.element('#component-element_' + @id())
      if e and e.length
        return e
      else
        return null

    c.scope = () ->
      e = @element()
      if e
        scope = e.scope()
        return scope
      return null


  make: (c) ->
    @setData(c)

    n = c.name
    x = n.indexOf('.')
    if x != -1
      n1 = n.substr(0, x)
      c.name = n.substr(x + 1)
      c.$data._parent = @VCGlobal.findComponent(n1)

  list: (selected) ->
    l = []
    if @VCGlobal.components
      for c in @VCGlobal.components
        if c.$data and c.isVisible()
          if !selected and !c.hasParent()
            l.push(c)
          else if selected and selected.getComponent().doAccept(selected, c)
            l.push(c)
    return l

  elements: () ->
    e = angular.element('#editor-components-root')
    if e and e.length
      return e
    else
      return null

  scope: () ->
    e = @elements()
    if e
      scope = e.scope()
      return scope
    return null


if define?
  define('vc_component', ['vc_global'], (gd) ->
    ComponentClass.VCGlobal = gd
    return ComponentClass
  )
else
  ComponentClass.VCGlobal = require('./vc_global')
  module.exports = ComponentClass
