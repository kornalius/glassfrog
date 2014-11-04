NodeClass =

#  _id
#  name
#  icon
#  color
#  component
#  options
#  nodes []
#  args {}

  VCGlobal: null
  VCArg: null

  setData: (n, parent, module) ->
    if n.clearData
      n.clearData()

    if !n._id
      n._id = makeId()

    n.$data = {}
    n.$data._parent = parent
    n.$data._component = null
    n.$data._args = null
    n.$data._module = module
    n.$data._link = null
    n.$data._states = ''
    n.$data.isNode = true
    n.$data._error = null

    if n.nodes
      for nn in n.nodes
        @setData(nn, n, module)
    else
      n.nodes = []


    n.id = () ->
      @_id

    n.getName = () ->
      if @isLink()
        n = @getLink()
        if n
          return n.getName()
      return (if @name then @name.toLowerCase() else "")

    n.setName = (name) ->
      if name and name.$data?
        @setLink(name)
      else if name and type(name) is 'string' and name.match(/^[0-9a-fA-F]{24}$/)
        @setLink(name)
      else
        if @name != name
          if @isLink()
            @setLink(null)
          @name = name
          @setModified(true)

    n.isObject = () ->
      cc = @getComponent()
      if cc
        return cc.isObject()
      else
        return false

    n.isRef = () ->
      cc = @getComponent()
      if cc
        return cc.isRef()
      else
        return false

    n.isProperty = () ->
      cc = @getComponent()
      if cc
        return cc.isProperty()
      else
        return false

    n.isMethod = () ->
      cc = @getComponent()
      if cc
        return cc.isMethod()
      else
        return false

    n.getDesc = () ->
      if @isLink()
        n = @getLink()
        if n
          return n.getDesc()
      return (if @desc then @desc else "")

    n.order = () ->
      @getParent().nodes.indexOf(@)

    n.setOrder = (o) ->
      i = @order()
      p = @getParent()
      if o != i and o in [0..p.children().length - 1]
        n = o
        if n > i
          n--
        p.nodes.splice(i)
        p.nodes.splice(n, 0, @)
        @setModified(true)

    n.childAt = (idx) ->
      if idx in [0..@children().length - 1]
        return @children()[idx]
      else
        return null

    n.module = () ->
      if @$data and !@$data._module
        @$data._module = NodeClass.VCGlobal.findModule(@module)
      return (if @$data then @$data._module else null)

    n.hasModule = () ->
      @module()

    n.hasParent = () ->
      @getParent()

    n.getParent = () ->
      return (if @$data and @$data._parent then @$data._parent else null)

    n.setParent = (p, idx) ->
      p = NodeClass.VCGlobal.findNode(@module(), p)
      pp = @getParent()
      if p != pp
        i = pp.order(@)
        if i != -1
          pp.nodes.splice(i)
          pp.setModified(true)

        @$data._parent = null

        if p
          if idx? and idx < p.nodes.length - 1
            p.nodes.splice(idx, 0, @)
          else
            p.nodes.push(@)
          @$data._parent = p

        @setModified(true)

    n.getComponent = () ->
      if @$data
        c = @$data._component
      else
        c = null

      if !c
        c = NodeClass.VCGlobal.findComponent(@component)
        @$data._component = c

      if c and c.isLink()
        c = c.getLink()
        if c
          c = c.getComponent()

      return c

    n.setComponent = (c) ->
      c = NodeClass.VCGlobal.findComponent(c)
      if c and @$data
        @$data._component = c
        @component = c.name
        @setModified(true)
        c.setDefaults(@)

    n.hasData = () ->
      return @hasOwnProperty('$data')

    n.clearData = () ->
      if @hasData()
        delete @$data

    n.plainObject = () ->
      o = {}

      for k of @
        if type(@[k]) != 'function' and k != 'nodes' and k != '$data' and k != '$$hashKey'
          o[k] = _.cloneDeep(@[k])

      args = @getArgs()
      if args
        o.args = {}
        for k of args
          v = args[k].getValue()
          if v and v.$data and v.id
            v = v.id()
          o.args[k] = v

