module.exports = [

  name: 'Fields'
  desc: 'Fields'
  extra:
    display: 'Field'
    options: 'c'
    category: 'Databases'
    icon: 'cic-uniF6CA'
    color: 'pink'
,

  name: 'Field'
  desc: 'Field definition'
  extra:
    category: 'Fields'
    inherit: 'Object'
    accepts: ['Color', 'Font+', 'Field.Type', 'Field.Attribute+', 'Field.Validator+']
    icon: 'cic-uniF6CA'
    color: 'pink'
    args:
      'options':
        desc: 'Specify options for the field'
        multi: ['Required', 'ReadOnly', 'Private', 'Encrypted', 'Indexed', 'Populated', 'Unselected', 'Trimmed', 'FullTextSearch', 'Password']
        default: []
    code:
      render: (node) ->
        if node
          for n in node.children()
            c = n.getComponent()
            if c and c.hasRenderCode()
              c.render(node)

      server: (node, user) ->
        Handlebars.compile('{{> field_server}}')(
          component: @
          node: node
          name: node.varName()
          index: (if node.is('options', 'indexed') then 'true' else 'false')
          required: (if node.is('options', 'required') then 'true' else 'false')
          private: (if node.is('options', 'private') then 'true' else 'false')
          readonly: (if node.is('options', 'readonly') then 'true' else 'false')
          select: (if node.is('options', 'unselected') then 'false' else 'true')
          populate: (if node.is('options', 'populated') then 'true' else 'false')
          trim: (if node.is('options', 'trimmed') then 'true' else 'false')
          password: (if node.is('options', 'password') then 'true' else 'false')
          encrypt: (if node.is('options', 'encrypted') then 'true' else 'false')
        )
,

  name: 'FieldRef'
  desc: 'Field reference'
  extra:
    options: 'h!'
    inherit: 'ObjectRef'
    icon: 'cic-uniF6CA'
,

  name: 'Field.Types'
  desc: 'Field data types'
  extra:
    category: 'Fields'
    options: 'c'
    color: 'lightpink'
    icon: 'cic-type2'
,

  name: 'Field.Type'
  desc: 'Field data type'
  extra:
    category: 'Field.Types'
    inherit: 'Object'
    options: 'hp!'
    color: 'lightpink'
    icon: 'cic-type2'
    code:
      server: (node, user) ->
        Handlebars.compile('type: {{type}}')({type: node.displayName()})
,

  name: 'Field.Text'
  desc: 'Text type'
  extra:
    icon: 'cic-uniF4E8'
    inherit: 'Field.Type'
    code:
      both: (node, user) ->
        return 'type: String'
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
      both: (node, user) ->
        return 'type: mongoosePercent'
,

  name: 'Field.Email'
  desc: 'Email type'
  extra:
    icon: 'cic-email22'
    inherit: 'Field.Type'
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
#
#  name: 'Field.Required'
#  desc: 'Required'
#  extra:
#    icon: 'cic-spam2'
#    inherit: 'Field.Validator'
#    code:
#      both: (node, user) ->
#        Handlebars.compile('required: true')({})
#,
#
#  name: 'Field.ReadOnly'
#  desc: 'Read-only'
#  extra:
#    icon: 'cic-lock32'
#    inherit: 'Field.Validator'
#    code:
#      both: (node, user) ->
#        Handlebars.compile('readOnly: true')({})
#,

  name: 'Field.Attributes'
  desc: 'Field Attributes'
  extra:
    category: 'Fields'
    options: 'c'
    icon: 'cic-tools'
,

  name: 'Field.Attribute'
  desc: 'Field attribute'
  extra:
    category: 'Field.Attributes'
    inherit: 'Object'
    options: 'hp!'
    icon: 'cic-tools'
,

#  name: 'Field.Encrypted'
#  desc: 'Encrypt field'
#  extra:
#    icon: 'cic-security2'
#    inherit: 'Field.Attribute'
#    code:
#      both: (node, user) ->
#        return 'encrypted: true'
#,
#
#  name: 'Field.Index'
#  desc: 'Indexed field'
#  extra:
#    icon: 'cic-uniF6CD'
#    inherit: 'Field.Attribute'
#    code:
#      both: (node, user) ->
#        return 'index: true'
#,
#
#  name: 'Field.Populate'
#  desc: 'Populate field'
#  extra:
#    icon: 'cic-document-fill'
#    inherit: 'Field.Attribute'
#    code:
#      both: (node, user) ->
#        return 'populate: true'
#,
#
#  name: 'Field.Trim'
#  desc: 'Always trim field value before storing in document.'
#  extra:
#    icon: 'cic-cut2'
#    inherit: 'Field.Attribute'
#    code:
#      both: (node, user) ->
#        return 'trim: true'
#,
#
#  name: 'Field.Private'
#  desc: 'Private field. Will not be transmitted to the client side.'
#  extra:
#    icon: 'cic-eye-close'
#    inherit: 'Field.Attribute'
#    code:
#      both: (node, user) ->
#        Handlebars.compile('private: true')({})
#,
#
#  name: 'Field.FullTextSearch'
#  desc: 'Mark this field has being able to be full text searchable.'
#  extra:
#    icon: 'cic-eye-zoom-in'
#    inherit: 'Field.Attribute'
#    code:
#      generate: (node, user) ->
#        return null
#,

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
      both: (node, user) ->
        Handlebars.compile('round: {{value}}')({value: node.getArgValueOrDefault('round')})
,

  name: 'Field.Label'
  desc: 'Defines the label that will be displayed in the forms.'
  extra:
    icon: 'cic-font3'
    inherit: 'Field.Attribute'
    code:
      both: (node, user) ->
        Handlebars.compile('label: \'{{caption}}\'')({caption: node.getName()})

]
