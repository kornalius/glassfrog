module.exports = [

  name: 'Form.Category'
  desc: 'Form'
  extra:
    inherit: 'View'
    display: 'Form'
    options: 'c'
    icon: 'cic-form'
    color: 'lightpurple'

,
  name: 'Form'
  desc: 'Form'
  extra:
    category: 'Form.Category'
    inherit: 'UI'
    icon: 'cic-form'
    accepts: ['Form.Field+', 'Form.Tab+']
    defaults: []
    args:
      'schema':
        desc: 'Form schema to use'
        enum: ['@Schema']
      'type':
        desc: 'Form type'
        enum: ['display', 'form', 'modal', 'table', 'grid']
        default: ['form']
      'layout':
        desc: 'Form layout'
        enum: ['inline', 'horizontal', 'vertical']
        default: ['horizontal']
      'options':
        desc: 'options'
        multi: ['autolabel', 'blank', 'canEdit', 'canCreate', 'canDelete', 'navbars', 'navTop', 'navBottom', 'navFilter', 'navSort', 'navPerPage', 'navSearch', 'navPagination', 'navButtons']
        default: ['autolabel', 'navbars', 'canEdit', 'canCreate', 'canDelete']
#      'editMode':
#        desc: 'Form edit mode'
#        enum: ['always']
#        default: ['always']
    code:
      client: (out, node, user) ->
        form = node.getClassName()
        if node.getArgValue('schema')
          schema = node.getArgDisplayValue('schema').toLowerCase()
          out.line "$scope.{0} = new Rest('{1}')".format(schema.pluralize(), schema)
          out.block("$scope.{0}.find({}, function ()".format(schema.pluralize()), ");", (out) ->

            out.assign("{0}".format(form), ";", (out) ->
              out.jsonBlock((out) ->
                out.line "name: '{0}'".format(form)
                out.jsonBlock("layout:", (out) ->
                  out.line "type: '{0}'".format(node.getArgValueOrDefault('type'))
                  out.line "style: '{0}'".format(node.getArgValueOrDefault('layout'))
                )

                if node.getArgValue('template')
                  out.line "template: '{0}'".format(node.getArgValueOrDefault('template'))
                if node.getArgValue('controller')
                  out.line "controller: '{0}Ctrl'".format(node.getArgDisplayValue('controller'))

                for o in node.getArg('options')
                  out.line "{0}: true".format(o)

                # generate tabs here

                out.arrayBlock("fields:", (out) ->
                  out.nodes node, 'client', user, 'Form.Field'
                )
              )
            )

            out.line()
            out.line "dynForm.build($scope, {0}, $scope.{1}, '\#{2}');".format(form, schema.pluralize(), schema.pluralize())
          )

,
  name: 'Form.Field'
  desc: 'Form field'
  extra:
    category: 'Form.Category'
    inherit: 'UI'
    icon: 'cic-edit-sign'
    accepts: ['Literal.String']
    args:
      'label':
        desc: 'Field label'
      'field':
        desc: 'Field'
      'type':
        desc: 'Field type'
        enum: ['caption', 'check', 'checklistbox', 'country', 'icon', 'image', 'input', 'label', 'radio', 'radiobutton', 'select', 'state', 'textarea', 'twolist']
        default: 'input'
      'options':
        desc: 'Select input options'
        'when': (node) ->
          node.argIsEqual('type', 'select')
        multi: ['openOnFocus', 'diacritics', 'create', 'createOnBlur', 'highlight', 'persist', 'hideSelected', 'allowEmptyOption', 'preload', 'addPrecedence', 'selectOnTab']
        default: ['openOnFocus', 'diacritics', 'hideSelected', 'allowEmptyOption', 'addPrecedence']
      'createFilter':
        desc: 'Specifies a RegExp or String containing a regular expression that the current search filter must match to be allowed to be created'
        'when': (node) ->
          node.argIsEqual('type', 'select') and node.argContains('options', 'create')
      'maxOptions':
        desc: 'The max number of items to render at once in the dropdown list of options'
        'when': (node) ->
          node.argIsEqual('type', 'select')
        component: 'Literal.Number'
        default: 1000
      'description':
        desc: 'Field description'
      'placeholder':
        desc: 'Field placeholder text'
      'required':
        desc: 'Field required or not'
        component: 'Literal.Boolean'
#      'tab':
#        desc: 'Which tab to place field into'
#        component: 'Literal.Number'
#        default: 0
    code:
      client: (out, node, user) ->
        out.jsonBlock((out) ->
          out.line "label: '{0}'".format(node.getArgValueOrDefault('label'))
          out.line "fieldname: '{0}'".format(node.getArgValueOrDefault('field'))
          out.line "type: '{0}'".format(node.getArgValueOrDefault('type'))
          out.line "placeholder: '{0}'".format(node.getArgValueOrDefault('placeholder'))
          if node.getArgValueOrDefault('required') == true
            out.line "required: true"
          if node.getArgValueOrDefault('tab') > 0
            out.line "tab: {0}".format(node.getArgValueOrDefault('tab'))
          if node.argIsEqual('type', 'select')
            out.jsonBlock("config:", (out) ->
              for o in node.getArgValueOrDefault('options')
                out.line "{0}: true".format(o)
              if node.argContains('options', 'create')
                out.line "createFilter: /{0}/".format(node.getArgValueOrDefault('createFilter'))
              out.line "maxOptions: {0}".format(node.getArgValueOrDefault('maxOptions'))
            )
        )

,
  name: 'Form.Tab'
  desc: 'Form tab'
  extra:
    category: 'Form.Category'
    inherit: 'UI'
    icon: 'cic-folder-add'
    accepts: ['Form.Field+']
]
