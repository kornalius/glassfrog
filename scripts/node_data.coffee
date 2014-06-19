Component_Data = null

nd =
  rest: null

  updateNode: (n) ->
    n.$data.node = n
    n.$data.parent = null
#    n.$data.link = null
    n.$data.component = null
    n.$data._this = @

    if n.parentId?
      n.$data.parent = n.$data._this.getNodeById(n.parentId)
      if n.$data.parent == n
        n.$data.parent = null

    if n.component?
      n.$data.component = Component_Data.getComponentById(n.component)

#    if n._options and n._options.indexOf('l') > -1 and n.name?
#      n.$data.link = n.$data._this.getNodeById(n.name)
#      if n.$data.link == n
#        n.$data.link = null

    return n

  makeId: (n) ->
    guid = () ->
      s4 = () ->
        return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)
      return s4() + s4() + s4() + s4() + s4() + s4()

    n._id = guid()

  makeNode: (n) ->
    n.$data = {}

    @updateNode(n)

    if !n._id
      @makeId(n)

    n.$data.id = () ->
      return @node._id

    n.$data.hasOption = (s) ->
      if @node._options
        @node._options.indexOf(s) > -1
      else
        return false

    n.$data.addOption = (s) ->
      if !@hasOption(s)
        @node._options += s

    n.$data.delOption = (s) ->
      i = @node._options.indexOf(s)
      if i != -1
        @node._options = @node._options.substr(0, i) + @node._options.substr(i + 1)

    n.$data.isSystem = () ->
      return @hasOption('s')

    n.$data.isValueKind = () ->
      return @component and @component.$data and @component.$data.valueKind?

    n.$data.isLink = () ->
      return @hasOption('l')

    n.$data.getLink = () ->
      if @isLink()
        return @_this.getNode(@node.name)
      else
        return null

    n.$data.setLink = (n) ->
      n = @_this.getNode(n)
      if n and n.$data.parentModule()._id.toString() == @parentModule()._id.toString() and n._id.toString() != @node._id.toString() and @component.valueKind? and n.$data.kindOf(@component.$data.valueKind.name)
        @addOption('l')
        @name = n._id
        #        @link = n
        return true
      else
        return false

    n.$data.isShared = () ->
      @hasOption('h')

    n.$data.isSharing = () ->
      @hasOption('*')

    n.$data.getOwner = () ->
      m = @parentModule()
      if m
        return m.owner_id.toString()
      else
        return null

    n.$data.getRoot = () ->
      p = @parent
      while p
        if !p.$data or !p.$data.parent
          break
        p = p.$data.parent
      return p

    n.$data.parentOfKind = (name) ->
      if @kindOf(name)
        p = @node
      else
        p = @parent
        while p
          if !p.$data or !p.$data.parent or p.$data.kindOf(name)
            break
          p = p.$data.parent
      return p

    n.$data.parentSchema = () ->
      @parentOfKind('Schema')

    n.$data.parentModule = () ->
      @parentOfKind('Module')

    n.$data.parentField = () ->
      @parentOfKind('Field')

    n.$data.parentPage = () ->
      @parentOfKind('Page')

    n.$data.parentView = () ->
      @parentOfKind('View')

    n.$data.parentMenubar = () ->
      @parentOfKind('Menubar')

    n.$data.parentTable = () ->
      @parentOfKind('Table')

    n.$data.parentHeader = () ->
      @parentOfKind('Header')

    n.$data.parentColumn = () ->
      @parentOfKind('Column')

    n.$data.parentQuery = () ->
      @parentOfKind('Query')

    n.$data.parentExpression = () ->
      @parentOfKind('Expression')

    n.$data.isRoot = () ->
      return !@parent?

    n.$data.hasParent = () ->
      return @parent?

    n.$data.hasChildren = () ->
      if @_this.rest
        for r in @_this.rest.rows
          if r.parentId == @node._id
            return true
      return false

    n.$data.children = (recursive) ->
      l = []
      i = @node._id
      if @_this.rest
        for r in @_this.rest.rows
          if r.parentId == i and r.$data and !r.$data.isDeleted()
            l.push(r)
            if recursive
              l = l.concat(r.$data.children(true))
      return l

    n.$data.childrenOfKind = (name, recursive) ->
      c = []
      l = @children(recursive)
      for n in l
        if n.$data.kindOf(name)
          c.push(n)
      return c

    n.$data.getAncestors = () ->
      a = []
      p = @node
      while p
        a.push(p)
        if !p.$data
          break
        p = p.$data.parent
      return a

    n.$data.getSiblings = () ->
      l = []
      if @parent
        pid = @parent._id
      else
        pid = 0
      if @_this.rest
        for r in @_this.rest.rows
          if r.parentId == pid
            l.push(r)
      return l

    n.$data.path = () ->
      return @getAncestors().map((nn) -> nn._id).join('#')

    n.$data.level = () ->
      return @getAncestors().length

    n.$data.icon = () ->
      if @node.icon
        return @node.icon
      else if @component and @component.$data
        return @component.$data.icon()
      else
        return null

    n.$data.color = () ->
      if @node.color
        return @node.color
      else if @component and @component.$data
        return @component.$data.color()
      else
        return '#00000000'

    n.$data.kindOf = (name) ->
      return @component and @component.$data and @component.$data.kindOf(name)

    n.$data.clientCode = () ->
      if @component and @component.$data
        return @component.$data.clientCode()
      else
        return ""

    n.$data.hasClientCode = () ->
      if @component and @component.$data
        return @component.$data.hasClientCode()
      else
        return false

    n.$data.flatOrder = () ->
      if @parent and @parent.$data
        p = @parent.$data.flatOrder()
      else
        p = '0'
      if @node._order
        c = @node._order.toString()
      else
        c = '0'
      s = p + c
      return s

    return n

  getNode: (n) ->
    if n and typeof n is 'string'
      _n = n
      n = @getNodeById(n)
      if !n
        n = @getNodeByName(_n)
    return n

  getNodeByName: (name) ->
    if @rest
      name = name.toLowerCase()
      for n in @rest.rows
        if n.name and n.name.toLowerCase() == name
          return n
    return null

  getNodeById: (id) ->
    if @rest
#      console.log "getNodeById", id, @rest.rows.length, "[", @rest.rows.map((n) -> n._id).join(','), "]"
      for n in @rest.rows
        if n._id.toString() == id
          return n
    return null

if define?
  define('Node_Data', ['Component_Data'], (cd) ->
    Component_Data = cd
    return nd
  )
else
  Component_Data = require("./component_data")
  module.exports = nd
