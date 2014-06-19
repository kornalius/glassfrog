cd =
  rest: null

  makeComponent: (c) ->
    c.$data = {}
    c.$data.inherit = null
    c.$data.component = c
    c.$data._accepts = []
    c.$data._this = @

    if c.inherit?
      c.$data.inherit = c.$data._this.getComponentById(c.inherit)
      if c.$data.inherit == c
        c.$data.inherit = null

    if c.valueKind?
      c.$data.valueKind = c.$data._this.getComponentById(c.valueKind)

    if c.accepts?
      for i in c.accepts
        d = c.$data
        a = { parent: [], component: d._this.getComponentById(i.component)}
        if i.parent and i.parent.length
          for pi in i.parent
            a.parent.push(d._this.getComponentById(pi))
        d._accepts.push(a)


    c.$data.hasOption = (s) ->
      @component._options.indexOf(s) > -1

    c.$data.isLocked = () ->
      if @hasOption('l')
        return true
      else if @inherit
        return @inherit.$data.isLocked()
      else
        return false

    c.$data.isVisible = () ->
      if @hasOption('v')
        return true
      else if @inherit
        return @inherit.$data.isVisible()
      else
        return false

    c.$data.isParentIcons = () ->
      if @hasOption('p')
        return true
      else if @inherit
        return @inherit.$data.isParentIcons()
      else
        return false

    c.$data.canEdit = () ->
      return !@isLocked()

    c.$data.kindOf = (name) ->
      if name instanceof Array
        for n in name
          if @kindOf(n)
            return true
        return false
      else
        return @component.name.toLowerCase() == name.toLowerCase() or (@inherit? and @inherit.$data.kindOf(name))

    c.$data.color = () ->
      if @component.color?
        return @component.color
      else if @inherit
        return @inherit.$data.color()

    c.$data.icon = () ->
      if @component.icon?
        return @component.icon
      else if @inherit
        return @inherit.$data.icon()

    c.$data.parentIcon = () ->
      if @isParentIcons()
        return true
      else if @inherit
        return @inherit.$data.parentIcon()

    c.$data.clientCode = () ->
      if @component.clientCode?
        return @component.clientCode
      else if @inherit
        return @inherit.$data.clientCode()
      else
        return ""

    c.$data.hasClientCode = () ->
      return @clientCode()?

    c.$data.accepts = () ->
      l = []
      if @_accepts.length
        l = l.concat(@_accepts)
      if @inherit
        l = l.concat(@inherit.$data.accepts())
      return l

    c.$data.doAccept = (node, cc) ->
      cc = @_this.getComponent(cc)
      if cc
        for c in @accepts()
          ok = cc.$data.kindOf(c.component.name)

          if ok and node and c.parent and c.parent.length
            p = node.$data.parent
            i = c.parent.length - 1
            while p and i >= 0
              if p.$data.component.$data.kindOf(c.parent[i].name)
                i--
                if p.$data.component.$data.kindOf('Module')
                  break
              else
                break
              p = p.$data.parent
            ok = (i == -1)

          if ok
            return true

      return false

    c.$data.render = (node, c) ->
      cc = @clientCode()
      if cc?
        cc = eval(cc)
        if cc and cc.render
          that = @
          window.setTimeout( ->
            cc.render.call(that.component, node, c)
          , 1)

    c.$data.generate = (node) ->
      cc = @clientCode()
      if cc?
        cc = eval(cc)
        if cc and cc.generate
          return cc.generate.call(@component, node)
      return ""

    return c

  getComponent: (c) ->
    if c and typeof c is 'string'
      _c = c
      c = @getComponentByName(c)
      if !c
        c = @getComponentById(_c)

    return c

  getComponentById: (id) ->
    if @rest
      id = id.toString()
      for c in @rest.rows
        if c._id.toString() == id
          return c
      return null

  getComponentByName: (name) ->
    if @rest
      for c in @rest.rows
        if c.$data.kindOf(name)
          return c
      return null


if define?
  define('Component_Data', [], () ->
    return cd
  )
else
  module.exports = cd
