module.exports = [

  name: 'Chart.Category'
  desc: 'Charts'
  extra:
    display: 'Chart'
    category: 'UI.Category'
    options: 'c'
    icon: 'cic-bars'
    color: 'lightpurple'
,

  name: 'Chart'
  desc: 'Chart'
  extra:
    category: 'Chart.Category'
    options: 'hp'
    inherit: 'UI'
    icon: 'cic-bars'
    color: 'lightpurple'
,

  name: 'Chart.Line'
  desc: 'Line chart'
  extra:
    inherit: 'Chart'
    icon: 'cic-chart-line'
    args:
      'type':
        enum: ['Count', 'List', 'Top']
        default: 'Count'
        component: 'String'
      'keyField':
        enum: ['@@@Field']
        component: 'String'
      'valueField':
        enum: ['@@@Field']
        component: 'String'
,

  name: 'Chart.Pie'
  desc: 'Pie chart'
  extra:
    inherit: 'Chart'
    icon: 'cic-chart-pie'
    args:
      'type':
        enum: ['Count', 'List', 'Top']
        default: 'Count'
        component: 'String'
      'keyField':
        enum: ['@@@Field']
        component: 'String'
      'valueField':
        enum: ['@@@Field']
        component: 'String'
,

  name: 'Chart.Bar'
  desc: 'Bar chart'
  extra:
    inherit: 'Chart'
    icon: 'cic-chart-bar'
    args:
      'type':
        enum: ['Count', 'List', 'Top']
        default: 'Count'
        component: 'String'
      'keyField':
        enum: ['@@@Field']
        component: 'String'
      'valueField':
        enum: ['@@@Field']
        component: 'String'

]
