GlobalClass =

  acorn: null

  components: []
  modules: { rows: [] }

  findNode: (m, n, idOnly) ->
    if typeof n is 'string'
      n = n.toLowerCase()
      if !m
        for m in GlobalClass.modules.rows
          nn = @findNode(m, n, idOnly)
          if nn
            return nn
        return null
      else if m.getNodes
        for nn in m.getNodes(true)
          if (idOnly? and nn.id and nn.id() == n) or (!idOnly? and ((nn.id and nn.id() == n) or (nn.name and nn.name.toLowerCase() == n)))
            return nn
      return null
    else
      return n

  findNodesOfKind: (type) ->
    l = []
    for m in @modules.rows
      if m.getRoot
        r = m.getRoot()
      else
        r = null
      if r
        l = l.concat(r.childrenOfKind(type))
    return l

  findModule: (m, idOnly) ->
    if typeof m is 'string'
      m = m.toLowerCase()
      if @modules and @modules.rows
        for mm in @modules.rows
          if (idOnly? and mm.id and mm.id() == m) or (!idOnly? and ((mm.id and mm.id() == m) or (mm.name and mm.name.toLowerCase() == m)))
            return mm
      return null
    else
      return m

  findComponent: (c, idOnly) ->
    if typeof c is 'string'
      c = c.toLowerCase()
      for cc in @components
        if (idOnly? and cc.id and cc.id() == c) or (!idOnly? and ((cc.id and cc.id() == c) or (cc.name and cc.name.toLowerCase() == c)))
          return cc
      return null
    else
      return null

  findComponentsOfKind: (type) ->
    if typeof type is 'string'
      t = type
    else
      t = type.getName()
    l = []
    for cc in @components
      if t == '*' or (cc.kindOf and cc.kindOf(t))
        l.push(cc)
    return l

  findArg: (c, a, idOnly) ->
    if typeof a is 'string'
      a = a.toLowerCase()
    if c
      c = @findComponent(c)
      for aa in c.args()
        if (idOnly? and aa.id and aa.id() == a) or (!idOnly? and ((aa.id and aa.id() == a) or (aa.name and aa.name.toLowerCase() == a)))
          return aa
      return null
    else
      for cc in @components
        aa = @findArg(cc, a, idOnly)
        if aa
          return aa
      return null

  find: (name, idOnly) ->
    n = @findComponent(name, idOnly)
    if !n
      n = @findModule(name, idOnly)
    if !n
      n = @findNode(null, name, idOnly)
    if !n
      n = @findArg(null, name, idOnly)
    return n

  module: () ->
    for m in @modules.rows
      if m.isEditing and m.isEditing()
        return m
    return null

  checkSyntax: (s) ->
    syntax = { code: '', nodes: null, error: null }
    try
      syntax.code = s
      syntax.crc = window.checksum(s)
      syntax.nodes = @acorn.parse(s,
        forbidReserved: 'everywhere'
        locations: true
        ranges: true
        onComment: (block, text, start, end) ->
          if !block
            line = GlobalClass.acorn.getLineInfo(s, start)
  #          console.log "onComment()", block, text, start, end, line
            x = text.indexOf('id::')
            if x != -1
              ids = text.substr(x + 4).split(',')
              for id in ids
                n = GlobalClass.find(id, true)
                if n and n.$data
                  n.$data._syntax = { start: start, end: end, line: line }
      )
    catch e
      syntax.error = e
    finally
      return syntax


if define?
  define('vc_global', [], () ->
    GlobalClass.acorn = window.acorn
    return GlobalClass
  )
else
  GlobalClass.acorn = require('acorn')
  module.exports = GlobalClass
