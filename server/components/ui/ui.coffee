module.exports = [

  name: 'UI'
  desc: 'UI element'
  extra:
    options: 'hpl'
#      accepts: ['View', 'Menubar']
    color: 'lightpurple'
,

  name: 'Page'
  desc: 'Page that contains view(s)'
  extra:
    inherit: 'UI'
    icon: 'canvasrulers'
    accepts: ['View', 'Menubar']
    default_children: 'View, Menubar'
    color: 'lightpurple'
,

  name: 'View'
  desc: 'View definition'
  extra:
    inherit: 'UI'
    icon: 'article2'
    accepts: ['Control']
    default_children: 'Label'
    color: 'blue'

]
