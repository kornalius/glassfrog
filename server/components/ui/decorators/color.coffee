module.exports = [

  name: 'Color'
  desc: 'Color'
  extra:
    inherit: ['Literal']
    icon: 'palette'
    code:
      render: (node) ->
        color = @getColor()
        if !color
          color = @name
        if color
          color = color.toLowerCase()
          if node
            e = angular.element('#node-label-id_' + node.id())
          else
            e = angular.element('#component-icon-id_' + @id())
          e.addClass(tinycolor(color).toName())
,

  name: 'Color.RGB'
  desc: 'Color'
  extra:
    inherit: 'MethodRef'
    icon: 'color'
,

  name: 'Red'
  desc: 'Red colored text appearance'
  extra:
    inherit: 'Color'
#    color: 'red'
,

  name: 'Blue'
  desc: 'Blue colored text appearance'
  extra:
    inherit: 'Color'
#    color: 'blue'
,

  name: 'LightBlue'
  desc: 'Light-blue colored text appearance'
  extra:
    inherit: 'Color'
#    color: 'lightblue'
,

  name: 'Orange'
  desc: 'Orange colored text appearance'
  extra:
    inherit: 'Color'
#    color: 'orange'
,

  name: 'Purple'
  desc: 'Purple colored text appearance'
  extra:
    inherit: 'Color'
#    color: 'purple'
,

  name: 'Pink'
  desc: 'Pink colored text appearance'
  extra:
    inherit: 'Color'
#    color: 'pink'
,

  name: 'Yellow'
  desc: 'Yellow colored text appearance'
  extra:
    inherit: 'Color'
#    color: 'yellow'
,

  name: 'DarkGrey'
  desc: 'Dark-grey colored text appearance'
  extra:
    inherit: 'Color'
#    color: 'darkgray'
,

  name: 'Grey'
  desc: 'Grey colored text appearance'
  extra:
    inherit: 'Color'
#    color: 'gray'
,

  name: 'LightGrey'
  desc: 'Light-grey colored text appearance'
  extra:
    inherit: 'Color'
#    color: 'lightgray'

]
