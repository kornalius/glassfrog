Handlebars.registerHelper('generate_nodes', (o, client, user, componentType, delimiter) ->
  if !delimiter?
    delimiter = '\n'
  if o.$data?.isModule
    r = o.getRoot()
  else
    r = o
  if componentType == '*'
    nodes = r.children()
  else
    nodes = r.childrenOfKind(componentType.split(','))
  d = []
  for n in nodes
    s = n.generateCode(client, user)
    if s and s.length
      d.push(s)
  return new Handlebars.SafeString(d.join(delimiter))
)

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
  async: null

  setData: (m) ->
    if m.clearData
      m.clearData()

    m.$data = {}
    m.$data._states = ''
    m.$data._json = {}
    m.$data.isModule = true
    m.$data._syntax = null
    m.prevGenerate = null

    if m.extra
      if type(m.extra) is 'string'
        m.$data._json = stringToJson(m.extra)
      else
        m.$data._json = _.cloneDeep(m.extra)

    if m.$data._json.root
      ModuleClass.VCNode.make(m.$data._json.root, null, m)


    m.id = () ->
      @_id

    m.initRoot = () ->
      nn =
        name: 'Root'
        component: 'root'
        nodes: [
          name: 'Config'
          component: 'Module.Config'
        ]
      ModuleClass.VCNode.make(nn, null, m)
      m.$data._json.root = nn

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
      if @$data and !@$data._json.root
        @initRoot()
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
      console.log "setExtra()", e
      if type(e) is 'string'
        @extra = e
      else
        ne = {}
        if e.options?
          ne.options = e.options
        if e.root?
          if e.root.plainObject?
            ne.root = e.root.plainObject()
          else
            ne.root = e.root
        try
          @extra = jsonToString(ne)
        catch e
          console.log "Error stringifying JSON data", e

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
      @hasState('m')

    m.setModified = (b) ->
      if b
        @addState('m')

#        if window?
#          if @$data.prevGenerate
#            window.clearTimeout(@$data.prevGenerate)
#            delete @$data.prevGenerate
#            @$data.prevGenerate = null
#
#          that = @
#          @$data.prevGenerate = window.setTimeout(->
#            that.generateCode(true)
#            delete that.$data.prevGenerate
#            that.$data.prevGenerate = null
#          , 1000)

      else
        @delState('m')
        @getRoot().foreachChild((n) ->
          n.delState('m')
          args = n.getArgs()
          for k of args
            args[k].delState('m')
        , true)

    m.setConfigNode = (cb) ->
      if @$data
        c = @getRoot().childrenOfKind(['Module.Config'])
        if c and c.length
          c = c[0]
          that = @
          require(['VersionClass'], (VersionClass) ->
#            console.log "setConfigNode()", mod, c, c.name
            c.name = that.name
            c.getArg('icon').value = that.icon
            c.getArg('desc').value = that.desc
            c.getArg('version').value = (new VersionClass(that.version)).versionString()
            cb() if cb
          )
        else
          cb() if cb

    m.setConfig = () ->
      if @$data
        c = @getRoot().childrenOfKind(['Module.Config'])
        if c and c.length
          c = c[0]
          that = @
          require(['VersionClass'], (VersionClass) ->
#            console.log "setConfig()", c, c.name
            that.name = c.name
            that.icon = c.getArg('icon').getValueOrDefault()
            that.desc = c.getArg('desc').getValueOrDefault()
            that.version = new VersionClass(c.getArg('version').getValueOrDefault())
          )

    m.getIcon = () ->
      if @icon
        return @icon
      else
        return 'cic-ruler3'

    m.getColor = () ->
      if @color
        return @color
      else
        return null

    m.versionString = () ->
      new ModuleClass.VersionClass(@version).versionString()

    m.setVersion = (str) ->
      that = @
      require(['VersionClass'], (VersionClass) ->
        that.version = new VersionClass(str)
      )

    m.foreachNode = (f, recursive) ->
      for c in @getNodes(recursive)
        f(c)

    m.domName = (type) ->
      if !type?
        type = 'element'
      'module-' + type + '_' + @getName()

    m.domId = (type) ->
      if !type?
        type = 'element'
      'module-' + type + '-id_' + @id()

    m.element = (type) ->
      e = angular.element('#' + @domId(type))
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

    m.schemas = () ->
      @getRoot().childrenOfKind('Schema')

    m.routes = () ->
      @getRoot().childrenOfKind('Route')

    m.resolveModules = () ->
      l = []
      r = @getRoot()
      if r
        links = r.childrenAsLinks()
        for n in links
          m = n.module()
          if m and l.indexOf(m) == -1
            l.push(m)
      return l

    m.generateCode = (client, user) ->
      s = "'use strict';\n\n"

      r = @getRoot()
      if r
        ss = r.generateCode(client, user)
        if !ss.endsWith('\n')
          ss += '\n'
        s += ss

      return ModuleClass.handleSyntax(s)

    m.edit = (cb) ->
      that = @
      mod = that.isModified()
      ModuleClass.async.eachSeries(ModuleClass.VCGlobal.modules.rows, (mm, callback) ->
        mm.saveLocally((ok) ->
          callback((if ok then null else true))
        )
      , (err) ->
        if !err
          that.addState('e')
          if window?
            window.setTimeout( ->
              that.setConfigNode(->
                that.setModified(mod)
                cb(true) if cb
              )
            )
        else
          cb(false) if cb
      )

    m.plainObject = () ->
      o = {}
      for k of @
        if type(@[k]) != 'function' and k != '$data'
          o[k] = _.cloneDeep(@[k])
      return o

    m.saveLocally = (cb) ->
      if @isEditing() and @isModified()
        @delState('e')
        @setConfig()
