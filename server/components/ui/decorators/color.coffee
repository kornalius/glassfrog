module.exports = [

  name: 'Colors'
  desc: 'Colors'
  extra:
    category: 'Decorators'
    display: 'Color'
    options: 'c'
    icon: 'cic-palette'
    color: 'lightpurple'
,

  name: 'Color'
  desc: 'Color'
  extra:
    category: 'Colors'
    options: '!'
    inherit: 'Decorator'
    icon: 'cic-palette'
    code:
      getColor: () ->
        tc = tinycolor(@getName().toLowerCase())
        if !tc.isValid()
          tc = tinycolor(@getColor().toLowerCase())
        if tc.isValid()
          c = tc.toHex8String()
        else
          c = '#000000'
        return c

      render: (node) ->
        color = tinycolor(@code("getColor").call(@)).toName()
        if node
          c = null
          l = node.element('label')
          i = null
        else
          c = @element('color')
          l = null
          i = @element('icon')
        if c and c.length
          c.css('background-color', color)
        if i and i.length
          i.addClass(color)
        if l and l.length
          l.addClass(color)

      client: (out, node, user) ->
        out.append @code("getColor").call(@)

      server: (out, node, user) ->
        color = @code("getColor").call(@).toName()
        p = node.getParent()
        if p? and !client and p.kindOf('Field')
          out.append 'color: "{0}"'.format(color)
,

  name: 'Color.RGB'
  desc: 'Color'
  extra:
    category: 'Colors'
    inherit: 'Method.Ref'
    icon: 'cic-color'
,

  name: 'Red'
  desc: 'Red colored text appearance'
  extra:
    inherit: 'Color'
,

  name: 'Blue'
  desc: 'Blue colored text appearance'
  extra:
    inherit: 'Color'
,

  name: 'LightBlue'
  desc: 'Light-blue colored text appearance'
  extra:
    inherit: 'Color'
,

  name: 'Orange'
  desc: 'Orange colored text appearance'
  extra:
    inherit: 'Color'
,

  name: 'Purple'
  desc: 'Purple colored text appearance'
  extra:
    inherit: 'Color'
,

  name: 'Pink'
  desc: 'Pink colored text appearance'
  extra:
    inherit: 'Color'
,

  name: 'Yellow'
  desc: 'Yellow colored text appearance'
  extra:
    inherit: 'Color'
,

  name: 'DarkGrey'
  desc: 'Dark-grey colored text appearance'
  extra:
    inherit: 'Color'
,

  name: 'Grey'
  desc: 'Grey colored text appearance'
  extra:
    inherit: 'Color'
,

  name: 'LightGrey'
  desc: 'Light-grey colored text appearance'
  extra:
    inherit: 'Color'

]
