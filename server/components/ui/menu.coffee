module.exports = [

  name: 'Menubar'
  desc: 'Navigation menu bar'
  extra:
    inherit: 'UI'
    options: 'l'
    icon: 'dropmenu'
    accepts: ['Menu']
    default_children: ['Menu']
,
  name: 'Menu'
  desc: 'Menu item'
  extra:
    inherit: 'UI'
    icon: 'menu2'
    accepts: ['Control']

]
