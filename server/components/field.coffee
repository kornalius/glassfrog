module.exports = [

  name: 'Field.Category'
  desc: 'Field'
  extra:
    display: 'Field'
    options: 'c'
    category: 'Database.Category'
    icon: 'cic-uniF6CA'
    color: 'pink'
,

  name: 'Field'
  desc: 'Field definition'
  extra:
    category: 'Field.Category'
    inherit: 'Object'
    accepts: ['Color', 'Font+', 'Field.Type', 'Field.Attribute+', 'Field.Validator+']
    icon: 'cic-uniF6CA'
    color: 'pink'
    args:
      'options':
        desc: 'Specify options for the field'
        multi: ['Required', 'ReadOnly', 'Private', 'Indexed', 'Populated', 'Unselected']
        default: []
    code:
      render: (node) ->
        if node
          for n in node.children()
            c = n.getComponent()
            if c
              c.render(node)

      server: (out, node, user) ->
        out.jsonBlock("'{0}':".format(node.varName()), (out) ->
          out.nodes node, 'server', user, 'Field.Type,Field.Attribute,Field.Validator'
          if node.is('options', 'indexed')
            out.line "index: true"
          if node.is('options', 'required')
            out.line "required: true"
          if node.is('options', 'private')
            out.line "'private': true"
          if node.is('options', 'readonly')
            out.line "readOnly: true"
          if node.is('options', 'unselected')
            out.line "select: false"
          if node.is('options', 'populated')
            out.line "populate: true"
        )
,

  name: 'Field.Ref'
  desc: 'Field reference'
  extra:
    options: 'h!'
    inherit: 'Object.Ref'
    icon: 'cic-uniF6CA'
,

  name: 'Field.Type.Category'
  desc: 'Field data types'
  extra:
    display: 'Type'
    category: 'Field.Category'
    options: 'c'
    color: 'lightpink'
    icon: 'cic-type2'
,

  name: 'Field.Type'
  desc: 'Field data type'
  extra:
    category: 'Field.Type.Category'
    inherit: 'Object'
    options: 'hp!'
    color: 'lightpink'
    icon: 'cic-type2'
    code:
      server: (out, node, user) ->
        out.line 'type: {0}'.format(node.displayName())
,

  name: 'Field.Text'
  desc: 'Text type'
  extra:
    icon: 'cic-uniF4E8'
    inherit: 'Field.Type'
    code:
      client_server: (out, node, user) ->
        out.line 'type: String'
,

  name: 'Field.Number'
  desc: 'Number type'
  extra:
    icon: 'cic-calculator2'
    inherit: 'Field.Type'
,

  name: 'Field.Boolean'
  desc: 'Boolean type'
  extra:
    icon: 'cic-switchon'
    inherit: 'Field.Type'
,

  name: 'Field.Currency'
  desc: 'Currency type'
  extra:
    icon: 'cic-dollar32'
    inherit: 'Field.Type'
,

  name: 'Field.Date'
  desc: 'Date type'
  extra:
    icon: 'cic-calendar32'
    inherit: 'Field.Type'
,

  name: 'Field.Percent'
  desc: 'Percent type'
  extra:
    icon: 'cic-coupon'
    inherit: 'Field.Type'
    code:
      client_server: (out, node, user) ->
        out.line 'type: mongoosePercent'
,

  name: 'Field.Email'
  desc: 'Email type'
  extra:
    icon: 'cic-email22'
    inherit: 'Field.Type'
,

  name: 'Field.Encrypted'
  desc: 'Encrypt field'
  extra:
    icon: 'cic-security2'
    inherit: 'Field.Type'
    args:
      'method':
        component: 'Literal.String'
        enum: ['pbkdf2', 'bcrypt']
        default: 'pbkdf2'
      'iterations':
        'when': (node) ->
          node.argIsEqual('method', 'pbkdf2')
        component: 'Literal.Number'
        default: 4096
      'keyLength':
        'when': (node) ->
          node.argIsEqual('method', 'pbkdf2')
        component: 'Literal.Number'
        default: 32
      'saltLength':
        'when': (node) ->
          node.argIsEqual('method', 'pbkdf2')
        component: 'Literal.Number'
        default: 64
      'saltRounds':
        'when': (node) ->
          node.argIsEqual('method', 'bcrypt')
        component: 'Literal.Number'
        default: 10
      'seedLength':
        'when': (node) ->
          node.argIsEqual('method', 'bcrypt')
        component: 'Literal.Number'
        default: 20
    code:
      client_server: (out, node, user) ->
        method = node.getArgValueOrDefault('method')
        out.list(null, ',', null, (out) ->
          out.line "type: mongoose.SchemaTypes.Encrypted"
          out.line "method: '{0}'".format(method)
          out.jsonBlock("encryptOptions:", (out) ->
            if method == 'pbkdf2'
              out.line "iterations: {0}".format(node.getArg('iterations'))
              out.line "keyLength: {0}".format(node.getArg('keyLength'))
              out.line "saltLength: {0}".format(node.getArg('saltLength'))
            else if method == 'bcrypt'
              out.line "saltRounds: {0}".format(node.getArg('saltRounds'))
              out.line "seedLength: {0}".format(node.getArg('seedLength'))
          )
        )
,

  name: 'Field.Reference'
  desc: 'Field referencing another field'
  extra:
    icon: 'cic-link42'
    inherit: 'Field.Type'
    args:
      'schema':
        component: 'Literal.String'
        enum: ['User', 'Module', 'Repository', '@Schema']
    code:
      client_server: (out, node, user) ->
        out.line "type: mongoose.SchemaTypes.ObjectId,"
        out.line "ref: '{0}'".format(node.getArgValue('schema'))
,

#  name: 'Field.Validators'
#  desc: 'Field validators'
#  extra:
#    category: 'Fields'
#    options: 'c'
#    icon: 'cic-check'
#    color: 'red'
#,
#
#  name: 'Field.Validator'
#  desc: 'Field validator'
#  extra:
#    category: 'Field.Validators'
#    inherit: 'Object'
#    options: 'hp!'
#    icon: 'cic-check'
#    color: 'red'
#,

  name: 'Field.Attribute.Category'
  desc: 'Field Attributes'
  extra:
    display: 'Attribute'
    category: 'Field.Category'
    options: 'c'
    icon: 'cic-tools'
    color: 'gray'
,

  name: 'Field.Attribute'
  desc: 'Field attribute'
  extra:
    category: 'Field.Attribute.Category'
    inherit: 'Object'
    options: 'hp!'
    icon: 'cic-tools'
,

  name: 'Field.FullTextSearch'
  desc: 'Mark this field has being able to be full text searchable.'
  extra:
    icon: 'cic-eye-open'
    inherit: 'Field.Attribute'
    code:
      client_server: (out, node, user) ->
        out.append('')
,

  name: 'Field.Trim'
  desc: 'Always trim field value before storing in document.'
  extra:
    icon: 'cic-cut2'
    inherit: 'Field.Attribute'
    code:
      client_server: (out, node, user) ->
        out.line 'trim: true'
,

  name: 'Field.Uppercase'
  desc: 'Makes sure the value is uppercase before writing to the database.'
  extra:
    icon: 'cic-uniF507'
    inherit: 'Field.Attribute'
    code:
      client_server: (out, node, user) ->
        out.line 'uppercase: true'
,

  name: 'Field.Lowercase'
  desc: 'Makes sure the value is lowercase before writing to the database.'
  extra:
    icon: 'cic-uniF506'
    inherit: 'Field.Attribute'
    code:
      client_server: (out, node, user) ->
        out.line 'lowercase: true'
,

  name: 'Field.Round'
  desc: 'Round field value before storing in document.'
  extra:
    icon: 'cic-number20'
    inherit: 'Field.Attribute'
    args:
      round:
        component: 'Literal.Number'
        desc: 'Number of decimals'
    code:
      client_server: (out, node, user) ->
        out.line 'round: {0}'.format(node.getArgValueOrDefault('round'))
,

  name: 'Field.Label'
  desc: 'Defines the label that will be displayed in the forms.'
  extra:
    icon: 'cic-font3'
    inherit: 'Field.Attribute'
    code:
      client_server: (out, node, user) ->
        out.line 'label: \'{0}\''.format(node.getName())

]
