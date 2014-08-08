module.exports = [

  name: 'UI'
  desc: 'UI element'
  extra:
    options: 'hp!'
#      accepts: ['View', 'Menubar']
    color: 'lightpurple'
,

  name: 'Page'
  desc: 'Page that contains view(s)'
  extra:
    inherit: 'UI'
    icon: 'canvasrulers'
    accepts: ['View', 'Menubar']
    defaults: ['View', 'Menubar']
    color: 'lightpurple'
,

  name: 'View'
  desc: 'View definition'
  extra:
    inherit: 'UI'
    icon: 'article2'
    accepts: ['Control']
    defaults: ['Label']
    color: 'blue'

]
