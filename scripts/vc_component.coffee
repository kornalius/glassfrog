ComponentClass =

#  @name
#  @desc
#  @extra
#    display
#    default
#    category
#    inputType    (string, number, boolean, date, color)
#    inherit
#    icon
#    color
#    options
#    args {}
#    accepts []
#    enum []
#    defaults []
#    code

  VCGlobal: null
  VCNode: null
  VCArg: null

  setData: (c) ->
    if c.clearData
      c.clearData()

    c.$data = {}
    c.$data._inherit = null
    c.$data._args = null
    c.$data._accepts = null
    c.$data._defaults = null
    c.$data._link = null
    c.$data._json = {}
    c.$data._code = {}
    c.$data._components = []
    c.$data.isComponent = true

    if c.extra?
      if type(c.extra) is 'string'
        c.$data._json = stringToJson(c.extra)
      else
        c.$data._json = _.cloneDeep(c.extra)

      code = c.$data._json.code
      if code?
        for k of code
          try
            c.$data._code[k] = eval('(' + code[k] + ')')
          catch e
            console.log e


    c.hasData = () ->
      return @hasOwnProperty('$data')

    c.clearData = () ->
      if @hasData()
        delete @$data

    c.id = () ->
      @_id

    c.getName = () ->
      if @isLink()
        n = @getLink()
        if n
          return n.getName().toLowerCase()
      return (if @name then @name.toLowerCase() else "")

    c.displayName = () ->
      if @isLink()
        n = @getLink()
        if n
          return n.displayName()
      if @$data and @$data._json and @$data._json.display
        return @$data._json.display
      else if @name
        return @name.split('.').pop()
      else
        i = @getInherit()
        if i
          return i.displayName()
        else
          return "Untitled"

    c.getLinkedComponent = () ->
      n = @getLink()
      if n and n.$data and n.$data.isNode and n.getComponent()
        return n.getComponent()
      else
        return null

    c.isCategory = () ->
      @hasOption('c')

    c.hasCategory = () ->
      @getCategory()

    c.isInCategory = (name) ->
      cat = @getCategory()
      return cat and cat.getName() == name

    c.getCategory = () ->
      if @$data and @$data._json.category
        cc = ComponentClass.VCGlobal.findComponent(@$data._json.category)
        return (if cc and cc.isCategory() then cc else null)
      else if @isLink()
        cc = @getLinkedComponent()
        if cc
          return cc.getCategory()
      else
        i = @getInherit()
        if i
          return i.getCategory()
        else
          return null

    c.getCategories = () ->
      l = []
      cc = @getCategory()
      while cc
        l.push(cc)
        cc = cc.getCategory()
      return l

    c.getComponents = (components) ->
      l = []
      if @isCategory()
        n = @getName()
        if components?
          cmps = components
        else
          cmps = ComponentClass.VCGlobal.components
        for cc in cmps
          if cc != @ and cc.isVisible()
            if cc.isInCategory(n) and l.indexOf(cc) == -1
              l.push(cc)
              if cc.isCategory()
#                debugger
                cc.$data._components = cc.getComponents(cmps)
      return l

    c.getDesc = () ->
      if @isLink()
        n = @getLink()
        if n
          return n.getDesc()
      return (if @desc then @desc else "")

    c.getDefault = () ->
      if @isLink()
        n = @getLink()
        if n and n.$data and n.$data.isComponent
          return n.getDefault()
      if @$data._json.default?
        return @$data._json.default
      else
        i = @getInherit()
        if i
          return i.getDefault()
        else
          return null

    c.options = () ->
      if @$data and @$data._json.options
        return @$data and @$data._json.options
