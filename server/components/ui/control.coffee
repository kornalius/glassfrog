module.exports = [

  name: 'Controls'
  desc: 'Control to place on view'
  extra:
    display: 'Control'
    category: 'UIs'
    options: 'c'
    icon: 'cic-pointer'
    color: 'lightpurple'
,

  name: 'Control'
  desc: 'Control to place on view'
  extra:
    category: 'Controls'
    inherit: 'UI'
    options: 'hp'
    icon: 'cic-pointer'
    accepts: ['Decorator+']
,

  name: 'Label'
  desc: 'Label'
  extra:
    icon: 'cic-uniF4E8'
    inherit: 'Control'
,

  name: 'Icon'
  desc: 'Icon'
  extra:
    icon: 'cic-picture22'
    inherit: 'Control'
,

  name: 'Input'
  desc: 'Input control'
  extra:
    inherit: 'Control'
    options: 'hp'
    icon: 'cic-uniF5D5'
,

  name: 'Button'
  desc: 'Action button'
  extra:
    icon: 'cic-progress-0'
    inherit: 'Control'
    accepts: ['Icon+', 'Label+']

]
