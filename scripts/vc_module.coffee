ModuleClass =

#  @name
#  @desc
#  @version
#  @share
#  @extra
#    root
#    icon
#    color
#    options

  Node: null

  setData: (m) ->
    if m.clearData
      m.clearData()

    m.$data = {}
    m.$data._states = ''
    m.$data._json = {}

    if m.extra
      m.$data._json = JSON.parse(m.extra)

      if !m.$data._json.root
        nn = { name: 'Root', component: 'root' }
        m.$data._json.root = nn

      ModuleClass.Node.make(m.$data._json.root, null, m)


    m.getRoot = () ->
      return @$data._json.root

    m.setRoot = (n) ->
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
      if @$data._json.options? then @$data._json.options else ''

    m.setOptions = (o) ->
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
      @$data._states.indexOf(s) > -1

    m.addState = (s) ->
      if !@hasState(s)
        @$data._states += s

    m.delState = (s) ->
      i = @$data._states.indexOf(s)
      if i != -1
        @$data._states = @$data._states.substr(0, i) + @$data._states.substr(i + 1)

    m.isSaved = () ->
      !@isModified()

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
      @extra = JSON.stringify(@$data._json)

    m.getIcon = () ->
      if @$data._json.icon
        return @$data._json.icon
      else
        return 'box4'

    m.getColor = () ->
      if @$data._json.color
        return @$data._json.color
      else
        return ''

    m.versionString = () ->
      "v{0}.{1}.{2}{3}".format(@version.major, @version.minor, @version.build, @version.maintenance)

    m.foreachNode = (f, recursive) ->
      for c in @getNodes(recursive)
        f(c)


  make: (m) ->
    @setData(m)
    for n in m.$data._json.root.nodes
      ModuleClass.Node.make(n, m.$data._json.root, m)


if define?
  define('vc_module', ['vc_node'], (nd) ->
    ModuleClass.Node = nd
    return ModuleClass
  )
else
  ModuleClass.Node = require("./vc_node")
  module.exports = ModuleClass
