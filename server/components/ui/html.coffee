module.exports = [

  name: 'Html.Category'
  desc: 'HTML tags'
  extra:
    display: 'Html'
    options: 'c'
    inherit: 'View'
    icon: 'cic-html5'
,

  name: 'Template'
  desc: 'HTML template'
  extra:
    category: 'Html.Category'
    inherit: 'UI'
    icon: 'cic-html5'
    accepts: ['Html+']
    code:
      client: (out, node, user) ->
        out.line '<script type="text/ng-template" id="{0}">'.format(node.displayName().toLowerCase())
        out.nodes node, 'client', user, "*"
        out.line '</script>'
,

  name: 'Html'
  desc: 'HTML tag'
  extra:
    category: 'Html.Category'
    inherit: 'UI'
    options: 'hp!'
    icon: 'cic-chevrons'
    accepts: ['Html+']
    args:
      'id':
        component: 'Literal.String'
        desc: 'Tag id.'
      'class':
        component: 'Literal.String'
        desc: 'Tag classes delimited by a space.'
      'styles':
        component: 'Literal.String'
        desc: 'Tag custom styles.'
,

  name: 'Html.Include'
  desc: 'Include an HTML template'
  extra:
    inherit: 'Html'
    icon: 'cic-file-xml'
    args:
      'template':
        component: 'Literal.String'
        desc: 'Template to include'
        enum: ['@Template']
    code:
      client: (out, node, user) ->
        out.line '<div ng-include="\'{0}\'">'.format(node.getArgValue('template').toLowerCase())
        out.nodes node, 'client', user, "*"
        out.line '</div>'
,

  name: 'Html.Heading'
  desc: 'HTML heading text'
  extra:
    inherit: 'Html'
    icon: 'cic-paragraph-left'
    args:
      'size':
        desc: 'Heading size'
        enum: ['1', '2', '3', '4', '5', '6']
        default: '1'
    code:
      client: (out, node, user) ->
        out.append '<h{0} id="{1}" class="{2}">'.format(node.getArgValue('size'), node.getArgValue('id', ''), node.getArgValue('class', ''))
        out.nodes node, 'client', user, "*"
        out.append '</h{0}>'.format(node.getArgValue('size'))
,

  name: 'Html.Container'
  desc: 'HTML container'
  extra:
    inherit: 'Html'
    icon: 'cic-insert-template'
    args:
      'fluid':
        component: 'Literal.Boolean'
        desc: 'Full width container, spanning the entire width of the viewport.'
    code:
      client: (out, node, user) ->
        out.line '<div id="{0}" class="{1} container{2}">'.format(node.getArgValue('id', ''), node.getArgValue('class', ''), node.getArgValue('fluid', '-fluid', ''))
        out.nodes node, 'client', user, "*"
        out.line '</div>'
,

  name: 'Html.Paragraph'
  desc: 'HTML paragraph'
  extra:
    inherit: 'Html'
    icon: 'cic-paragraph-left'
    accepts: ['Html+']
    code:
      client: (out, node, user) ->
        out.append '<p id="{0}" class="{1}">'.format(node.getArgValue('id', ''), node.getArgValue('class', ''))
        out.nodes node, 'client', user, "*"
        out.append '</p>'
,

  name: 'Html.Span'
  desc: 'HTML text'
  extra:
    inherit: 'Html'
    icon: 'cic-code32'
    code:
      client: (out, node, user) ->
        out.append '<span id="{0}" class="{1}">'.format(node.getArgValue('id', ''), node.getArgValue('class', ''))
        out.nodes node, 'client', user, "*"
        out.append '</span>'
,

  name: 'Html.Icon'
  desc: 'HTML icon'
  extra:
    inherit: 'Html'
    icon: 'cic-uniF545'
    args:
      'icon':
        component: 'Literal.Icon'
        desc: 'Icon to display'
    code:
      client: (out, node, user) ->
        out.append '<span id="{0}" class="{1} cic {2}">'.format(node.getArgValue('id', ''), node.getArgValue('class', ''), node.getArgValue('icon', ''))
        out.nodes node, 'client', user, "*"
        out.append '</span>'
,

  name: 'Html.Button'
  desc: 'HTML button'
  extra:
    inherit: 'Html'
    icon: 'cic-cursor2'
    args:
      'value':
        component: 'Literal.String'
        desc: 'Text of button'
        default: 'Button'
      'click':
        component: 'Literal.String'
        desc: 'Method to execute when button is clicked'
        enum: ['@Method']
      'icon':
        component: 'Literal.Icon'
        desc: 'Icon to display on button'
      'type':
        component: 'Literal.String'
        desc: 'Type of button'
        enum: ['danger', 'success', 'info', 'warning', 'default', 'primary']
        default: 'primary'
      'size':
        component: 'Literal.String'
        desc: 'Size of button'
        enum: [
          label: 'extra small'
          value:'btn-xs'
        ,
          label: 'small'
          value: 'btn-sm'
        ,
          label: 'normal'
          value:''
        ,
          label: 'large'
          value:'btn-lg'
        ]
        default: 'normal'
    code:
      client: (out, node, user) ->
        out.append '<button id="{0}" class="{1} btn {2} btn-{3}" ng-click="{4}">'.format(node.getArgValue('id', ''), node.getArgValue('class', ''), node.getArgValue('size'), node.getArgValue('type'), node.getArgValue('click'))
        if node.getArgValue('icon')
          out.append '<span class="cic {0}">&nbsp;'.format(node.getArgValue('icon'))
        out.append node.getArgValueOrDefault('value')
        if node.getArgValue('icon')
          out.append '</span>'
        out.append '</button>'
,

  name: 'Html.Input'
  desc: 'HTML input'
  extra:
    inherit: 'Html'
    icon: 'cic-uniF5D5'
    args:
      'type':
        component: 'Literal.String'
        desc: 'Type of input'
        enum: ['text', 'password', 'datetime', 'datetime-local', 'date', 'month', 'time', 'week', 'number', 'email', 'url', 'search', 'tel', 'color']
        default: 'text'
      'value':
        component: 'Literal.String'
        desc: 'Default value of input'
      'placeholder':
        component: 'Literal.String'
        desc: 'Placeholder text of input'
      'size':
        component: 'Literal.String'
        desc: 'Size of button'
        enum: [
          label: 'small'
          value: 'input-sm'
        ,
          label: 'normal'
          value:''
        ,
          label: 'large'
          value:'input-lg'
        ]
        default: 'normal'
      'icon':
        component: 'Literal.Icon'
        desc: 'Icon addon for input'
      'change':
        component: 'Literal.String'
        desc: 'Method to execute when value of input is changed'
        enum: ['@Method']
    code:
      client: (out, node, user) ->
        if node.getArgValue('icon')
          out.line '<div class="input-group">'
        out.line '<input type="{0}" id="{1}" class="{2} form-control {3}" placeholder="{4}" value="{5}"/>'.format(node.getArgValue('type', ''), node.getArgValue('id', ''), node.getArgValue('class', ''), node.getArgValue('size'), node.getArgValue('placeholder'), node.getArgValue('value'), node.getArgValue('change', ''))
        if node.getArgValue('icon')
          out.line '<span class="input-group-addon">'
          out.line '<span class="cic {0}"></span>'.format(node.getArgValue('icon'))
          out.line '</span>'
          out.line '</div>'
,

  name: 'Html.Mark'
  desc: 'HTML marked text'
  extra:
    inherit: 'Html'
    icon: 'cic-flashlight'
    code:
      client: (out, node, user) ->
        out.append '<mark>'
        out.nodes node, 'client', user, "*"
        out.append '</mark>'
,

  name: 'Html.Bold'
  desc: 'Bold text appearance'
  extra:
    inherit: 'Html'
    icon: 'cic-bold'
    code:
      client: (out, node, user) ->
        out.append '<strong>'
        out.nodes node, 'client', user, "*"
        out.append '</strong>'
,

  name: 'Html.Italic'
  desc: 'Italic text appearance'
  extra:
    icon: 'cic-italic'
    inherit: 'Html'
    code:
      client: (out, node, user) ->
        out.append '<em>'
        out.nodes node, 'client', user, "*"
        out.append '</em>'
,

  name: 'Html.Underline'
  desc: 'Underline text appearance'
  extra:
    icon: 'cic-underline'
    inherit: 'Html'
    code:
      client: (out, node, user) ->
        out.append '<u>'
        out.nodes node, 'client', user, "*"
        out.append '</u>'
,

  name: 'Html.Strike'
  desc: 'Strike through text appearance'
  extra:
    icon: 'cic-strikethrough'
    inherit: 'Html'
    code:
      client: (out, node, user) ->
        out.append '<s>'
        out.nodes node, 'client', user, "*"
        out.append '</s>'
,

  name: 'Html.Panel.Category'
  desc: 'HTML panel'
  extra:
    display: 'Panel'
    options: 'c'
    inherit: 'Html'
    icon: 'cic-window22'
,

  name: 'Html.Panel'
  desc: 'HTML panel'
  extra:
    category: 'Html.Panel.Category'
    inherit: 'Html'
    icon: 'cic-window22'
    accepts: ['Html.Panel.Header', 'Html.Panel.Body', 'Html.Panel.Footer']
    defaults: ['Html.Panel.Header', 'Html.Panel.Body', 'Html.Panel.Footer']
    args:
      'style':
        component: 'Literal.String'
        desc: 'Window like panel'
        enum: ['danger', 'success', 'info', 'warning', 'default', 'primary']
        default: 'default'
    code:
      client: (out, node, user) ->
        out.line '<div id="{0}" class="{1} panel panel-{2}">'.format(node.getArgValue('id', ''), node.getArgValue('class', ''), node.getArgValue('style', ''))
        out.nodes node, 'client', user, "*"
        out.line '</div>'
,

  name: 'Html.Panel.Header'
  desc: 'HTML panel header section'
  extra:
    display: 'Header'
    category: 'Html.Panel.Category'
    inherit: 'Html'
    icon: 'cic-upload'
    code:
      client: (out, node, user) ->
        out.line '<div id="{0}" class="{1} panel-heading">'.format(node.getArgValue('id', ''), node.getArgValue('class', ''))
        out.nodes node, 'client', user, "*"
        out.line '</div>'
,

  name: 'Html.Panel.Body'
  desc: 'HTML panel body section'
  extra:
    display: 'Body'
    category: 'Html.Panel.Category'
    inherit: 'Html'
    icon: 'cic-lines'
    code:
      client: (out, node, user) ->
        out.line '<div id="{0}" class="{1} panel-body">'.format(node.getArgValue('id', ''), node.getArgValue('class', ''))
        out.nodes node, 'client', user, "*"
        out.line '</div>'
,

  name: 'Html.Panel.Footer'
  desc: 'HTML panel footer section'
  extra:
    display: 'Footer'
    category: 'Html.Panel.Category'
    inherit: 'Html'
    icon: 'cic-download'
    code:
      client: (out, node, user) ->
        out.line '<div id="{0}" class="{1} panel-footer">'.format(node.getArgValue('id', ''), node.getArgValue('class', ''))
        out.nodes node, 'client', user, "*"
        out.line '</div>'

]