#      i = @getInherit()
#      else if i
#        return i.options()
      else
        return ''

    c.hasOption = (s) ->
      o = @options()
      if o?
        o.indexOf(s) > -1
      else
        return false

    c.getInherit = () ->
      if @isLink()
        cc = @getLinkedComponent()
        if cc
          return cc.getInherit()
      if @$data and @$data._inherit
        return @$data._inherit
      else if @$data and @$data._json.inherit
        c = ComponentClass.VCGlobal.findComponent(@$data._json.inherit)
        @$data._inherit = c
        return c
      else return null

    c.isObject = () ->
      @kindOf('Object')

    c.isRef = () ->
      @kindOf('ObjectRef')

    c.isProperty = () ->
      @kindOf('Property')

    c.isMethod = () ->
      @kindOf('Method')

    c.isInherit = () ->
      @getInherit() != null

    c.hasEnum = () ->
      l = []
      e = @$data and @$data._json.enum
      if e
        if type(e) is 'string'
          l = e.split(',')
        else if e instanceof Array
          l = e
      else
        i = @getInherit()
        if i
          return i.hasEnum()
      return l and l.length

    c.getEnum = (node, asObject) ->
      l = []
      e = @$data and @$data._json.enum
      if e
        if type(e) is 'string'
          l = e.split(',')
        else if e instanceof Array
          l = e
      else
        i = @getInherit()
        if i
          l = i.getEnum(node, asObject)
      return ComponentClass.VCGlobal.enumToList(l, node, asObject)

    c.hasArgs = () ->
      if @$data and @$data._json.args
        return true
      else
        i = @getInherit()
        if i
          return i.hasArgs()

    c.getArg = (name) ->
      return @getArgs()[name]

    c.getArgs = () ->
      if @$data and @$data._args
        return @$data._args
      else
        if @$data and @$data._json.args
          na = {}
          if @$data and @$data._json.args
            for k of @$data._json.args
              a = _.cloneDeep(@$data._json.args[k])
              ComponentClass.VCArg.setData(k, a, null)
              na[k] = a
          if @$data
            @$data._args = na
          return na
        else
          i = @getInherit()
          if i
            return i.getArgs()

    c.argToString = (a, user) ->
      if type(a) is 'string'
        a = @getArg(a)
      if a
        return a.getName()
      else
        return ""

    c.argsToString = (user) ->
      d = []
      for a in @argsToArray()
        d.push(@argToString(a, user))
      return d.join(', ')

    c.argsToArray = () ->
      d = []
      for k of @getArgs()
        d.push(@getArgs()[k])
      return d

    c.getAccepts = () ->
      if @$data and @$data._accepts
        r = @$data._accepts
      else
        na = []
        if @$data and @$data._json.accepts
          for i in @$data._json.accepts
            a = _.clone(i)
            a.component = ComponentClass.VCGlobal.findComponent(i.component)
            na.push(a)
        if @$data
          @$data._accepts = na
        r = na

      return r

    c.getInheritedAccepts = () ->
      l = []
      for a in @getAccepts()
        if a.inherited
          i = @getInherit()
          if i
            l = l.concat(i.getInheritedAccepts())
        else
          l.push(a)
      return l

    c.doAccept = (node, cc) ->
      cc = ComponentClass.VCGlobal.findComponent(cc)
      if cc
        for a in @getInheritedAccepts()
          if a.component
            if a.strict
              ok = (a.component.getName() == cc.getName()) or (!a.component and !node)
            else
              ok = cc.kindOf(a.component.name) or (!a.component and !node)
            if ok
              if a.reject
                continue
              ch = node.childrenOfKind(a.component.name)
              if ok and ch.length
                if !a.multi
                  ok = false
                else if a.unique
                  ccn = cc.getName()
                  for n in ch
                    if n.getComponent().getName() == ccn
                      ok = false
                      break

            if ok
              return true

      return false

    c.getDefaults = () ->
      if @$data and @$data._defaults
        return @$data._defaults
      else
        na = []
        i = @getInherit()
        if i
          na = i.getDefaults()
        else
          if @$data and @$data._json.defaults
            for i in @$data._json.defaults
              if type(i) is 'string'
                cc = ComponentClass.VCGlobal.findComponent(i)
                if cc
                  ni = { name: i, component: cc, args: {} }
                else
                  ni = null
              else
                cc = ComponentClass.VCGlobal.findComponent(i.name)
                if cc
                  ni = _.cloneDeep(i)
                  ni.component = cc
                  if !ni.args?
                    ni.args = {}
                else
                  ni = null

              if ni
                na.push(ni)

          if @$data
            @$data._defaults = na

        return na

    c.hasDefaults = () ->
      @getDefaults().length

    c.isLocked = () ->
      if @hasOption('!')
        return true
      else
        i = @getInherit()
        if i
          return i.isLocked()
        else
          return false

    c.isVisible = () ->
      !@hasOption('h')
#      if !@hasOption('h')
#        return true
#      else
#        i = @getInherit()
#        if i
#          return i.isVisible()
#        else
#          return false

    c.isFolder = () ->
      @hasOption('f')
#      if @hasOption('f')
#        return true
#      else
#        i = @getInherit()
#        if i
#          return i.isFolder()
#        else
#          return false

    c.isParentIcons = () ->
      if @hasOption('p')
        return true
      else
        i = @getInherit()
        if i
          return i.isParentIcons()
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
        i = @getInherit()
        return @getName() == name.toLowerCase() or i?.kindOf(name)

    c.isLink = () ->
      @hasOption('l')

    c.getLink = () ->
      if @isLink()
        if @$data and !@$data._link and @name
          n = ComponentClass.VCGlobal.find(@name, true)
          if n and n.$data
            @$data._link = n
        return (if @$data and @$data._link then @$data._link else null)
      else
        return null

