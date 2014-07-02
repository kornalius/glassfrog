GlobalClass =

  components: []
  modules: { rows: [] }

  findNode: (m, n) ->
    if typeof n is 'string'
      n = n.toLowerCase()
      for nn in m.getNodes(true)
        if nn.id == n or nn.name.toLowerCase() == n
          return nn
    else
      return n

  findModule: (m) ->
    if typeof m is 'string'
      m = m.toLowerCase()
      for mm in @modules.rows
        if mm.id == m or mm.name.toLowerCase() == m
          return mm
    else
      return m

  findComponent: (c) ->
    if typeof c is 'string'
      c = c.toLowerCase()
      for cc in @components
        if cc.name.toLowerCase() == c
          return cc
      return null
    else
      return c

  findComponentsOfKind: (type) ->
    if typeof type is 'string'
      t = type
    else
      t = type.valueKind
    l = []
    for cc in @components
      if t == '*' or cc.kindOf(t)
        l.push(cc)
    return l


if define?
  define('vc_global', [], () ->
    return GlobalClass
  )
else
  module.exports = GlobalClass
