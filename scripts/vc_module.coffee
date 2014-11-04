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

    m.varName = () ->
      return @displayName().camelize(false)

    m.getClassName = () ->
      return @varName().camelize(true)

    m.displayName = () ->
      if @name
        return @name
      else
        return "Untitled"

    m.setName = (name) ->
      if @name != name
        @name = name
        @setModified(true)

    m.getDesc = () ->
      return (if @desc then @desc else "")

    m.setDesc = (desc) ->
      if @desc != desc
        @desc = desc
        @setModified(true)

    m.getReadme = () ->
      return (if @readme then @readme else "")

    m.setReadme = (readme) ->
      if @readme != readme
        @readme = readme
        @setModified(true)

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
          c.name = @name
          c.setArg('icon', @getIcon())
          c.setArg('color', @getColor())
          c.setArg('desc', @getDesc())
          c.setArg('readme', @getReadme())
          c.setArg('tags', _.clone(@getTags()))
          c.setArg('version', @versionString())
          cb() if cb
        else
          cb() if cb

    m.setConfig = () ->
      if @$data
        c = @getRoot().childrenOfKind(['Module.Config'])
        if c and c.length
          c = c[0]
          @setName(c.name)
          @setColor(c.getArgValueOrDefault('color'))
          @setIcon(c.getArgValueOrDefault('icon'))
          @setDesc(c.getArgValueOrDefault('desc'))
          @setReadme(c.getArgValueOrDefault('readme'))
          @setTags(c.getArgValueOrDefault('tags'))
          @setVersion(c.getArgValueOrDefault('version'))

    m.getIcon = () ->
      if @icon
        return @icon
      else
        return 'cic-ruler3'

    m.setIcon = (icon) ->
      if @icon != icon
        @icon = icon
        @setModified(true)

    m.getColor = () ->
      if @color
        return @color
      else
        return null

    m.setColor = (color) ->
      if type(color) is 'tinycolor'
        color = color.toHex8String()
      if !_.isEqual(@color, color)
        @color = _.clone(color)
        @setModified(true)

    m.versionString = () ->
      @getVersion().versionString()

    m.getVersion = () ->
      new ModuleClass.VersionClass(@version)

    m.setVersion = (version) ->
      v = new ModuleClass.VersionClass(version)
      if @getVersion().compareTo(v) != 0
        @version = v.versionString()
        @setModified(true)

    m.getTags = () ->
      if !@tags
        @tags = []
      if @tags.indexOf('module') == -1
        @tags.push('module')
      return @tags

    m.setTags = (tags) ->
      if type(tags) is 'string'
        tags = tags.split(',')
      tags.map((t) -> t.toLowerCase())
      if !_.isEqual(@tags, tags)
        @tags = _.clone(tags)
        @setModified(true)

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
        for n in r.childrenAsLinks()
          m = n.module()
          if m and l.indexOf(m) == -1
            l.push(m)
      return l

    m.generateCode = (codetype, user) ->
      r = @getRoot()
      if r
        out = new StringBuilder()

        r.generateCode(out, codetype, user, 'init')
        if !out.error()
          r.generateCode(out, codetype, user)
          if !out.error()
            r.generateCode(out, codetype, user, 'shut')

        ss = out.toString()
        if !ss.endsWith('\n')
          ss += '\n'

      if out.error()
        return { code: ss, error: out.error() }
      else
        return ModuleClass.handleSyntax(@, ss)

    m.edit = (cb) ->
      that = @
      mod = that.isModified()
      ModuleClass.async.eachSeries(ModuleClass.VCGlobal.modules.rows, (mm, callback) ->
        mm.saveLocally((ok) ->
          callback((if ok then null else true))
        )
      , (err) ->
        if !err
          if window?
            window.setTimeout(->
              that.setConfigNode(->
                for mm in ModuleClass.VCGlobal.modules.rows
                  mm.delState('e')
                that.setModified(mod)
                that.addState('e')
                cb(true) if cb
              )
            )
          else
            cb(false) if cb
        else
          cb(false) if cb
      )

    m.clearSyntax = () ->
      for n in @getNodes(true)
        if n.$data
          n.$data._error = null

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

    m.showSyntaxError = (error) ->
      if error.message
        ll = error.message.split('\n')
      else
        ll = []

      if window? and angular?
        if error.messageHtml
          ll = error.messageHtml.split('\n')
        angular.injector(['app.globals']).invoke(['Globals', (globals) ->
          globals.showMessage(ll.join('\n'), 'error', (if error.name then error.name else 'Error'), 'cic cic-spam3 large', false, '600px')
        ])
#        angular.injector(['editor']).get('Editor').
      else
        len = _.max(_.pluck(ll, 'length'))
        console.log ''
        console.log _.str.pad('', len, '―')
        for l in ll
          console.log l
        console.log _.str.pad('', len, '―')
        console.log ''

    m.syntaxError = (error, lines) ->
      ll = []
      llh = ['<pre style="background: none; border: none; white-space: nowrap;">']

      error.desc = error.toString()

      if error.loc
        el = error.loc.line
        min = Math.max(0, el - 3)
        max = Math.max(0, el + 3)
        for l in [min..max]
          if l == el
            if error._id
              n = ModuleClass.VCGlobal.findNode(@, error._id, true)
            else
              n = null
            msg = _.str.pad('', lines[l].indexOf('| ') + 2 + error.loc.column, '·') + '▲  ' + error + ' #' + error._id + (if n then ' ["{0}" <{1}>]'.format(n.pathname(true, true), n.getComponent().displayName()) else '')
            llh.push('<span style="border-radius: 2px; background-color: #d9534f; color: #f5f5f5;">' + msg.replace(/\s/g, '&nbsp;') + '</span>')
            ll.push(msg)
          llh.push(lines[l].replace(/\s/g, '&nbsp;'))
          ll.push(lines[l])

      llh.push('</pre>')

      error.message = ll.join('\n')
      error.messageHtml = llh.join('<br>')

      if ll.length
        @showSyntaxError(error)

      return ll

    hasRepo: () ->
      @repo


  make: (m) ->
    @setData(m)
    if m.$data._json.root and m.$data._json.root.nodes
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

  handleSyntax: (m, s) ->
    syntax = null

    codeStr = js_beautify(s, {indent_size: 2, max_preserve_newlines: 2, keep_array_indentation: true, brace_style: 'collapse', e4x: true})
    syntax = @VCGlobal.checkSyntax(codeStr)

    console.log ""
    console.log ""
    lines = syntax.code.toSourceCode().split('\n')
    for l in lines
      console.log l
    console.log ""
    console.log ""

    if syntax.error
      m.syntaxError(syntax.error, lines)

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