#    c.setLink = (n) ->
#      if !n and @$data
#        @delOption('l')
#        delete @name
#        @$data._link = null
#        return true
#      else
#        n = ComponentClass.VCGlobal.find(n)
#        if n and @$data and n != @$data._link
#          @addOption('l')
#          @name = n.id()
#          @$data._link = n
#          return true
#        else
#          return false

    c.getColor = () ->
      if @isLink()
        n = @getLink()
        if n
          return n.getColor()
      if @$data and @$data._json.color
        return @$data._json.color
      else
        i = @getInherit()
        if i
          return i.getColor()
        else
          return null

    c.getIcon = () ->
      if @isLink()
        n = @getLink()
        if n
          return n.getIcon()
      if @$data and @$data._json.icon
        return @$data._json.icon
      else
        i = @getInherit()
        if i
          return i.getIcon()
        else
          return null

    c.getInputType = () ->
      if @$data and @$data._json and @$data._json.inputType
        return @$data._json.inputType
      else
        if @hasEnum()
          return "enum"
        else
          n = @displayName().toLowerCase()
          if n == 'number' or n == 'boolean' or n == 'datetime' or n == 'date' or n == 'time' or n == 'color' or n == 'icon'
            return n
          else
            return "string"

        i = @getInherit()
        if i
          return i.getInputType()

    c.parentIcon = () ->
      if @hasOption('p')
        return true
      else
        i = @getInherit()
        if i
          return i.parentIcon()
        else
          return false

    c.code = (name) ->
      if @$data and @$data._code
        names = name.split(',')
        for n in names
          if @$data._code[n]
            return @$data._code[n]
      i = @getInherit()
      if i
        return i.code(name)
      else
        return null

    c.hasCode = (name) ->
      @code(name) != null

    c.renderCode = () ->
      @code("render")

    c.hasRenderCode = () ->
      @renderCode() != null

    c.render = (node) ->
      r = @renderCode()
      if r
        that = @
        window.setTimeout(->
          r.call(that, node)
        )

    c.hasClientCode = () ->
      @clientCode() != null

    c.clientCode = () ->
      @code("client,both")

    c.hasServerCode = () ->
      @serverCode() != null

    c.serverCode = () ->
      @code("server,both")

    c.generateCode = (node, client, user) ->
      s = ""
      if client
        g = @clientCode()
        if g
          s = g.call(@, node)
      else
        g = @serverCode()
        if g
          s = g.call(@, node, user)
      if !s
        s = ''
      return s

    c.newContext = () ->
      return @kindOf(['Object', 'ObjectRef'])

    c.domName = (type) ->
      if !type?
        type = 'element'
      'component-' + type + '_' + @getName()

    c.domId = (type) ->
      if !type?
        type = 'element'
      'component-' + type + '-id_' + @id()

    c.element = (type) ->
      e = angular.element('#' + @domId(type))
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

    c.setDefaults = (node) ->
      if @hasDefaults()
        for d in @getDefaults()
          if d.value?
            _name = d.value
          else
            _name = null
          nn = d.component.add(_name, node, module)
          if nn and d.args
            for k in Object.keys(d.args)
              nn.setArg(k, d.args[k])

      if @hasArgs()
        for a in @argsToArray()
          node.setArg(a.getName(), a.getDefault())


    c.newNode = (name, parent, module, args) ->
      if !name?
        dv = @getDefault()
        if dv
          name = dv
        else
          dv = @displayName()

      n = { name: name, component: @name }

      if @isLink()
        i = @getInherit()
        if i
          n.component = i.name
          n.options = 'l'

      ComponentClass.VCNode.make(n, parent, module)

      @setDefaults(n)

      if args
        for k in Object.keys(args)
          n.setArg(k, args[k])

      n.setNew(true)

      return n

    c.add = (name, parent, module, args) ->
      n = @newNode(name, parent, module, args)
      if parent
        parent.nodes.push(n)
      return n


  make: (c) ->
    @setData(c)

  list: (selected, module) ->
    l = []

    if module
      for n in module.getRoot().children(true)
#        if n.$data and n.kindOf('Object') and (!selected or (selected.getComponent() and selected.getComponent().doAccept(selected, n.getComponent().name + 'Ref')))
        if n.$data and n.kindOf('Object')
          c =
            name: n.id()
            extra:
              category: 'ObjectsRef'
              options: 'l'
              inherit: (if n.getComponent() then n.getComponent().name + 'Ref' else "")
          @make(c)
          l.push(c)

    if @VCGlobal.modules.rows
      for m in @VCGlobal.modules.rows
#          if m.$data and (!selected or (selected.getComponent() and selected.getComponent().doAccept(selected, 'ModuleRef')))
        if m.$data
          c =
            name: m.id()
            extra:
              category: 'ModulesRef'
              options: 'l'
              inherit: 'ModuleRef'
          @make(c)
          l.push(c)

    if @VCGlobal.components
      for c in @VCGlobal.components
        if c.isVisible()
#            if selected and selected.getComponent() and selected.getComponent().doAccept(selected, c)
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
  define('vc_component', ['vc_global', 'vc_node', 'vc_arg'], (gd, nd, ad) ->
#    require(['vc_global', 'vc_node', 'vc_arg'], (gd, nd, ad) ->
    ComponentClass.VCGlobal = gd
    ComponentClass.VCNode = nd
    ComponentClass.VCArg = ad
    return ComponentClass
  )
else
  ComponentClass.VCGlobal = require('./vc_global')
  ComponentClass.VCNode = require('./vc_node')
  ComponentClass.VCArg = require('./vc_arg')
  module.exports = ComponentClass
  return ComponentClass
