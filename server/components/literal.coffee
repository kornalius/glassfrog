module.exports = [

  name: 'Literal'
  desc: 'Literal value'
  extra:
    options: 'h'
    icon: 'tag8'
    code:
      generate: (arg, client) ->
        return arg.getValue()
,

  name: 'String'
  desc: 'String object'
  extra:
    inherit: 'Literal'
    icon: 'quote-right'
    code:
      generate: (arg, client) ->
        return '"{0}"'.format(arg.getValue())
,

  name: 'Number'
  desc: 'Number object'
  extra:
    inherit: 'Literal'
    icon: 'hash'
    code:
      generate: (arg, client) ->
        return parseInt(arg.getValue(), 10).toString()
,

  name: 'Boolean'
  desc: 'Boolean object'
  extra:
    inherit: 'Literal'
    icon: 'switchon'
    code:
      argument: (arg, client) ->
        v = arg.getValue().toLowerCase()
        if v == 'true' or v = 't' or v == 'yes' or v = 'y' or v = 'ok'
          return "true"
        else
          return "false"
,

  name: 'Date'
  desc: 'Date object'
  extra:
    inherit: 'Literal'
    icon: 'calendar32'
    code:
      generate: (arg, client) ->
        console.log arg
#        m = moment(arg.getValue())
#        console.log m
#        if m.isValid
#          return d.format('L LT')
#        else
#          return moment().format('L LT')
,

  name: 'Html'
  desc: 'Html object'
  extra:
    inherit: 'Literal'
    icon: 'chevrons'
    code:
      generate: (arg, client) ->
        if client
          return "$('{0}')".format(arg.getValue())
,

  name: 'JSON'
  desc: 'JSON object'
  extra:
    inherit: 'Literal'
    icon: 'braces'
    code:
      generate: (arg, client) ->
        if client
          return "\{{0}\}".format(arg.getValue())
,

  name: 'Array'
  desc: 'Array object'
  extra:
    inherit: 'Literal'
    icon: 'squarebrackets'
    code:
      generate: (arg, client) ->
        if client
          return "\{{0}\}".format(arg.getValue())
,

  name: 'RegExp'
  desc: 'Regular Expression object'
  extra:
    inherit: 'Literal'
    icon: 'asterisk'
    code:
      generate: (arg, client) ->
        if client
          return "/{0}/".format(arg.getValue())
,

  name: 'Expression'
  desc: 'Expression'
  extra:
    inherit: 'Literal'
    icon: 'sum'
    code:
      generate: (arg, client) ->
        if client
          return "({0})".format(arg.getValue())

]

