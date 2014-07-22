if (window? and !window.cg) or (global? and !global.cg)

  class cg
    lvl: 0
    code: ''

    constructor: (lvl, code) ->
      if lvl?
        @lvl = lvl
      else
        @lvl = 0
      if code?
        @code = code
      else
        @code = ''

    toString: () ->
      return '(' + @lvl + ') cg.code: "' + @code + '"'

    trace: () ->
      indent = _.str.repeat('  ', @lvl)
      console.log indent + @toString()
      console.trace()
      console.log ""

    cg: () ->
      return new cg(@lvl)

    process: (l) ->
      if !l
        return ''
      else if type(l) is 'object' and l.cg and l.code
        return l.code
      else if type(l) is 'function'
        @trace()
        n = @cg()
        l.call(n)
        return n.process(n)
      else if l.toString
        return l.toString()
      else
        return l

    getArgs: (args...) ->
      l = []
      while args and args.length and args[0] instanceof Array
        args = args[0]
      for a in args
        if a?
          l.push(@process(a))
      return l

    argsToStr: (args...) ->
      return @argsToStrSep(null, args)

    argsToStrSep: (separator, args...) ->
      l = @getArgs(args)
      if separator and separator != ''
        return l.join(separator)
      else
        ss = ""
        for ll in l
          ss += ll
        return ss

    out: (str...) ->
      indent = _.str.repeat('  ', @lvl)
      if (@code == '' or @code.endsWith('\n')) and !@code.endsWith(indent)
        @code += indent
      @code += @argsToStr(str)
      @trace()
      return @
      
    lines: (lines, separator) ->
      if !lines?
        lines = []
      lines = @process(lines).split('\n')
      for l in lines
        if l
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

    comma: (force) ->
      if force? or !@ends(',')
        @code += ', '
      return @

    space: (force) ->
      if force? or (!@code.endsWith(' ') and !@code.endsWith('\n'))
        @code += ' '
      return @

    open: (b, force) ->
      if force? or !@ends(b)
        @code += b
      return @

    close: (b, force) ->
      if force? or !@ends(b)
        @code += b
      return @

    endline: (force) ->
      @semicolon(force).cr(force)
      return @

    surround: (b, args...) ->
      switch(b)
        when '(' then e = ')'
        when '{' then e = '}'
        when '[' then e = ']'
        else e = b
      return b + @argsToStr(args) + e

    level: (inc) ->
      @lvl = Math.max(0, @lvl + inc)
      return @

    startblock: () ->
      @open('{').level(1)
      return @

    trim_endblock: () ->
      s = @code
      while s.charAt(s.length - 1) in [',', '\n', '\t', ' ']
        s = s.substr(0, s.length - 1)
      @code = s
      return @

    endblock_stmt: () ->
      @trim_endblock().level(-1).cr().close('}').endline()
      return @
      
    endblock_expr: () ->
      @trim_endblock().level(-1).close('}')
      return @

    block_stmt: (code) ->
      @cr()
        .startblock()
          .lines(code)
        .trim_endblock().close('}')
      .cr()
      return @

    block_expr: (code) ->
      @startblock()
        .lines(code)
      .trim_endblock().close('}')
      return @

    csv: (args...) ->
      return @argsToStrSep(', ', args)

    args: (args...) ->
      @out(@surround('(', @csv(args)))
      return @

    variable: (name, args) ->
      @out('var ', name, ' = ', @argsToStr(args)).endline()
      return @

    array_literal: (args...) ->
      @out(@surround('[', @csv(args)))
      return @

    string_literal: (str) ->
      @out(@surround((if str.indexOf("'") then '"' else "'"), str))
      return @

    literal: (str) ->
      @out(str)
      return @

    label: (name, args...) ->
      @out(name, ': ', @argsToStr(args))
      return @

    sequence: (args...) ->
      @out(@csv(args))
      return @

    fct_stmt: (name, args, code) ->
      @blankline()
      @out('function ', name).args(args)
      if code?
        @block(code)
      @blankline()
      return @

    fct_expr: (args, code) ->
      @out('function ').args(args)
      if code?
        @block(code)
      return @

    call_stmt: (name, args...) ->
      @out(name).args(args).endline()
      return @

    call_expr: (name, args...) ->
      @out(name).args(args)
      return @

    member_stmt: (args...) ->
      name = args.shift()
      method = args.shift()
      @out(name, '.', method).args(args).endline()
      return @

    member_expr: (name, method, args...) ->
      @out(name, '.', method).args(args)
      return @

    if_stmt: (condition, true_code, false_code) ->
      @out('if').open('(').out(condition).close(')').block(true_code)
      if false_code?
        @else_stmt(false_code)
      return @

    if_expr: (condition, true_code, false_code) ->
      @open('(').out(condition).close(')').out(' ? ').block(true_code).block(false_code)
      return @

    else_stmt: (code) ->
      @out('else').block(code)
      return @

    elseif_stmt: (condition, code) ->
      @out('else').if_stmt(condition, code)
      return @


  if window?
    window.cg = cg
  else if global?
    global.cg = cg
