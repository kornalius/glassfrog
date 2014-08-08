if (window? and !window.cg) or (global? and !global.cg)

  class cg
    lvl: 0
    code: ''
    _indent = ''

    constructor: (lvl, code) ->
      if lvl?
        @lvl = lvl
      else
        @lvl = 0
      @_indent = _.str.repeat('  ', @lvl)
      if code?
        @code = code
      else
        @code = ''
#      console.log "cg.constructor()", @lvl, @code, @_indent.length

    toString: () ->
      return '(' + @lvl + ') cg.code: "' + @code + '"'

    trace: () ->
      console.log @toString()
      console.trace()
      console.log ""

    cg: (lvl) ->
      if !lvl?
        lvl = @lvl
      n = new cg(lvl)
#      console.log "cg()", n.lvl, n.code, n._indent.length
      return n

    out: (s) ->
#      debugger
      if @code == '' or !@code.endsWith(@_indent)
        @code += @_indent
      @code += s
      return @

    line: (l, model, separator) ->
      if !l
        l = ""
      if !model
        model = {}
      if !separator
        separator = ';'
      l = Mustache.render(l, model)
      @out(_.str.trim(l))
      if separator? and !@code.endsWith(separator)
        @code += separator
      @cr()
      return @

    cr: (force) ->
      if force? or !@code.endsWith('\n')
        @code += '\n'
      return @

    blankline: () ->
      if !@code.endsWith('\n\n')
        if !@code.endsWith('\n')
          @code += '\n\n'
        else
          @code += '\n'
      return @

    ends: (str) ->
      x = str.length - 1
      i = @code.length - 1
      while i >= 0 and x >= 0
        c = @code.charAt(i)
        if c == ' ' or c == '\t' or c == '\n'
          i--
        else if c == str[x]
          x--
          i--
        else
          return false
      return x == 0

    semicolon: (force) ->
      if force? or !@ends(';')
        @code += ';'
      return @

    endline: (force) ->
      @semicolon(force).cr(force)
      return @

    level: (inc) ->
      @lvl = Math.max(0, @lvl + inc)
      @_indent = _.str.repeat('  ', @lvl)
      return @

    process: (l) ->
      if !l
        return ''
      else if type(l) is 'object' and l.cg and l.code
        return l.code
      else if type(l) is 'function'
        n = @cg()
        l.call(n)
        return n.process(n)
      else
        if l.toString
          return l.toString()
        else
          return l

    getArgs: (args) ->
      l = []
      if type(args) != 'array'
        args = [args]
      for a in args
        l.push(@process(a))
      return l

    argsToString: (args, separator) ->
      if !separator
        separator = ""
      return @getArgs(args).join(separator)


  if window?
    window.cg = cg
  else if global?
    global.cg = cg
