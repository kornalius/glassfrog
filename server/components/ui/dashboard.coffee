module.exports = [

  name: 'Dashboard'
  desc: 'Dashboard'
  extra:
    category: 'Views'
    inherit: 'Control'
    defaults: [
      name: 'Chart.Line'
      args:
        'Type': 'List'
    ]
    accepts: ['Chart+']
    icon: 'cic-stats3'
    color: 'lightgray'

]
