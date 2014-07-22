ArgClass =

#  name
#  desc
#  component
#  options
#  enum []
#  default

  VCGlobal: null
  VCComponent: null

  setData: (a) ->
    if a.clearData
      a.clearData()

    if !a._id
      a._id = makeId()

    a.$data = {}
    a.$data._component = null
    a.$data.isComponentArg = true

    a.hasData = () ->
      return @hasOwnProperty('$data')

    a.clearData = () ->
      if @hasData()
        delete @$data

    a.id = () ->
      @_id

    a.getName = () ->
      return (if @name then @name.toLowerCase() else "")

    a.displayName = () ->
      return (if @name then @name else "")

    a.getDesc = () ->
      return (if @desc then @desc else "")

    a.getComponent = () ->
      if @$data
        c = @$data._component
      else
        c = null

      if !c
        c = ArgClass.VCGlobal.findComponent(@component)
        @$data._component = c

      return c

    a.getDefault = () ->
      return (if @default then @default else "")

    a.getOptions = () ->
      if @options
        return @options
      else
        return ''

    a.hasOption = (s) ->
      o = @getOptions()
      if o?
        o.indexOf(s) > -1
      else
        return false

    a.hasEnum = () ->
      @getEnum().length

    a.getEnum = () ->
      l = []

      e = @$data and @$data.enum
      if e
        if typeof e is 'string'
          l = e.split(',')
        else if e instanceof Array
          l = e

      nl = []

      for i in [0..l.length - 1]
        ii = l[i]
        if ii and typeof ii is 'string'
          if ii.startsWith('#')
            nl = nl.concat(ArgClass.VCGlobal.findComponentsOfKind(ii.substr(1)))
          else if ii.toLowerCase() == '@module'
            nl = nl.concat(ArgClass.VCGlobal.modules.rows)
          else if ii.startsWith('@')
            nl = nl.concat(ArgClass.VCGlobal.findNodesOfKind(ii.substr(1)))
          else
            nl.push(ii)

      return nl

    a.isRequired = () ->
      !@hasOption('o')

    a.isOptional = () ->
      @hasOption('o')

    a.kindOf = (name) ->
      if name instanceof Array
        for n in name
          if @kindOf(n)
            return true
        return false
      else
        cc = @getComponent()
        return cc and cc.kindOf(name)


  make: (a) ->
    @setData(a)


if define?
  define('vc_arg', ['vc_global', 'vc_component'], (gd, cd) ->
    ArgClass.VCGlobal = gd
    ArgClass.VCComponent = cd
    return ArgClass
  )
else
  ArgClass.VCGlobal = require('./vc_global')
  ArgClass.VCComponent = require('./vc_component')
  module.exports = ArgClass