#      console.log "plainObject()", @, o

      if @nodes
        o.nodes = []
        for n in @nodes
          o.nodes.push(n.plainObject())

      return o

    n.hasOption = (s) ->
      if @options?
        @options.indexOf(s) > -1
      else
        return false

    n.refreshScope = () ->
      s = @scope()
      if s
        setTimeout(->
          s.$apply()
        )

    n.addOption = (s) ->
      if !@hasOption(s)
        if !@options?
          @options = s
        else
          @options += s
        @setModified(true)
        @refreshScope()

    n.delOption = (s) ->
      if @options?
        i = @options.indexOf(s)
      else
        i = -1
      if i != -1
        @options = @options.substr(0, i) + @options.substr(i + 1)
        @setModified(true)

    n.hasState = (s) ->
      if @$data
        return @$data._states.indexOf(s) > -1
      else
        return null

    n.addState = (s) ->
      if !@hasState(s) and @$data
        @$data._states += s
        @refreshScope()

    n.delState = (s) ->
      if @$data
        i = @$data._states.indexOf(s)
        if i != -1
          @$data._states = @$data._states.substr(0, i) + @$data._states.substr(i + 1)
          @refreshScope()

    n.isSystem = () ->
      cc = @getComponent()
      return cc and cc.isSystem()

    n.isLocked = () ->
      cc = @getComponent()
      return cc and cc.isLocked()

    n.isShared = () ->
      @hasModule() and @module().hasShare()

    n.hasRepo = () ->
      @hasModule() and @module().repo?

    n.canModify = () ->
      !@isLocked() and !@isShared() and !@hasRepo()

    n.canEdit = () ->
      @canModify() and !@isLocked()

    n.domName = (type) ->
      if !type?
        type = 'element'
      'node-' + type + '_' + @getName()

    n.domId = (type) ->
      if !type?
        type = 'element'
      'node-' + type + '-id_' + @id()

    n.element = (type) ->
      if angular
        e = angular.element('#' + @domId(type))
        if e and e.length
          return e
      return null

    n.scope = () ->
      e = @element()
      if e
        scope = e.scope()
        return scope
      return null

    n.isOpened = () ->
      return @hasState('o')

    n.isClosed = () ->
      return !@hasState('o')

    n.canOpen = () ->
      cc = @getComponent()
      return (cc and cc.getInheritedAccepts().length > 0) or @hasChildren()

    n.open = (recursive) ->
      if @canOpen()
        @addState('o')
        s = @scope()
        if s
          s.expand()
        if recursive
          @foreachChild((n) ->
            n.open(true))

    n.close = (recursive) ->
      @delState('o')
      s = @scope()
      if s
        s.collapse()
      if recursive
        @foreachChild((n) ->
          n.close(true))

    n.toggle = (recursive) ->
      if @isOpened()
        @close(recursive)
      else
        @open(recursive)

    n.makeVisible = () ->
      for nn in @ancestors(true)
        nn.open()
      e = @element()
      if e
        m = $('#editor-content-main')
        if m and m.length
          m.scrollTop(0)
          m.scrollTop(e.position().top - (m.height() / 2))


    n.isModified = () ->
      @hasState('m')

    n.setModified = (b) ->
      if b
        @addState('m')
        for n in @ancestors()
          n.addState('m')
        @module().setModified(true)
      else
        @delState('m')

    n.isNew = () ->
      @hasState('n')

    n.setNew = (b) ->
      if b
        @addState('n')
        @setModified(true)
      else
        @delState('n')
        @setModified(true)

    n.getClassName = () ->
      return @varName().camelize(true)

    n.varName = () ->
      vn = @name
      if @isLink()
        n = @getLink()
        if n
          vn = n.varName()
      if !vn
        vn = @displayName()
      return vn.camelize(false)

    n.displayName = () ->
      if @name
        if @isLink()
          n = @getLink()
          if n
            if n.$data and n.$data.isNode
              return n.pathname(true)
            else
              return n.displayName()
        return @name
      else
        cc = @getComponent()
        if cc
          return cc.displayName()
        else
          return "Untitled"

    n.isLink = () ->
      @hasOption('l')

    n.getLink = () ->
      if @isLink()
        if @$data and !@$data._link and @name
          n = NodeClass.VCGlobal.find(@name, true)
          if n and n.$data
            @$data._link = n
        return (if @$data and @$data._link then @$data._link else null)
      else
        return null

    n.setLink = (n) ->
      if !n and @$data
        @delOption('l')
        @$data._link = null
        delete @name
        @setModified(true)
        return true
      else
        n = NodeClass.VCGlobal.find(n)
        if n and @$data and n != @$data._link
          @addOption('l')
          @name = n.id()
          @$data._link = n
          @setModified(true)
          return true
        else
          return false

    n.isRoot = () ->
      @getRoot() == @

    n.getRoot = () ->
      @module().getRoot()

    n.parentOfKind = (name) ->
      if @kindOf(name)
        p = @
      else
        p = @getParent()
        while p
          if !p.getParent() or p.kindOf(name)
            break
          p = p.getParent()
      return p

    n.hasChildren = (onlyStatement) ->
      if onlyStatement?
        return @children(false, true).length
      else
        return @nodes.length

    n.children = (recursive, onlyStatement) ->
      l = []
      if @nodes
        for nn in @nodes
          if nn.$data and nn.$data.isNode
            if (!onlyStatement? or nn.isStatement())
              l.push(nn)
            if recursive
              l = l.concat(nn.children(true, onlyStatement))
      return l

    n.setChildren = (nodes) ->
      @nodes = []

      if nodes
        if type(nodes) is 'string'
          @nodes = stringToJson(nodes)
          @setModified(true)
          p = @getParent()
          NodeClass.make(@, p, p.module())
        else
          try
            @nodes = jsonToString(nodes)
          catch e
            console.log "Error stringifying JSON data", e
          @setModified(true)
          p = @getParent()
          NodeClass.make(@, p, p.module())

    n.childrenOfKind = (name, recursive) ->
      c = []
      for n in @children(recursive)
        if name == '*' or n.kindOf(name)
          c.push(n)
      return c

    n.childrenAsLinks = (recursive) ->
      c = []
      for n in @children(recursive)
        args = n.getArgs()
        for k of args
          if args[k].isLink()
            c.push(args[k])
        if n.isLink()
          c.push(n)
      return c

    n.linkedModules = (recursive) ->
      m = []
      for n in @childrenAsLinks(recursive)
        if n.$data? and n.$data.isArg
          nn = n.getNode()
        else
          nn = n
        if nn and m.indexOf(nn.module()) == -1
          m.push(nn.module())
      return m

    n.ancestors = (hideRoot) ->
      r = @module().getRoot()
      a = []
      p = @
      while p
        if !hideRoot or p != r
          a.unshift(p)
        p = p.getParent()
      return a

    n.ancestorsOfKind = (name, hideRoot) ->
      r = @$data._module.getRoot()
      a = []
      p = @
      while p
        if (!hideRoot or p != r) and p.kindOf(name)
          a.unshift(p)
        p = p.getParent()
      return a

    n.isAncestorOf = (node) ->
      return node.ancestors().indexOf(@) != -1

    n.isChildOf = (node) ->
      return @ancestors().indexOf(node) != -1

    n.siblings = () ->
      if @hasParent()
        return @getParent().nodes
      else
        return null

    n.hasError = () ->
      @$data and @$data._error

    n.error = () ->
      if @hasError()
        return @$data._error
      else
        return null

    n.hasEnum = () ->
      cc = @getComponent()
      if cc
        return cc.hasEnum()
      else
        return false

    n.getEnum = (asObject) ->
      cc = @getComponent()
      if cc
        return cc.getEnum(@, asObject)
      else
        return []

    n.pathname = (display, hideModule) ->
      if display?
        if !hideModule
          l = [@$data._module.displayName()]
        else
          l = []
        return l.concat(@ancestors(true).map((nn) ->
          nn.displayName())).join('.')
      else
        if !hideModule
          l = [@$data._module.id()]
        else
          l = []
        return l.concat(@ancestors().map((nn) ->
          nn.id())).join('#')

    n.path = (_path) ->
      nn = @
      for p in _path.split('.')

        if p == '' # ex: .view.form  or ..schema
          if nn.hasParent()
            nn = nn.getParent()
          else
            nn = null

        else if p.length > 1 and p[0] == ':' and p[1] == ':' # ::module.schema
          m = NodeClass.VCGlobal.findModule(p.substr(2))
          p = ''
          if m
            nn = m.getRoot()

        else if p.length and p[0] == ':' # :schema.field
          p = p.substr(1)
          nn = nn.getRoot()

        if p.length
          if p[0] == '@'  # ex: :@Schema.@Field
            l = nn.childrenOfKind(p.substr(1))
            if l.length
              nn = l[0]
            else
              nn = null

          else
            r = new RegExp(p, 'i')
            ok = false
            for cn in nn.children()
              if r.test(cn.getName()) or r.test(cn.id())
                nn = cn
                ok = true
                break
            if !ok
              nn = null

        if nn == null
          break

      return nn

    n.level = () ->
      @ancestors().length

    n.getIcon = () ->
      if @isLink()
        n = @getLink()
        if n
          return n.getIcon()
      if @icon
        return @icon
      else
        cc = @getComponent()
        if cc
          return cc.getIcon()
        else
          return null

    n.getColor = () ->
      if @isLink()
        n = @getLink()
        if n
          return n.getColor()
      if @color
        return @color
      else
        cc = @getComponent()
        if cc
          return cc.getColor()
        else
          return null

    n.kindOf = (name) ->
      cc = @getComponent()
      if cc then cc.kindOf(name) else false

    n.code = (codetype, stage) ->
      cc = @getComponent()
      if cc
        return cc.code(codetype, stage)
      else
        return null

    n.hasCode = (codetype, stage) ->
      cc = @getComponent()
      if cc
        return cc.hasCode(codetype, stage)
      else
        return false

    n.render = () ->
      cc = @getComponent()
      if cc
        cc.render(@)
      p = @getParent()
      if p
        p.render()

    n.generateCode = (out, codetype, user, stage, args) ->
      if stage and type(stage) is 'array'
        args = stage
        stage = null

      cc = @getComponent()
      if cc
        cc.generateCode(out, @, codetype, user, stage, args)
        if stage?
          for n in @children()
            n.generateCode(out, codetype, user, stage, args)

    n.hasArgs = () ->
      return _.keys(@getArgs()).length

    n.argsOfKind = (name, recurse) ->
      l = []
      for a in @argsToArray()
        if a.kindOf(name)
          l.push(a)
      if recurse
        for n in @children()
          l = l.concat(n.argsOfKind(name, recurse))
      return l

    n.argsWithOptions = (options, recurse) ->
      l = []
      for a in @argsToArray()
        if a.hasOption(options)
          l.push(a)
      if recurse
        for n in @children()
          l = l.concat(n.argsWithOptions(options, recurse))
      return l

    n.getArg = (name) ->
      return @getArgs()[name]

    n.getArgValue = (name, trueValue, falseValue) ->
      a = @getArg(name)
      if a
        return a.getValue(trueValue, falseValue)
      else if trueValue? and falseValue?
        return falseValue
      else if trueValue?
        return trueValue
      else
        return null

    n.getArgDisplayValue = (name) ->
      a = @getArg(name)
      if a
        return a.displayValue()
      else
        return null

    n.getArgValueOrDefault = (name, trueValue, falseValue) ->
      a = @getArg(name)
      if a
        return a.getValueOrDefault(null, trueValue, falseValue)
      else if trueValue? and falseValue?
        return falseValue
      else if trueValue?
        return trueValue
      else
        return null

    n.is = (name, option) ->
      a = @getArg(name)
      if a
        return a.is(option)
      else
        return false

    n.setArg = (name, value) ->
      a = @getArg(name)
      if a
        a.setValue(value)
      else
        d = @getArgDef(name)
        if d
          a = { name: name, component: d.getComponent().getName() }
          NodeClass.VCArg.setData(name, a, @)
          a.setValue(value)

    n.getArgDef = (name) ->
      cc = @getComponent()
      if cc
        return cc.getArg(name)
      else
        return null

    n.argIsEqual = (name, value) ->
      a = @getArg(name)
      if a
        return a.isEqual(value)
      else
        return false

    n.argContains = (name, value) ->
      a = @getArg(name)
      if a
        return a.contains(value)
      else
        return false

    n.getArgs = () ->
      if @$data and @$data._args
        return @$data._args
      else
        na = {}
        c = @getComponent()
        if c
          cargs = c.getArgs()
          if cargs
            for k of cargs
              ca = cargs[k]
              if @args and @args[k]?
                v = @args[k]
              else
                v = ca.getDefault()
              a = {}
              NodeClass.VCArg.setData(k, a, @)
              a.options = ca.options
              if v?
