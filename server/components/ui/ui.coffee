module.exports = [

  name: 'UI.Category'
  desc: 'UI elements'
  extra:
    display: 'User Interface'
    options: 'c'
    icon: 'cic-window2'
    color: 'lightpurple'
,

  name: 'UI'
  desc: 'UI element'
  extra:
    category: 'UI.Category'
    options: 'hp'
    color: 'lightpurple'
,

  name: 'Page.Category'
  desc: 'Page definition'
  extra:
    category: 'UI.Category'
    display: 'Page'
    options: 'c'
    icon: 'cic-layout12'
    color: 'lightpurple'
,

  name: 'Page'
  desc: 'Page that contains view(s)'
  extra:
    inherit: 'UI'
    category: 'Page.Category'
    icon: 'cic-layout12'
    accepts: ['View+', 'Method+', 'Menubar']
#    defaults: ['View', 'Menubar']
    code:
      client: (out, node, user) ->
        mod = node.module().getClassName()
        ctrl = mod + node.getClassName() + 'Ctrl'

        out.block(".controller('{0}', ['$scope', 'Globals', 'Rest', 'dynForm', function($scope, globals, Rest, dynForm)".format(ctrl), "])", (out) ->
          out.nodes node, 'client', user, "View", [true]

          out.nodes node, 'client', user, "Method"
        )

        out.nodes node, 'client', user, "View"
,

  name: 'View.Category'
  desc: 'View definition'
  extra:
    category: 'UI.Category'
    display: 'View'
    options: 'c'
    icon: 'cic-webpage'
    color: 'lightpurple'
,

  name: 'View'
  desc: 'View definition'
  extra:
    category: 'View.Category'
    inherit: 'UI'
    icon: 'cic-article2'
    accepts: ['Form+', 'Template+']
    code:
      client: (out, node, user, onlyForms) ->
        if onlyForms
          out.nodes node, 'client', user, "Form"
        else
          mod = node.module().getClassName()
          pg = node.getParent().getClassName()
          ctrl = mod + pg + node.getClassName() + 'Ctrl'
          out.block(".controller('{0}', ['$scope', 'Globals', 'Rest', 'dynForm', function($scope, globals, Rest, dynForm)".format(ctrl), "])", (out) ->
#            out.line "shj293$@/"

            out.nodes node, 'client', user, "Method"
          )

]
