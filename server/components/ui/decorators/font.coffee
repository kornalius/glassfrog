module.exports = [

  name: 'Bold'
  desc: 'Bold text appearance'
  extra:
    icon: 'bold'
    inherit: 'Decorator'
    code:
      render: (node) ->
        if node
          e = angular.element('#node-label-id_' + node.id())
        else
          e = angular.element('#component-label-id_' + this.id())
        e.addClass('bold')
,

  name: 'Italic'
  desc: 'Italic text appearance'
  extra:
    icon: 'italic'
    inherit: 'Decorator'
    code:
      render: (node) ->
        if node
          e = angular.element('#node-label-id_' + node.id())
        else
          e = angular.element('#component-label-id_' + this.id())
        e.addClass('italic')
,

  name: 'Underline'
  desc: 'Underline text appearance'
  extra:
    icon: 'underline'
    inherit: 'Decorator'
    code:
      render: (node) ->
        if node
          e = angular.element('#node-label-id_' + node.id())
        else
          e = angular.element('#component-label-id_' + this.id())
        e.addClass('underline')
,

  name: 'Strike'
  desc: 'Strike through text appearance'
  extra:
    icon: 'strikethrough'
    inherit: 'Decorator'
    code:
      render: (node) ->
        if node
          e = angular.element('#node-label-id_' + node.id())
        else
          e = angular.element('#component-label-id_' + this.id())
        e.addClass('strikethrough')

]
