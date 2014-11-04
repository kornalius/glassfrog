module.exports = [

  name: 'Fonts'
  desc: 'Fonts'
  extra:
    display: 'Font'
    category: 'Decorators'
    options: 'c'
    icon: 'cic-font'
    color: 'lightpurple'
,

  name: 'Font'
  desc: 'Font'
  extra:
    category: 'Fonts'
    color: 'darkorange'
    options: 'h!'
    icon: 'cic-font'
    inherit: 'Decorator'
,

  name: 'Font.Bold'
  desc: 'Bold text appearance'
  extra:
    icon: 'cic-bold'
    inherit: 'Font'
    code:
      render: (node) ->
        if node
          e = node.element('label')
        else
          e = @element('label')
        if e and e.length
          e.addClass('bold')
,

  name: 'Font.Italic'
  desc: 'Italic text appearance'
  extra:
    icon: 'cic-italic'
    inherit: 'Font'
    code:
      render: (node) ->
        if node
          e = node.element('label')
        else
          e = @element('label')
        if e and e.length
          e.addClass('italic')
,

  name: 'Font.Underline'
  desc: 'Underline text appearance'
  extra:
    icon: 'cic-underline'
    inherit: 'Font'
    code:
      render: (node) ->
        if node
          e = node.element('label')
        else
          e = @element('label')
        if e and e.length
          e.addClass('underline')
,

  name: 'Font.Strike'
  desc: 'Strike through text appearance'
  extra:
    icon: 'cic-strikethrough'
    inherit: 'Font'
    code:
      render: (node) ->
        if node
          e = node.element('label')
        else
          e = @element('label')
        if e and e.length
          e.addClass('strikethrough')

]
