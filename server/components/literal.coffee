module.exports = [

  name: 'Literals'
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
    category: 'Literals'
    options: 'h'
    icon: 'cic-tag8'
    color: 'gray'
    code:
      both: (arg, user) ->
        Handlebars.compile('{{value}}')({value: arg.getValueOrDefault()})
,

  name: 'Literal.String'
  desc: 'String object'
  extra:
    inherit: 'Literal'
    icon: 'cic-quote-right'
    default: ''
    code:
      both: (arg, user) ->
        Handlebars.compile('\'{{value}}\'')({value: arg.getValueOrDefault()})
,

  name: 'Literal.Number'
  desc: 'Number object'
  extra:
    inherit: 'Literal'
    icon: 'cic-hash'
    default: 0
    code:
      both: (arg, user) ->
        v = arg.getValueOrDefault()
        return (if type(v) is 'number' and Number.isNaN(v) then '0' else v.toString())
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
      both: (arg, user) ->
        m = moment(arg.getValueOrDefault())
        if !m.isValid()
          m = moment()
        Handlebars.compile('moment(\'{{value}}\')')({value: m.format('L')})
,

  name: 'Literal.DateTime'
  desc: 'Date and time object'
  extra:
    inherit: 'Literal'
    icon: 'cic-appointment'
    options: 'h'
    code:
      both: (arg, user) ->
        m = moment(arg.getValueOrDefault())
        if !m.isValid()
          m = moment()
        Handlebars.compile('moment(\'{{value}}\')')({value: m.format('L LT')})
,

  name: 'Literal.Time'
  desc: 'Time object'
  extra:
    inherit: 'Literal'
    icon: 'cic-clock23'
    options: 'h'
    code:
      both: (arg, user) ->
        m = moment(arg.getValueOrDefault())
        if !m.isValid()
          m = moment()
        Handlebars.compile('moment(\'{{value}}\')')({value: m.format('LT')})
,

  name: 'Literal.Color'
  desc: 'Color'
  extra:
    inherit: 'Literal'
    icon: 'cic-palette'
    default: tinycolor('black').toHex8String()
    code:
      both: (arg, user) ->
        tc = tinycolor(arg.getValueOrDefault().toLowerCase())
        if !tc.isValid()
          tc = tinycolor('black')
        Handlebars.compile('tinycolor(\'{{value}}\')')({value: tc.toHex8String()})
,

  name: 'Literal.Html'
  desc: 'Html object'
  extra:
    inherit: 'Literal'
    icon: 'cic-chevrons'
    code:
      both: (arg, user) ->
        Handlebars.compile('$(\'{{value}}\')')({value: arg.getValueOrDefault()})
,

  name: 'Literal.JSON'
  desc: 'JSON object'
  extra:
    inherit: 'Literal'
    icon: 'cic-braces'
    default: {}
    code:
      both: (arg, user) ->
        Handlebars.compile('\{{{value}}\}')({value: arg.getValueOrDefault()})
,

  name: 'Literal.Array'
  desc: 'Array object'
  extra:
    inherit: 'Literal'
    icon: 'cic-squarebrackets'
    default: []
    code:
      both: (arg, user) ->
        Handlebars.compile('[{{value}}]')({value: arg.getValueOrDefault().join(', ')})
,

  name: 'Literal.RegExp'
  desc: 'Regular Expression object'
  extra:
    inherit: 'Literal'
    icon: 'cic-asterisk'
    default: /$.*^/ig
    code:
      both: (arg, user) ->
        Handlebars.compile('$(/{{value}}/')({value: arg.getValueOrDefault().toString()})
,

  name: 'Literal.Expression'
  desc: 'Expression'
  extra:
    inherit: 'Literal'
    icon: 'cic-sum'
    default: ->

    code:
      both: (arg, user) ->
        Handlebars.compile('(/{{value}}/')({value: arg.getValueOrDefault().toString()})
,

  name: 'Literal.Icon'
  desc: 'Icon'
  extra:
    inherit: 'Literal'
    icon: 'cic-uniF545'
    code:
      both: (arg, user) ->
        Handlebars.compile('\'cic {{value}}\'')({value: arg.getValueOrDefault()})

]

