NodeClass =

#  id
#  name
#  icon
#  color
#  component
#  arg
#  options
#  nodes []
#  args []

  VCGlobal: null

  setData: (n, parent, module) ->
    if n.clearData
      n.clearData()

    if !n._id
      n._id = makeId()

    n.$data = {}
    n.$data._parent = parent
    n.$data._component = null
    n.$data._module = module
    n.$data._link = null
    n.$data._states = ''
    n.$data._arg = null
    n.$data.isNode = true
    n.$data.isArg = false
    n.$data._syntax = null

    if !n.nodes
      n.nodes = []
    else
      for nn in n.nodes
        @setData(nn, n, module)

    if !n.args
      n.args = []
    else
      for nn in n.args
        @setData(nn, n, module)
        nn.$data.isArg = true


    n.id = () ->
      @_id

    n.getName = () ->
      if @isLink()
        n = @getLink()
        if n and n.name
          return n.name.toLowerCase()
      return (if @name then @name.toLowerCase() else "")

    n.setName = (name) ->
      if name and @kindOf('Object')
        name = _.str.classify(name)
      if !@isLink() and (@name != name or !name)
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
        if n and n.desc
          return n.desc
      return (if @desc then @desc else "")

    n.order = () ->
      if @$data.isArg
        @getParent().args.indexOf(@)
      else
        @getParent().nodes.indexOf(@)

    n.setOrder = (o) ->
      i = @order()
      p = @getParent()
      if @$data.isArg and o != i and o in [0..p.args.length - 1]
        n = o
        if n > i
          n--
        p.args.splice(i)
        p.args.splice(n, 0, @)
        @setModified(true)
      else if o != i and o in [0..p.children().length - 1]
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
          if @$data.isArg
            pp.args.splice(i)
          else
            pp.nodes.splice(i)
          pp.setModified(true)

        @$data._parent = null

        if p
          if @$data.isArg
            if idx? and idx < p.args.length - 1
              p.args.splice(idx, 0, @)
            else
              p.args.push(@)
          else
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
        if c.hasDefaults()?
          l = []
          for d in c.getDefaults()
            l.push(NodeClass.VCGlobal.findComponent(d))
          @addComponents(l)

    n.getArg = () ->
      if @$data
        a = @$data._arg
      else
        a = null

      if !c
        a = NodeClass.VCGlobal.findArg(null, @arg)
        @$data._arg = a
        @$data.isArg = true

      return a

    n.setArg = (a) ->
      a = NodeClass.VCGlobal.findArg(a)
      if a and @$data
        @$data._arg = a
        @$data.isArg = a != null
        @setModified(true)

    n.hasData = () ->
      return @hasOwnProperty('$data')
  
    n.clearData = () ->
      if @hasData()
        delete @$data
  
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
        , 1)

    n.addOption = (s) ->
      if !@hasOption(s)
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
      @hasOption('s')

    n.isShared = () ->
      @hasModule() and @module().hasShare()

    n.canEdit = () ->
      cc = @getComponent()
      @canModify() and cc and !cc.isLocked()

    n.canModify = () ->
      !@isSystem() and !@isShared()

    n.element = () ->
      e = angular.element('#node-element_' + @id())
      if e and e.length
        return e
      else
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

    n.open = (recursive) ->
      @addState('o')
      if recursive
        @foreachChild((n) -> n.open(true))

    n.close = (recursive) ->
      @delState('o')
      if recursive
        @foreachChild((n) -> n.close(true))

    n.toggle = (recursive) ->
      if @isOpened()
        @close(recursive)
      else
        @open(recursive)

    n.isModified = () ->
      @hasState('m')

    n.setModified = (b) ->
      if b
        @addState('m')
        @$data._module.doGenerate(true)
        @$data._module.doGenerate(false)
        if @$data and @$data.isArg and @getParent()
          @getParent().setModified(true)
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

    n.isDeleted = () ->
      @hasState('d')
  
    n.setDeleted = (b) ->
      if b
        @addState('d')
        @setModified(true)
      else
        @delState('d')
        @setModified(true)

    n.varName = () ->
      if @$data and @$data._varName
        return @$data._varName
      else
        vn = @name
        if @isLink()
          n = @getLink()
          if n
            vn = n.varName()
        @$data._varName = _.str.classify(vn)
        return vn

    n.displayName = () ->
      if @name
        if @isLink()
          n = @getLink()
          if n
            if n.$data and n.$data.isNode
              return n.getPath(true)
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
      for nn in @nodes
        if nn.$data and nn.$data.isNode and !nn.isDeleted()
          if (!onlyStatement? or nn.isStatement())
            l.push(nn)
          if recursive
            l = l.concat(nn.children(true, onlyStatement))
      return l
  
    n.setChildren = (nodes) ->
      @nodes = []

      if nodes
        if typeof nodes is 'string'
          @nodes = JSON.parse(nodes)
          @setModified(true)
          p = @getParent()
          NodeClass.make(@, p, p.module())
        else
          @nodes = JSON.stringify(nodes)
          @setModified(true)
          p = @getParent()
          NodeClass.make(@, p, p.module())

    n.childrenOfKind = (name, recursive) ->
      c = []
      l = @children(recursive)
      for n in l
        if name == '*' or n.kindOf(name)
          c.push(n)
      return c
  
    n.ancestors = (hideRoot) ->
      r = @$data._module.getRoot()
      a = []
      p = @
      while p
        if !hideRoot? or p != r
          a.unshift(p)
        p = p.getParent()
      return a
  
    n.siblings = () ->
      if @hasParent()
        return @getParent().nodes
      else
        return null

    n.hasEnum = () ->
      cc = @getComponent()
      if cc
        return cc.hasEnum()
      else
        return false

    n.getEnum = () ->
      cc = @getComponent()
      if cc
        return cc.getEnum()
      else
        return []

    n.getPath = (display) ->
      if display?
        l = []
        if !@$data._module.isEditing()
          l = [@$data._module.displayName()]
        return l.concat(@ancestors(true).map((nn) -> nn.displayName())).join('.')
      else
        return [@$data._module.id()].concat(@ancestors().map((nn) -> nn.id())).join('#')
  
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
      return cc and cc.kindOf(name)
  
    n.code = (name) ->
      cc = @getComponent()
      if cc
        return cc.code(name)
      else
        return null
  
    n.hasCode = (name) ->
      @code(name) != null

    n.string = () ->
      @code("string")

    n.hasString = () ->
      @string() != null

    n.render = () ->
      @code("render")

    n.hasRender = () ->
      @render() != null

    n.doRender = () ->
      cc = @getComponent()
      if cc
        cc.doRender(@)

    n.generate = () ->
      @code("generate")

    n.hasGenerate = () ->
      @generate() != null

    n.doGenerate = (client) ->
      cc = @getComponent()
      if cc
        return cc.doGenerate(@, client)
      else
        return ""

    n.hasRun = () ->
      @run() != null

    n.doRun = (client, args, cb) ->
      cc = @getComponent()
      if cc
        cc.doRun(@, client, args, (r) ->
          cb(r)
        )
      else
        cb(null)

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
      return nc and nc.doAccept(n, c)

    n.add = (name, c, child, args) ->
      c = NodeClass.VCGlobal.findComponent(c)
      if c
        if !child and @getParent()
          p = @getParent()
        else
          p = @
        return c.add(name, n.module(), p, args)

    n.remove = () ->
      if @canModify()
        @setDeleted(true)
        for n in @children(true)
          n.remove()

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

    n.canMove = (d, child) ->
      if !child and @getParent()
        n = @getParent()
      else
        n = @
      cc = n.getComponent()
      return cc and cc.doAccept(n, d.getComponent())
  
    n.move = (dst, order) ->
      @setParent(dst)
      @setOrder(order)

    n.addComponents = (components) ->
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
      for c in @children()
        f(c)
        if recursive
          c.foreachChild(f, true)

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
  define('vc_node', ['vc_global'], (gd) ->
    NodeClass.VCGlobal = gd
    return NodeClass
  )
else
  NodeClass.VCGlobal = require("./vc_global")
  module.exports = NodeClass
