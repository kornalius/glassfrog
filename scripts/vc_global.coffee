GlobalClass =

  components: []
  modules: { rows: [] }

  findNode: (m, n) ->
    if typeof n is 'string'
      n = n.toLowerCase()
      for nn in m.getNodes(true)
        if nn.id() == n or nn.getName() == n
          return nn
    else
      return n

  findNodesOfKind: (type) ->
    l = []
    for m in @modules.rows
      l = l.concat(m.getRoot().childrenOfKind(type))
    return l

  findModule: (m) ->
    if typeof m is 'string'
      m = m.toLowerCase()
      for mm in @modules.rows
        if mm.id() == m or mm.getName() == m
          return mm
    else
      return m

  findComponent: (c) ->
    if typeof c is 'string'
      c = c.toLowerCase()
      for cc in @components
        if cc.id() == c or cc.getName() == c
          return cc
      return null
    else
      return c

  findComponentsOfKind: (type) ->
    if typeof type is 'string'
      t = type
    else
      t = type.getName()
    l = []
    for cc in @components
      if t == '*' or cc.kindOf(t)
        l.push(cc)
    return l

  find: (name) ->
    n = @findComponent(name)
    if !n
      n = @findModule(name)
    if !n
      for m in @modules.rows
        n = @findNode(m, name)
        if n
          return n
    return n

if define?
  define('vc_global', [], () ->
    return GlobalClass
  )
else
  module.exports = GlobalClass