#                a.value = _.deepClone(v)
                a.value = v
                if NodeClass.VCGlobal.isValidId(v)
                  n = NodeClass.VCGlobal.find(v)
                  if n
                    a.addState('l')
                    a.$data._link = n
              na[k] = a
        if @$data
          @$data._args = na
        return na

    n.argToString = (a, codetype, user) ->
      if type(a) is 'string'
        a = @getArg(a)
      if a
        v = a.codeValue(codetype, user)
        if !v?
          v = a.getValueOrDefault()
        if !v?
          v = ''
        return v
      else
        return ''

    n.argsToString = (codetype, user) ->
      d = []
      for a in @argsToArray(true)
        s = @argToString(a, codetype, user)
        if s?
          d.push(s)
      return d.join(', ')

    n.argsToArray = (display) ->
      d = []
      aa = @getArgs()
      for k of aa
        if !display or aa[k].shouldDisplay()
          d.push(aa[k])
      return d

    n.flatOrder = () ->
      if @hasParent()
        p = @getParent().flatOrder()
      else
        p = '0'
      if @order()
        c = @order().toString()
      else
        c = '0'
      s = p + c
      return s

    n.canAdd = (c, child) ->
      if !child and @getParent()
        n = @getParent()
      else
        n = @
      nc = n.getComponent()
      return (if nc then nc.doAccept(n, c) else false)

    n.add = (name, c, child, args) ->
      c = NodeClass.VCGlobal.findComponent(c)
      if c
        if !child and @getParent()
          p = @getParent()
        else
          p = @
        return c.add(name, p, n.module(), args)

    n.canRemove = () ->
      return @canModify() and !@isSystem()

    n.remove = () ->
      if @canRemove()
        p = @getParent()
        if p
          i = p.nodes.indexOf(@)
          if i != -1
            p.nodes.splice(i, 1)
            console.log ">>>>", p, i
            p.setModified(true)

    n.first = () ->
      nn = @children()
      if nn and nn.length
        return nn[0]
      else
        return null

    n.prev = () ->
      i = @order()
      if i > 0
        return @children()[i - 1]
      else
        return null

    n.next = () ->
      i = @order()
      if i > 0
        return @children()[i + 1]
      else
        return null

    n.last = () ->
      nn = @children()
      if nn and nn.length
        return nn[nn.length - 1]
      else
        return null

    n.canMoveUp = () ->
      !@prev()

    n.moveUp = () ->
      p = @prev()
      if p
        po = p.order()
        p.setOrder(o.order())
        @setOrder(po)

    n.canMoveDown = () ->
      !@next()

    n.moveDown = () ->
      p = @next()
      if p
        po = p.order()
        p.setOrder(o.order())
        @setOrder(po)

    n.canMove = (dst, child) ->
      if child
        d = dst
      else
        d = dst.getParent()
      if d != @getParent()
        cc = n.getComponent()
        return (if cc then cc.doAccept(@, dst.getComponent(), true) else false)
      else
        return true

    n.move = (dst, order) ->
      @setParent(dst)
      @setOrder(order)

    n.addComponents = (components) ->
      if components
        for c in components
          c = NodeClass.VCGlobal.findComponent(c)
          if c
            @add(c.name, c)

    n.hasParentIcons = () ->
      for cn in @children()
        cc = cn.getComponent()
        if cc and cc.parentIcon()
          return true
      return false

    n.foreachChild = (f, recursive) ->
      for c in @children(recursive)
        f(c)

    n.hasErrors = () ->
      return false

