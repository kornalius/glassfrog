module.exports = [

  name: 'Menus'
  desc: 'Menu controls'
  extra:
    display: 'Menu'
    category: 'UIs'
    options: 'c'
    icon: 'cic-dropmenu'
    color: 'lightpurple'
,

  name: 'Menubar'
  desc: 'Navigation menu bar'
  extra:
    display: 'Menu Bar'
    category: 'Menus'
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
    category: 'Menus'
    inherit: 'UI'
    icon: 'cic-menu2'
    accepts: ['Icon+', 'Label+']

]
