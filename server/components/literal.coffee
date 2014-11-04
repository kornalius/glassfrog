module.exports = [

  name: 'Literal.Category'
  desc: 'Literal value'
  extra:
    display: 'Literal'
    options: 'c'
    icon: 'cic-tag8'
    color: 'gray'
,

  name: 'Literal'
  desc: 'Literal value'
  extra:
    category: 'Literal.Category'
    options: 'h'
    icon: 'cic-tag8'
    color: 'gray'
    code:
      client_server: (out, arg, user) ->
        out.append '{0}'.format(arg.toString())
,

  name: 'Literal.String'
  desc: 'String object'
  extra:
    inherit: 'Literal'
    icon: 'cic-quote-right'
    default: ''
    code:
      client_server: (out, arg, user) ->
        out.append '\'{0}\''.format(arg.toString())
,

  name: 'Literal.Number'
  desc: 'Number object'
  extra:
    inherit: 'Literal'
    icon: 'cic-hash'
    default: 0
    code:
      client_server: (out, arg, user) ->
        out.append '{0}'.format(arg.toNumber())
,

  name: 'Literal.Boolean'
  desc: 'Boolean object'
  extra:
    inherit: 'Literal'
    icon: 'cic-switchon'
    default: false
,

  name: 'Literal.Date'
  desc: 'Date object'
  extra:
    inherit: 'Literal'
    icon: 'cic-calendar32'
    code:
      client_server: (out, arg, user) ->
        out.append 'moment(\'{0}\')'.format(arg.toDateTime().format('L'))
,

  name: 'Literal.DateTime'
  desc: 'Date and time object'
  extra:
    inherit: 'Literal'
    icon: 'cic-appointment'
    options: 'h'
    code:
      client_server: (out, arg, user) ->
        out.append 'moment(\'{0}\')'.format(arg.toDateTime().format('L LT'))
,

  name: 'Literal.Time'
  desc: 'Time object'
  extra:
    inherit: 'Literal'
    icon: 'cic-clock23'
    options: 'h'
    code:
      client_server: (out, arg, user) ->
        out.append 'moment(\'{0}\')'.format(arg.toDateTime().format('LT'))
,

  name: 'Literal.Color'
  desc: 'Color'
  extra:
    inherit: 'Literal'
    icon: 'cic-palette'
    default: tinycolor('black').toHex8String()
    code:
      client_server: (out, arg, user) ->
        out.append 'tinycolor(\'{0}\')'.format(arg.toColor().toHex8String())
,

  name: 'Literal.Html'
  desc: 'Html object'
  extra:
    inherit: 'Literal'
    icon: 'cic-chevrons'
    code:
      client_server: (out, arg, user) ->
        out.append '$(\'{0}\')'.format(arg.toHtml())
,

  name: 'Literal.JSON'
  desc: 'JSON object'
  extra:
    inherit: 'Literal'
    icon: 'cic-braces'
    default: {}
    code:
      client_server: (out, arg, user) ->
        out.append '\{{0}\}'.format(arg.toJSON())
,

  name: 'Literal.Array'
  desc: 'Array object'
  extra:
    inherit: 'Literal'
    icon: 'cic-squarebrackets'
    default: []
    code:
      client_server: (out, arg, user) ->
        out.append '[{0}]'.format(arg.toArray().join(', '))
,

  name: 'Literal.RegExp'
  desc: 'Regular Expression object'
  extra:
    inherit: 'Literal'
    icon: 'cic-asterisk'
    default: /$.*^/ig
    code:
      client_server: (out, arg, user) ->
        out.append '/{0}/'.format(arg.toString())
,

  name: 'Literal.Expression'
  desc: 'Expression'
  extra:
    inherit: 'Literal'
    icon: 'cic-sum'
    default: ->

    code:
      client_server: (out, arg, user) ->
        out.append '(/{0}/)'.format(arg.toString())
,

  name: 'Literal.Icon'
  desc: 'Icon'
  extra:
    inherit: 'Literal'
    icon: 'cic-uniF545'
    code:
      client_server: (out, arg, user) ->
        out.append '\'cic {0}\''.format(arg.toString())

]

