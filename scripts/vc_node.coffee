NodeClass =

#  id
#  name
#  icon
#  color
#  component
#  options
#  nodes []
#  properties []

  VCGlobal: null
  NodeProperty: null

  setData: (n, parent, module) ->
    if n.clearData
      n.clearData()

    if !n._id
      n._id = @makeId()

    n.$data = {}
    n.$data._parent = parent
    n.$data._component = null
    n.$data._module = module
    n.$data._link = null
    n.$data._states = ''
    n.$data.isNode = true

    if parent and parent.isNode
      if !parent.nodes
        parent.nodes = []
      if parent.nodes.indexOf(n) == -1
        parent.nodes.push(n)

    if !n.nodes
      n.nodes = []

    if !n.properties
      n.properties = []


    n.id = () ->
      @_id

    n.getName = () ->
      @name.toLowerCase()

    n.setName = (name) ->
      if @name != name
        @name = name
        @setModified(true)

    n.order = () ->
      @children().indexOf(@)

    n.setOrder = (o) ->
      i = @order()
      if o != i and o in [0..@children().length - 1]
        n = o
        if n > i
          n--
        @nodes = @nodes.splice(i).splice(n, 0, @)
        @setModified(true)

    n.module = () ->
      if !@$data._module
        @$data._module = NodeClass.VCGlobal.findModule(@module)
      return @$data._module

    n.hasModule = () ->
      @module()

    n.hasParent = () ->
      @getParent()

    n.getParent = () ->
      if @$data._parent then @$data._parent else null

    n.setParent = (p) ->
      p = NodeClass.VCGlobal.findNode(@module(), p)
      pp = @getParent()
      if p != pp
        i = pp.order(@)
        if i != -1
          pp.nodes = pp.nodes.splice(i)
          pp.setModified(true)

        @$data._parent = null

        if p
          p.nodes.push(@)
          @$data._parent = p

        @setModified(true)

    n.getComponent = () ->
      if !@$data._component
        @$data._component = NodeClass.VCGlobal.findComponent(@component)
      return @$data._component

    n.setComponent = (c) ->
      c = NodeClass.VCGlobal.findComponent(c)
      if c
        @$data._component = c
        @component = c.name
        @setModified(true)
        if c.children?
          cc = []
          for k in c.children.split(',')
            cc.push(NodeClass.VCGlobal.findComponent(k))
          @addComponents(cc)

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
  
    n.addOption = (s) ->
      if !@hasOption(s)
        @options += s
        @setModified(true)
  
    n.delOption = (s) ->
      if @options?
        i = @options.indexOf(s)
      else
        i = -1
      if i != -1
        @options = @options.substr(0, i) + @options.substr(i + 1)
        @setModified(true)

    n.hasState = (s) ->
      @$data._states.indexOf(s) > -1

    n.addState = (s) ->
      if !@hasState(s)
        @$data._states += s

    n.delState = (s) ->
      i = @$data._states.indexOf(s)
      if i != -1
        @$data._states = @$data._states.substr(0, i) + @$data._states.substr(i + 1)

    n.isSystem = () ->
      @hasOption('s')

    n.isShared = () ->
      @hasModule() and @module().hasShare()

    n.canEdit = () ->
      cc = n.getComponent()
      @canModify() and cc and !cc.isLocked()

    n.canModify = () ->
      !@isSystem() and !@isShared()

    n.isOpened = () ->
      @hasState('o')

    n.isClosed = () ->
      !@hasState('o')

    n.open = (recursive) ->
      @addState('o')
      if recursive
        @foreachChild((n) -> n.open(true))

    n.close = (recursive) ->
      @delState('o')
      if recursive
        @foreachChild((n) -> n.close(true))

    n.isModified = () ->
      if !@hasState('m')
        ok = false
        @foreachProperty(false, (p) ->
          if p.isModified()
            ok = true
        )
        return ok
      else
        return true

    n.setModified = (b) ->
      if b
        @addState('m')
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

    n.displayName = () ->
      if @name?
        if @isLink()
          n = @link()
          if n
            return n.name
        return @name
      else if @getComponent()
        return @getComponent().name
      else
        return "Untitled"
  
    n.isLink = () ->
      @hasOption('l')
  
    n.link = () ->
      if @isLink()
        if !@$data._link
          @$data._link = NodeClass.VCGlobal.findNode(@module(), @name)
        return @$data._link
      else
        return null

    n.setLink = (n) ->
      if !n
        @delOption('l')
        @$data._link = null
        delete @name
        @setModified(true)
        return true
      else
        n = NodeClass.VCGlobal.findNode(@module(), n)
        if n and @getComponent().valueKind() and n.kindOf(@getComponent().valueKind().name)
          if n != @$data._link
            @addOption('l')
            @$data._link = n
            @name = n.name
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
  
    n.parentSchema = () ->
      @parentOfKind('Schema')
  
    n.parentField = () ->
      @parentOfKind('Field')
  
    n.parentPage = () ->
      @parentOfKind('Page')
  
    n.parentView = () ->
      @parentOfKind('View')
  
    n.parentMenubar = () ->
      @parentOfKind('Menubar')
  
    n.parentTable = () ->
      @parentOfKind('Table')
  
    n.parentHeader = () ->
      @parentOfKind('Header')
  
    n.parentColumn = () ->
      @parentOfKind('Column')
  
    n.parentQuery = () ->
      @parentOfKind('Query')
  
    n.parentExpression = () ->
      @parentOfKind('Expression')
  
    n.hasChildren = () ->
      @nodes.length

    n.children = (recursive) ->
      l = []
      for nn in @nodes
        if !nn.isDeleted()
          l.push(nn)
          if recursive
            l = l.concat(nn.children(true))
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
  
    n.ancestors = () ->
      a = []
      p = @
      while p
        a.push(p)
        p = p.getParent()
      return a
  
    n.siblings = () ->
      if @hasParent()
        return @getParent().nodes
      else
        return null

    n.path = (display) ->
      if display?
        return @ancestors().map((nn) -> nn.name).join('.')
      else
        return @ancestors().map((nn) -> nn.id).join('#')
  
    n.level = () ->
      @ancestors().length
  
    n.getIcon = () ->
      if @icon
        return @icon
      else if @getComponent()
        return @getComponent().getIcon()
      else
        return null
  
    n.getColor = () ->
      if @color
        return @color
      else if @getComponent()
        return @getComponent().getColor()
      else
        return 'black'
  
    n.isValueKind = () ->
      @getComponent() and @getComponent().isValueKind()

    n.valueKind = () ->
      if @getComponent()
        return @getComponent().valueKind()
      else
        return null

    n.kindOf = (name) ->
      @getComponent() and @getComponent().kindOf(name)
  
    n.code = () ->
      cc = @getComponent()
      if cc and cc.hasCode()
        return cc.code()
      else
        return {}
  
    n.hasCode = () ->
      c = @code()
      return (typeof c is 'object') and Object.keys(c).length > 0

    n.string = () ->
      @code().string

    n.hasString = () ->
      @string() != null

    n.render = () ->
      @code().render

    n.hasRender = () ->
      @render() != null

    n.doRender = () ->
      cc = @getComponent()
      if cc and cc.hasRender()
        cc.doRender(@)

    n.generate = () ->
      cc = @getComponent()
      if cc and cc.hasGenerate()
        cc.doGenerate(@)

    n.hasGenerate = () ->
      @generate() != null

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

    n.add = (name, c, child) ->
      c = NodeClass.VCGlobal.findComponent(c)
      if c
        if !child and @getParent()
          p = @getParent()
        else
          p = @

        n = { name: name, component: c.name }
        NodeClass.make(n, p, p.module())

        n.setNew(true)

    n.remove = () ->
      if @canModify()
        @setDeleted(true)
        for n in @children(true)
          n.remove()

    n.first = () ->
      nodes = @children()
      if nodes and nodes.length
        return nodes[0]
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
      nodes = @children()
      if nodes and nodes.length
        return nodes[nodes.length - 1]
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
  
    n.generate = () ->
      if @getComponent()
        return @getComponent().generate(@)
      else
        return ""
  
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

    n.foreachProperty = (all, f) ->
      if @hasProperties()
        for p in @getProperties(all)
          f(p)

    n.hasProperties = (all) ->
      @getProperties(all).length

    n.hasProperty = (name) ->
      @getProperty(name)?

    n.getProperty = (name) ->
      name = name.toLowerCase()
      for np in @getProperties()
        if np.getName() == name
          return np
      return null

    n.getProperties = (all) ->
      p = []
      c = @getComponent()
      if all and c
        for cp in c.getProperties()
          np = @getProperty(cp.name)
          if !np
            np = { componentProperty: cp.name, value: null }
            NodeClass.NodeProperty.make(np, @)
          p.push(np)
      else
        p = @properties

      return p

    n.list = () ->
      _listChildren = (list, node) ->
        for n in node.children()
          list.push(n)
          if n.isOpened()
            _listChildren(list, n)

      list = []

      if @hasChildren()
        for n in @children()
          if !n.isDeleted()
            if !n.isRoot()
              list.push(n)
            if n.isOpened()
              _listChildren(list, n)

      return list

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


  makeId: () ->
    guid = () ->
      s4 = () ->
        return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)
      return s4() + s4() + s4() + s4() + s4() + s4()

    return guid()

  make: (n, parent, module) ->
    @setData(n, parent, module)

    n.foreachProperty((p) ->
      NodeClass.NodeProperty.make(p, n)
    , true)

    for nn in n.nodes
      @make(nn, n, module)


if define?
  define('vc_node', ['vc_global', 'vc_nodeproperty'], (gd, npd) ->
    NodeClass.VCGlobal = gd
    NodeClass.NodeProperty = npd
    return NodeClass
  )
else
  NodeClass.VCGlobal = require("./vc_global")
  NodeClass.NodeProperty = require("./vc_nodeproperty")
  module.exports = NodeClass
