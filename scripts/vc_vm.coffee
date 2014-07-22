VMClass =

  VCGlobal: null
  VCNode: null
  VCComponent: null
  VCModule: null
  async: null

  contexts: []
  currentContext: null
  stepMode: ' '
  objects: {}

  findObject: (name) ->
    @objects[name]

  newObject: (name, value) ->
    @objects[name] = value

  delObject: (name) ->
    delete @objects[name]

  isStep: () ->
    @stepMode in ['s', 'i', 'o']

  isStepIn: () ->
    @stepMode == 'i'

  isStepOut: () ->
    @stepMode == 'o'

  newContext: (n) ->
    cc = { node: n, object: @findObject(n.varName()) }
    @contexts.push(cc)
    currentContext = cc
    return cc

  endContext: () ->
    if @contexts.length
      cc = @contexts.pop()
    else
      cc = null
    currentContext = cc
    return cc

  singleArg: (args) ->
    return (if args and args.length == 1 then args[0] else args)

  run: (n, client, cb) ->
    c = n.getComponent()
    if c

      isNewContext = c.newContext()
      if isNewContext
        @newContext(n)

      args = []
      if n instanceof Array
        l = n
      else
        l = n.children()

      that = @

      @async.eachSeries(l, (nn, callback) ->
        that.run(nn, client, (v) ->
          if v
            args.push({ node: nn, component: nn.getComponent(), value: v })
          callback()
        )
      , (err) ->
        c.doRun(that, n, client, args, (res) ->
          if isNewContext
            that.endContext()
          cb(res)
        )
      )

    else
      cb(null)


if define?
  define('vc_vm', ['vc_global', 'vc_node', 'vc_component', 'vc_module', 'async'], (gd, nd, cd, md, ad) ->
    VMClass.VCGlobal = gd
    VMClass.VCNode = nd
    VMClass.VCComponent = cd
    VMClass.VCModule = md
    VMClass.async = ad
    return VMClass
  )
else
  VMClass.VCGlobal = require('./vc_global')
  VMClass.VCNode = require('./vc_node')
  VMClass.VCComponent = require('./vc_component')
  VMClass.VCModule = require('./vc_module')
  VMClass.async = require('async')
  module.exports = VMClass
