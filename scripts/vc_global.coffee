GlobalClass =

  components: []
  modules: { rows: [] }

  findNode: (m, n, idOnly) ->
    if type(n) is 'string'
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
    else if n and n.$data and n.$data.isNode
      return n
    else
      return null

  findNodesOfKind: (type, recursive) ->
    l = []
    for m in @modules.rows
      if m.getRoot
        r = m.getRoot()
      else
        r = null
      if r
        l = l.concat(r.childrenOfKind(type, recursive))
    return l

  findModule: (m, idOnly) ->
    if type(m) is 'string'
      m = m.toLowerCase()
      if @modules and @modules.rows
        for mm in @modules.rows
          if (idOnly? and mm.id and mm.id() == m) or (!idOnly? and ((mm.id and mm.id() == m) or (mm.name and mm.name.toLowerCase() == m)))
            return mm
      return null
    else if m and m.$data and m.$data.isModule
      return m
    else
      return null

  findComponent: (c, idOnly) ->
    if type(c) is 'string'
      c = c.toLowerCase()
      for cc in @components
        if (idOnly? and cc.id and cc.id() == c) or (!idOnly? and ((cc.id and cc.id() == c) or (cc.name and cc.name.toLowerCase() == c)))
          return cc
      return null
    else if c and c.$data and c.$data.isComponent
      return c
    else
      return null

  findComponentsOfKind: (type) ->
    if type(type) is 'string'
      t = type
    else
      t = type.getName()
    l = []
    for cc in @components
      if t == '*' or (cc.kindOf and cc.kindOf(t))
        l.push(cc)
    return l

  find: (name, idOnly) ->
    n = @findComponent(name, idOnly)
    if !n
      n = @findModule(name, idOnly)
    if !n
      n = @findNode(null, name, idOnly)
    return n

  checkSyntax: (s) ->
    syntax = { code: '', nodes: null, error: null }
    try
      syntax.code = s
      syntax.crc = checksum(s)
      syntax.nodes = acorn.parse(s,
        forbidReserved: 'everywhere'
        locations: true
        ranges: true
        onComment: (block, text, start, end) ->
          if !block
            line = acorn.getLineInfo(s, start)
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

  enumToList: (l, node, asObject, multi) ->

    if !multi
#      if asObject
#        nl = [{label: '', value: ''}]
#      else
      nl = ['']
    else
      nl = []

    for i in [0..l.length - 1]
      ii = l[i]
      if ii and type(ii) is 'string'
        if ii.startsWith('#')
          nl = nl.concat(@findComponentsOfKind(ii.substr(1)).map((c) -> if asObject then {label: c.displayName(), value: c.id(), link: true} else c.displayName()))

        else if ii.toLowerCase() == '@module'
          nl = nl.concat(@modules.rows.map((m) -> if asObject then {label: m.varName(), value: m.id(), link: true} else m.varName()))

        else if ii.startsWith('@@@') and node?
          nl = nl.concat(node.childrenOfKind(ii.substr(3), true).map((n) -> if asObject then {label: n.varName(), value: n.id(), link: true} else n.varName()))

        else if ii.startsWith('@@')
          nl = nl.concat(@findNodesOfKind(ii.substr(2), true).map((n) -> if asObject then {label: n.varName(), value: n.id(), link: true} else n.varName()))

        else if ii.startsWith('@')
          nl = nl.concat(@findNodesOfKind(ii.substr(1), false).map((n) -> if asObject then {label: n.varName(), value: n.id(), link: true} else n.varName()))

        else
          nl.push(if asObject then {label: ii, value: ii} else ii)

    if nl.length == 1 and !multi
      nl = []

    id = null
    name = null
    if node
      if node.id
        id = node.id()
      if node.varName
        name = node.varName()

    _.remove(nl, (n) -> (n.value and n.value in [id, name]) or (n in [id, name]))

    return nl


  loadComponents: (cb) ->
    that = @

    console.log "Loading components..."

    if window? and angular?
      $http = angular.injector(['ng']).invoke(['$http', ($http) ->
        $http.get('/api/components')
        .success((result, status) ->
          if result and result.length
            info = result[0]
            that.status = info.status
            that.err = info.err
            if that.status == 'ok'
              result.shift()
              data = result
              require(['vc_component'], (VCComponent) ->
                that.components = data
                for c in that.components
                  VCComponent.make(c)
                console.log "Loaded {0} components".format(data.length)
                cb(data) if cb
              )

            else
              console.log "Error loading components", status
              cb(null) if cb

          else
            console.log "Error loading components", status
            cb(null) if cb
        )

        .error((data, status) ->
          console.log "Error loading components", status
          cb(null) if cb
        )
      ])
    else
      require('mongoose').model('Component').find({}, (err, data) ->
        if data
          VCComponent = require('./vc_component')
          that.components = []
          for c in data
            cc = c.toObject()
            VCComponent.make(cc)
            that.components.push(cc)
          console.log "Loaded {0} components".format(that.components.length)
          cb(data) if cb
        else
          console.log "Error loading components", err
          cb(null) if cb
      )

  isValidId: (s) ->
    return s and type(s) is 'string' and s.match(/^[0-9a-fA-F]{24}$/)

  isValidVC: (n) ->
    return n and n.$data

  isValidNode: (n) ->
    return @isValidVC(n) and n.$data.isNode

  isValidArg: (n) ->
    return @isValidVC(n) and n.$data.isArg

  isValidComponent: (n) ->
    return @isValidVC(n) and n.$data.isComponent

  isValidModule: (n) ->
    return @isValidVC(n) and n.$data.isModule


if define?
  define('vc_global', [], () ->
    return GlobalClass
  )
else
  module.exports = GlobalClass
  return GlobalClass
