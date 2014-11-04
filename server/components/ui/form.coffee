module.exports = [

  name: 'UIs'
  desc: 'UI elements'
  extra:
    display: 'User Interface'
    options: 'c'
    icon: 'cic-window2'
    color: 'purple'
,

  name: 'UI'
  desc: 'UI element'
  extra:
    category: 'UIs'
    options: 'hp!'
    color: 'lightpurple'
,

  name: 'Page'
  desc: 'Page that contains view(s)'
  extra:
    inherit: 'UI'
    icon: 'cic-layout12'
    accepts: ['View+', 'Menubar']
    defaults: ['View', 'Menubar']
,

  name: 'Views'
  desc: 'View definition'
  extra:
    category: 'UIs'
    display: 'View'
    options: 'c'
    icon: 'cic-webpage'
    color: 'lightpurple'
,

  name: 'View'
  desc: 'View definition'
  extra:
    category: 'Views'
    inherit: 'UI'
    icon: 'cic-article2'
    accepts: ['Control+']
    defaults: ['Label']

]
