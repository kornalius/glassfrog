module.exports = [

  name: 'Menubar'
  desc: 'Navigation menu bar'
  extra:
    inherit: 'UI'
    options: '!'
    icon: 'dropmenu'
    accepts: ['Menu.Item']
    defaults: ['Menu.Item']
,
  name: 'Menu.Item'
  desc: 'Menu item'
  extra:
    inherit: 'UI'
    icon: 'menu2'
    accepts: ['Control']

]
