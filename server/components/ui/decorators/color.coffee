module.exports = [

  name: 'Red'
  desc: 'Red colored text appearance'
  extra:
    inherit: 'Decorator'
    color: 'red'
    code:
      render: (node) ->
        if node
          e = angular.element('#node-label_' + node.id())
        else
          e = angular.element('#component-icon_' + this.id())
        e.addClass('red')
,

  name: 'Blue'
  desc: 'Blue colored text appearance'
  extra:
    inherit: 'Decorator'
    color: 'blue'
    code:
      render: (node) ->
        if node
          e = angular.element('#node-label_' + node.id())
        else
          e = angular.element('#component-icon_' + this.id())
        e.addClass('blue')
,

  name: 'LightBlue'
  desc: 'Light-blue colored text appearance'
  extra:
    inherit: 'Decorator'
    color: 'lightblue'
    code:
      render: (node) ->
        if node
          e = angular.element('#node-label_' + node.id())
        else
          e = angular.element('#component-icon_' + this.id())
        e.addClass('lightblue')
,

  name: 'Orange'
  desc: 'Orange colored text appearance'
  extra:
    inherit: 'Decorator'
    color: 'orange'
    code:
      render: (node) ->
        if node
          e = angular.element('#node-label_' + node.id())
        else
          e = angular.element('#component-icon_' + this.id())
        e.addClass('orange')
,

  name: 'Purple'
  desc: 'Purple colored text appearance'
  extra:
    inherit: 'Decorator'
    color: 'purple'
    code:
      render: (node) ->
        if node
          e = angular.element('#node-label_' + node.id())
        else
          e = angular.element('#component-icon_' + this.id())
        e.addClass('purple')
,

  name: 'Pink'
  desc: 'Pink colored text appearance'
  extra:
    inherit: 'Decorator'
    color: 'pink'
    code:
      render: (node) ->
        if node
          e = angular.element('#node-label_' + node.id())
        else
          e = angular.element('#component-icon_' + this.id())
        e.addClass('pink')
,

  name: 'Yellow'
  desc: 'Yellow colored text appearance'
  extra:
    inherit: 'Decorator'
    color: 'yellow'
    code:
      render: (node) ->
        if node
          e = angular.element('#node-label_' + node.id())
        else
          e = angular.element('#component-icon_' + this.id())
        e.addClass('yellow')
,

  name: 'DarkGray'
  desc: 'Dark-gray colored text appearance'
  extra:
    inherit: 'Decorator'
    color: 'darkgray'
    code:
      render: (node) ->
        if node
          e = angular.element('#node-label_' + node.id())
        else
          e = angular.element('#component-icon_' + this.id())
        e.addClass('darkgray')
,

  name: 'Gray'
  desc: 'Gray colored text appearance'
  extra:
    inherit: 'Decorator'
    color: 'gray'
    code:
      render: (node) ->
        if node
          e = angular.element('#node-label_' + node.id())
        else
          e = angular.element('#component-icon_' + this.id())
        e.addClass('gray')
,

  name: 'LightGray'
  desc: 'Light-gray colored text appearance'
  extra:
    inherit: 'Decorator'
    color: 'lightgray'
    code:
      render: (node) ->
        if node
          e = angular.element('#node-label_' + node.id())
        else
          e = angular.element('#component-icon_' + this.id())
        e.addClass('lightgray')

]
