ComponentClass =

#  @name
#  @desc
#  @extra
#    inherit
#    icon
#    color
#    options
#    args []
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

      if !c.$data._json.defaults
        c.$data._json.defaults = []

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
      if @isLink()
        n = @getLink()
        if n and n.name
          return n.name.toLowerCase()
      return (if @name then @name.toLowerCase() else "")

    c.displayName = () ->
      if @name
        if @isLink()
          n = @getLink()
          if n
            return n.displayName()
        return @name.split('.').pop()
      else
        i = @getInherit()
        if i
          return i.displayName()
        else
          return "Untitled"

    c.getDesc = () ->
      if @isLink()
        n = @getLink()
        if n and n.desc
          return n.desc
      return (if @desc then @desc else "")

    c.getDefaultValue = () ->
      if @isLink()
        n = @getLink()
        if n
          dv = n.getDefaultValue()
          if dv
            return dv
      if @$data._json.defaultValue
        return @$data._json.defaultValue
      else
        i = @getInherit()
        if i
          return i.getDefaultValue()
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
      if @$data and @$data._inherit
        return @$data._inherit
      else if @$data and @$data._json.inherit
        c = ComponentClass.VCGlobal.findComponent(@$data._json.inherit)
        @$data._inherit = c
        return c
      else
        return null

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
      @getEnum().length

    c.getEnum = () ->
      l = []

      i = @getInherit()

      e = @$data and @$data._json.enum
      if e
        if typeof e is 'string'
          l = e.split(',')
        else if e instanceof Array
          l = e
      else if i
        l = i.getEnum()

      nl = []

      for i in [0..l.length - 1]
        ii = l[i]
        if ii and typeof ii is 'string'
          if ii.startsWith('#')
            nl = nl.concat(ComponentClass.VCGlobal.findComponentsOfKind(ii.substr(1)))
          else if ii.toLowerCase() == '@module'
            nl = nl.concat(ComponentClass.VCGlobal.modules.rows)
          else if ii.startsWith('@')
            nl = nl.concat(ComponentClass.VCGlobal.findNodesOfKind(ii.substr(1)))
          else
            nl.push(ii)

      return nl

    c.isMultiArgs = () ->
      @hasOption('m')

    c.hasArgs = () ->
      return !@$data or !@$data._json.args

    c.args = () ->
      if !@hasArgs() or @isMultiArgs()
        return []
      else
        if @$data and @$data._args
          r = @$data._args
        else
          na = []
          if @$data and @$data._json.args
            for a in @$data._json.args
              aa = _.cloneDeep(a)
              ComponentClass.VCArg.setData(aa)
              na.push(aa)
          if @$data
            @$data._args = na
          r = na
        return r

    c.getAccepts = () ->
      if @$data and @$data._accepts
        r = @$data._accepts
      else
        na = []
        if @$data and @$data._json.accepts
          for i in @$data._json.accepts
            a = { restrict: [], component: ComponentClass.VCGlobal.findComponent(i.component), multi: false }
            if i.restrict and i.restrict.length
              for pi in i.restrict
                if pi.endsWith('+')
                  a.multi = true
                  pi = pi.substr(0, pi.length - 1)
                ppi = ComponentClass.VCGlobal.findComponent(pi)
                if ppi
                  a.restrict.push(ppi)
                else
                  console.log "Component '{0}' not found".format(pi)
            na.push(a)
        if @$data
          @$data._accepts = na
        r = na

      return r

    c.getInheritedAccepts = () ->
      l = [].concat(@getAccepts())
      i = @getInherit()
      if i
        l = l.concat(i.getAccepts())
      return l

    c.doAccept = (node, cc) ->
      cc = ComponentClass.VCGlobal.findComponent(cc)
      if cc
        for a in @getInheritedAccepts()
          if a.component
            ok = cc.kindOf(a.component.name) or (!a.component and !node)
            if ok and !a.multi and node.childrenOfKind(a.component.name).length
              ok = false
            cp = a.restrict
            if ok and node and cp.length
              p = node.getParent()
              i = cp.length - 1
              while p and i >= 0
                if cp[i] and p.getComponent() and p.getComponent().kindOf(cp[i].name)
                  i--
                else
                  break
                p = p.getParent()
              ok = (i == -1)

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
              if typeof i is 'string'
                cc = ComponentClass.VCGlobal.findComponent(i)
                if cc
                  ni = { name: i, component: cc }
                else
                  ni = null
              else
                cc = ComponentClass.VCGlobal.findComponent(i.name)
                if cc
                  ni = _.cloneDeep(i)
                  ni.component = cc
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
      if !@hasOption('h')
        return true
      else
        i = @getInherit()
        if i
          return i.isVisible()
        else
          return false

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
        return @getName() == name.toLowerCase() or (i and i.kindOf(name))

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

    c.setLink = (n) ->
      if !n and @$data
        @delOption('l')
        delete @name
        @$data._link = null
        return true
      else
        n = ComponentClass.VCGlobal.find(n)
        if n and @$data and n != @$data._link
          @addOption('l')
          @name = n.id()
          @$data._link = n
          return true
        else
          return false

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
        if @$data._code[name]
          return @$data._code[name]
      i = @getInherit()
      if i
        return i.code(name)
      else
        return null

    c.hasCode = (name) ->
      @code(name) != null

    c.string = () ->
      @code("string")

    c.hasString = () ->
      @string() != null

    c.render = () ->
      @code("render")

    c.hasRender = () ->
      @render() != null

    c.doRender = (node) ->
      r = @render()
      if r
        that = @
        window.setTimeout(->
          r.call(that, node)
        )

    c.generate = () ->
      @code("generate")

    c.hasGenerate = () ->
      @generate() != null

    c.doGenerate = (node, client) ->
      s = ""
      g = @generate()
      if g
        if node and node.$data and !node.$data._arg
          d = [node.id()]
          for n in node.args
            d.push(n.id())
          s = "// id::" + d.join(',') + "\n"
        s += g.call(@, node, (if client? then client else false))
      return s

    c.run = () ->
      if @hasRun()
        @code().run
      else
        return null

    c.newContext = () ->
      return @kindOf(['Object', 'ObjectRef'])

    c.hasRun = () ->
      @run() != null

    c.doRun = (node, client, args, cb) ->
      r = @run()
      if r
        r.call(@, node, (if client? then client else false), args, (res) ->
          cb(res)
        )
      else
        cb(null)

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

    c.add = (name, module, parent, args) ->
      if !name?
        dv = @getDefaultValue()
        if dv
          name = dv

      n = { name: name, component: @name }

      if @isLink()
        i = @getInherit()
        if i
          n.component = i.name
          n.options = 'l'

      ComponentClass.VCNode.make(n, parent, module)

      if !args
        args = {}

      if @hasDefaults()
        for d in @getDefaults()
          if d.value?
            _name = d.value
          else
            d.component.name
          d.component.add(_name, module, n)

      if @hasArgs()
        if @isMultiArgs()
          n.args = args
        for a in @args()
          if a.required()
            n.args[a.name] = a.default()

      n.setNew(true)

      return n


  make: (c) ->
    @setData(c)

  list: (selected, module) ->
    l = []

    if module
      for n in module.getRoot().children(true)
        if n.$data and n.kindOf('Object') and (!selected or (selected.getComponent() and selected.getComponent().doAccept(selected, n.getComponent().name + 'Ref')))
          c =
            name: n.id()
            extra:
              options: 'l'
              inherit: (if n.getComponent() then n.getComponent().name + 'Ref' else "")
          @make(c)
          l.push(c)

      if @VCGlobal.modules.rows
        for m in @VCGlobal.modules.rows
          if m.$data and (!selected or (selected.getComponent() and selected.getComponent().doAccept(selected, 'ModuleRef')))
            c =
              name: m.id()
              extra:
                options: 'l'
                inherit: 'ModuleRef'
            @make(c)
            l.push(c)

      if @VCGlobal.components
        for c in @VCGlobal.components
          if c.$data and c.isVisible()
            if selected and selected.getComponent() and selected.getComponent().doAccept(selected, c)
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