#    n.list = () ->
#
#      _listChildren = (list, node) ->
#        for n in node.children()
#          list.push(n)
#          if n.$data and n.$data.isNode and n.isOpened()
#            _listChildren(list, n)
#
#      list = []
#
#      if @$data
#        if @hasChildren()
#          for n in @children()
#            if n.$data and n.$data.isNode and !n.isDeleted()
#              if !n.isRoot()
#                list.push(n)
#              if n.isOpened()
#                _listChildren(list, n)
#
#      return list
#
#      return list.sort((a, b) ->
#        ao = a.flatOrder()
#        bo = b.flatOrder()
#        if ao < bo
#          return -1
#        else if ao > bo
#          return 1
#        else
#          return 0
#      )


  make: (n, parent, module) ->
    @setData(n, parent, module)

  elements: () ->
    e = angular.element('#editor-nodes-root')
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
  define('vc_node', ['vc_global', 'vc_arg'], (gd, ad) ->
#    require(['vc_global', 'vc_arg'], (gd, ad) ->
    NodeClass.VCGlobal = gd
    NodeClass.VCArg = ad
    return NodeClass
  )
else
  NodeClass.VCGlobal = require("./vc_global")
  NodeClass.VCArg = require("./vc_arg")
  module.exports = NodeClass
  return NodeClass
