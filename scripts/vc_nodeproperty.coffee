NodePropertyClass =

#  componentProperty
#  value
#  nodes []

  VCGlobal: null

  setData: (p, node) ->
    if p.clearData
      p.clearData()

    p.$data = {}
    p.$data._states = ''
    p.$data._componentProperty = null
    p.$data._node = node
    p.$data.isNodeProperty = true

    if !p.nodes
      p.nodes = []


    p.id = () ->
      p = @getParent()
      if p
        i = 0
        name = @getName()
        l = p.getProperties(true)
        for x in [0..l.length - 1]
          if l[x].getName() == name
            i = x
            break
        return p.id() + '_' + i
      else
        return 0

    p.getValue = () ->
      if @value?
        return @value
      else if @getDefault()
        return @getDefault()
      else if !@showExpand() and @children().length == 1
        return '(' + @children()[0].displayName() + ')'
      else
        return ''

    p.getName = () ->
      cc = @getComponentProperty()
      if cc
        return cc.getName()
      else
        return ''

    p.getDesc = () ->
      cc = @getComponentProperty()
      if cc
        return cc.getDesc()
      else
        return ''

    p.getIcon = () ->
      cc = @getComponentProperty()
      if cc
        return cc.getIcon()
      else
        return null

    p.getType = () ->
      cc = @getComponentProperty()
      if cc
        return cc.getType()
      else
        return 'string'

    p.getColor = () ->
      cc = @getComponentProperty()
      if cc
        return cc.getColor()
      else
        return '#000'

    p.getEnum = () ->
      cc = @getComponentProperty()
      if cc
        return cc.getEnum()
      else
        return ''

    p.getDefault = () ->
      cc = @getComponentProperty()
      if cc
        return cc.getDefault()
      else
        return ''

    p.isOptional = () ->
      cc = @getComponentProperty()
      if cc
        return cc.isOptional()
      else
        return false

    p.isInline = () ->
      cc = @getComponentProperty()
      if cc
        return cc.isInline()
      else
        return false

    p.isSelect = () ->
      cc = @getComponentProperty()
      if cc
        return cc.isSelect()
      else
        return false

    p.isString = () ->
      cc = @getComponentProperty()
      if cc
        return cc.isString()
      else
        return false

    p.isNumber = () ->
      cc = @getComponentProperty()
      if cc
        return cc.isNumber()
      else
        return false

    p.isBoolean = () ->
      cc = @getComponentProperty()
      if cc
        return cc.isBoolean()
      else
        return false

    p.isDate = () ->
      cc = @getComponentProperty()
      if cc
        return cc.isDate()
      else
        return false

    p.isColor = () ->
      cc = @getComponentProperty()
      if cc
        return cc.isColor()
      else
        return false

    p.isArray = () ->
      cc = @getComponentProperty()
      if cc
        return cc.isArray()
      else
        return false

    p.isExpr = () ->
      cc = @getComponentProperty()
      if cc
        return cc.isExpr()
      else
        return false

    p.isLabel = () ->
      cc = @getComponentProperty()
      if cc
        return cc.isLabel()
      else
        return false

    p.getLabel = () ->
      cc = @getComponentProperty()
      if cc
        return cc.getLabel()
      else
        return ''

    p.isInput = () ->
      cc = @getComponentProperty()
      if cc
        return cc.isInput()
      else
        return false

    p.isIn = () ->
      cc = @getComponentProperty()
      if cc
        return cc.isIn()
      else
        return false

    p.isOut = () ->
      cc = @getComponentProperty()
      if cc
        return cc.isOut()
      else
        return false

    p.showValue = () ->
      cc = @getComponentProperty()
      if cc
        return cc.showValue() and !@showExpand()
      else
        return false

    p.showInput = () ->
      cc = @getComponentProperty()
      if cc
        return cc.showInput()
      else
        return false

    p.showIcons = () ->
      cc = @getComponentProperty()
      if cc
        return cc.showIcons()
      else
        return false

    p.showExpand = () ->
      cc = @getComponentProperty()
      if cc
        return cc.showExpand()
      else
        return false

    p.hasParentIcons = () ->
      for cn in @children()
        cc = cn.getComponent()
        if cc and cc.parentIcon()
          return true
      return false

    p.module = () ->
      n = @getParent()
      if n
        return n.module()

    p.hasModule = () ->
      @module()

    p.hasParent = () ->
      @getParent()

    p.getParent = () ->
      if @$data._node then @$data._node else null

    p.options = () ->
      cc = @componentProperty()
      if cc
        return cc.options()
      else
        return ''

    p.hasData = () ->
      @hasOwnProperty('$data')

    p.clearData = () ->
      if @hasData()
        delete @$data

    p.hasState = (s) ->
      if @$data._states?
        @$data._states.indexOf(s) > -1
      else
        return false

    p.addState = (s) ->
      if !@hasState(s)
        @$data._states += s

    p.delState = (s) ->
      if @$data._states?
        i = @$data._states.indexOf(s)
      else
        i = -1
      if i != -1
        @$data._states = @$data._states.substr(0, i) + @$data._states.substr(i + 1)

    p.isModified = () ->
      @hasState('m')

    p.setModified = (b) ->
      if b
        @addState('m')
      else
        @delState('m')

    p.getComponentProperty = () ->
      if @$data._componentProperty
        return @$data._componentProperty
      else
        n = @getParent()
        if n
          c = n.getComponent()
          if c
            cpn = @componentProperty.toLowerCase()
            for cp in c.getProperties(true)
              if cp.getName() == cpn
                @$data._componentProperty = cp
                return cp
        return null

    p.setComponentProperty = (c) ->
      c = NodePropertyClass.VCGlobal.findComponent(c)
      if c and @$data._componentProperty != c
        @$data._componentProperty = c
        @componentProperty = c.name
        @setModified(true)

    p.hasChildren = () ->
      @nodes.length

    p.children = () ->
      @nodes

    p.isOpened = () ->
      @hasChildren() and @children()[0].isOpened()

    p.isClosed = () ->
      !@hasChildren() or @children()[0].isClosed()

    p.open = () ->
      if @hasChildren()
        @children()[0].open()

    p.close = () ->
      if @hasChildren()
        @children()[0].close()

    p.canModify = () ->
      p = @getParent()
      return p and p.canModify()

    p.canAdd = (c) ->
      console.log "NodeProperty.canAdd()", @, c
      if c.$data and c.$data.isNode
        return @canAdd(c.getComponent())
      else if typeof c is 'string' or (c.$data and c.$data.isComponent)
        cp = @getComponentProperty()
        if cp
          if @isArray() and cp.doAccept(c)
            return true
          else if !@isExpr() and cp.doAccept(c)
            return true
        return false

    p.add = (name, c) ->
      that = @
      require(['vc_node'], (Node) ->
        if c.$data and c.$data.isNode
          n = { name: name }
          that.nodes.push(n)
          n.setLink(node)
          Node.make(n, null, that.getParent().module())
          n.setNew()
          that.setModified(true)
        else if typeof c is 'string' or (c.$data and c.$data.isComponent)
          c = NodePropertyClass.VCGlobal.findComponent(c)
          if c
            n = { name: name, component: c.name }
            that.nodes.push(n)
            Node.make(n, null, that.getParent().module())
            n.setNew()
            that.setModified(true)
      )

    p.foreachChild = (f, recursive) ->
      for c in @children()
        f(c)
        if recursive
          c.foreachChild(f, true)

    p.list = () ->
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


  make: (p, node) ->
    @setData(p, node)

    require(['vc_node'], (Node) ->
      p.foreachChild((n) ->
        Node.make(n, null)
      )
    )


if define?
  define('vc_nodeproperty', ['vc_global'], (gd) ->
    NodePropertyClass.VCGlobal = gd
    return NodePropertyClass
  )
else
  NodePropertyClass.VCGlobal = require('./vc_global')
  module.exports = NodePropertyClass
