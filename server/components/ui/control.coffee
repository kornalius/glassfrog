module.exports = [

  name: 'Control'
  desc: 'Control to place on view'
  extra:
    inherit: 'UI'
    options: 'hp'
    icon: 'pointer'
    accepts: ['Decorator']
    color: 'lightorange'
,

  name: 'Label'
  desc: 'Label'
  extra:
    icon: 'uniF4E8'
    inherit: 'Control'
,

  name: 'Icon'
  desc: 'Icon'
  extra:
    icon: 'picture22'
    inherit: 'Control'
,

  name: 'Input'
  desc: 'Input control'
  extra:
    inherit: 'Control'
    options: 'hp'
    icon: 'uniF5D5'
,

  name: 'Button'
  desc: 'Action button'
  extra:
    icon: 'progress-0'
    inherit: 'Control'
    accepts: ['Icon', 'Label']

]