#        @setModified(false)
        @setExtra(
          root: @getRoot().plainObject()
          options: (if @$data and @$data._json.options? then @$data._json.options else '')
        )
      cb(true) if cb


  make: (m) ->
    @setData(m)
    if m.$data._json.root
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

  handleSyntax: (s) ->
    syntax = null

    codeStr = js_beautify(s, {indent_size: 2})
    syntax = @VCGlobal.checkSyntax(codeStr)
#    if !@$data._syntax
#      @$data._syntax = { client: null, server: null }
#    if client
#      @$data._syntax.client = syntax
#    else
#      @$data._syntax.server = syntax

    lines = syntax.code.split('\n')
    for i in [0..lines.length - 1]
      console.log i + 1, lines[i]

    if syntax.error

      ll = []
      if syntax.error.loc
        min = Math.max(0, syntax.error.loc.line - 5)
        for l in [min..syntax.error.loc.line - 1]
          ll.push(_.str.lpad('{0}'.format(l), 4) + '. ' + lines[l])
        ss = _.str.pad("", syntax.error.loc.column + 6) + '^'
      else
        ss = null

      console.log ''
      console.log "SYNTAX ERROR:", syntax.error
      console.log ll.join('\n')
      if ss
        console.log ss
      console.log ''

      if window? and PNotify
        notice = new PNotify(
          title: 'Syntax Error'
          text: '<pre style="background: none; border: none">' + ll.join('\n') + '\n' + ss + '\n<span class="label-danger", style="color: white;">' + syntax.error + '</span></pre>'
          icon: 'cic cic-spam3'
          type: 'error'
          hide: false
          width: "500px"
          buttons:
            sticker: false
        )
#            notice.get().click(->
#              notice.remove()
#            )
    return syntax

#  evalCode: (code) ->
#    r = null
#    try
#      r = eval(code)
#    catch e
#      console.log "Eval error", e
#    return r


if define?
  define('vc_module', ['vc_global', 'vc_node', 'VersionClass', 'async'], (gd, nd, vd, ad) ->
#    require(['vc_global', 'vc_node', 'VersionClass'], (gd, nd, vd) ->
    ModuleClass.VCGlobal = gd
    ModuleClass.VCNode = nd
    ModuleClass.VersionClass = vd
    ModuleClass.async = ad
    return ModuleClass
  )
else
  ModuleClass.VCGlobal = require('./vc_global')
  ModuleClass.VCNode = require("./vc_node")
  ModuleClass.VersionClass = require("./version")
  ModuleClass.async = require("async")
  module.exports = ModuleClass
  return ModuleClass
