module.exports = [

  name: 'Menu.Category'
  desc: 'Menu controls'
  extra:
    display: 'Menu'
    inherit: 'Page'
    options: 'c'
    icon: 'cic-dropmenu'
    color: 'lightpurple'
,

  name: 'Menubar'
  desc: 'Navigation menu bar'
  extra:
    display: 'Menu Bar'
    category: 'Menu.Category'
    inherit: 'UI'
    options: '!'
    icon: 'cic-dropmenu'
    accepts: ['Menu.Item+']
    defaults: ['Menu.Item']
,

  name: 'Menu.Item'
  desc: 'Menu item'
  extra:
    display: 'Menu Item'
    category: 'Menu.Category'
    inherit: 'UI'
    icon: 'cic-menu2'
    accepts: ['Icon+', 'Label+']

]
