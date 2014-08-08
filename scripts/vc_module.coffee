ModuleClass =

#  @name
#  @desc
#  @version
#  @share
#  @icon
#  @color
#  @extra
#    root
#    options

  VCGlobal: null
  VCNode: null
  VersionClass: null

  setData: (m) ->
    if m.clearData
      m.clearData()

    m.$data = {}
    m.$data._states = ''
    m.$data._json = {}
    m.$data.isModule = true
    m.$data._syntax = null

    if m.extra
      if typeof m.extra is 'string'
        m.$data._json = JSON.parse(m.extra)
      else
        m.$data._json = _.cloneDeep(m.extra)

      if !m.$data._json.root
        nn = { name: 'Root', component: 'root' }
        m.$data._json.root = nn

      ModuleClass.VCNode.make(m.$data._json.root, null, m)


    m.id = () ->
      @_id

    m.getName = () ->
      return (if @name then @name.toLowerCase() else "")

    m.getDesc = () ->
      return (if @desc then @desc else "")

    m.displayName = () ->
      if @name
        return @name
      else
        return "Untitled"

    m.getRoot = () ->
      return (if @$data and @$data._json.root then @$data._json.root else null)

    m.setRoot = (n) ->
      if @$data
        @$data._json.root = n
      @setModified(true)

    m.hasNodes = () ->
      @getNodes() and @getNodes().length

    m.getNodes = (recursive) ->
      @getRoot().children(recursive)

    m.setNodes = (nodes) ->
      @getRoot().setChildren(nodes)
      @setModified(true)

    m.hasExtra = () ->
      @extra

    m.setExtra = (e) ->
      if typeof e is 'string'
        @extra = e
      else
        @extra = JSON.stringify(e)

    m.hasShare = () ->
      @share

    m.hasData = () ->
      return @hasOwnProperty('$data')

    m.clearData = () ->
      if @hasData()
        delete @$data

    m.options = () ->
      return (if @$data and @$data._json.options? then @$data._json.options else '')

    m.setOptions = (o) ->
      if @$data
        @$data._json.options = o
      @setModified(true)

    m.hasOption = (s) ->
      @options().indexOf(s) > -1

    m.addOption = (s) ->
      if !@hasOption(s)
        @setOptions(@options() + s)

    m.delOption = (s) ->
      o = @options()
      i = o.indexOf(s)
      if i != -1
        @setOptions(o.substr(0, i) + o.substr(i + 1))

    m.hasState = (s) ->
      if @$data
        @$data._states.indexOf(s) > -1

    m.addState = (s) ->
      if !@hasState(s) and @$data
        @$data._states += s

    m.delState = (s) ->
      if @$data
        i = @$data._states.indexOf(s)
        if i != -1
          @$data._states = @$data._states.substr(0, i) + @$data._states.substr(i + 1)

    m.isSaved = () ->
      !@isModified()

    m.isEditing = () ->
      @hasState('e')

    m.isModified = () ->
      for n in @getNodes(true)
        if n.isModified()
          return true
      return false

    m.setModified = (b) ->
      if b
        @getRoot().setModified(true)
      else
        @getRoot().setModified(false)
        @getRoot().foreachChild((n) ->
          n.setModified(false)
        , true)
      if @$data
        @extra = JSON.stringify(@$data._json)

    m.getIcon = () ->
      if @icon
        return @icon
      else
        return 'ruler3'

    m.getColor = () ->
      if @color
        return @color
      else
        return null

    m.versionString = () ->
      new ModuleClass.VersionClass(@version).versionString()

    m.foreachNode = (f, recursive) ->
      for c in @getNodes(recursive)
        f(c)

    m.element = () ->
      e = angular.element('#module-element-id_' + @id())
      if e and e.length
        return e
      else
        return null

    m.scope = () ->
      e = @element()
      if e
        scope = e.scope()
        return scope
      return null

    m.doGenerate = (client) ->
      syntax = null
      r = @getRoot()
      if r
        s = ""
        for n in r.children()
          ss = n.doGenerate(client)
          if !ss.endsWith('\n')
            ss += '\n'
          s += ss
        syntax = ModuleClass.VCGlobal.checkSyntax(s)
        if !@$data._syntax
          @$data._syntax = { client: null, server: null }
        if client
          @$data._syntax.client = syntax
        else
          @$data._syntax.server = syntax
#      console.log "module generate", syntax

      lines = syntax.code.split('\n')
      for i in [0..lines.length - 1]
        console.log i + 1, lines[i]

      if syntax.error
        console.log "ERROR:", syntax.error
        if syntax.error.loc
          console.log lines[syntax.error.loc.line - 1]
          ss = ""
          for i in [0..syntax.error.loc.column - 1]
            ss += ' '
          console.log ss + '^'

      return syntax

  make: (m) ->
    @setData(m)
    for n in m.$data._json.root.nodes
      ModuleClass.VCNode.make(n, m.$data._json.root, m)

  list: () ->
    l = []

    if @VCGlobal.modules
      for m in @VCGlobal.modules.rows
        l.push(m)

    return l.sort((a, b) ->
      ao = a.name
      bo = b.name
      if ao < bo
        return -1
      else if ao > bo
        return 1
      else
        return 0
    )

  elements: () ->
    e = angular.element('#editor-modules-root')
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
  define('vc_module', ['vc_global', 'vc_node', 'VersionClass'], (gd, nd, vd) ->
#    require(['vc_global', 'vc_node', 'VersionClass'], (gd, nd, vd) ->
    ModuleClass.VCGlobal = gd
    ModuleClass.VCNode = nd
    ModuleClass.VersionClass = vd
    return ModuleClass
  )
else
  ModuleClass.VCGlobal = require('./vc_global')
  ModuleClass.VCNode = require("./vc_node")
  ModuleClass.VersionClass = require("./version")
  module.exports = ModuleClass