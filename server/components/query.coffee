module.exports = [

  name: 'Query'
  desc: 'Query'
  extra:
    inherit: 'Object'
    icon: 'filter'
    default_children: ['Select','Where','OrderBy','Limit']
    accepts: ['QueryAction']
    color: 'lightgray'
    code: 'query.js'
,

  name: 'QueryAction'
  desc: 'Query action'
  extra:
    options: 'hp'
    icon: 'filter'
    color: 'darkgray'
,

  name: 'Select'
  desc: 'Selected fields'
  extra:
    icon: 'selectionadd'
    accepts: ['Field']
    inherit: 'QueryAction'
    code: 'queryselect.js'
,

  name: 'Where'
  desc: 'Query conditions'
  extra:
    icon: 'search5'
    accepts: ['If', 'And', 'Or']
    inherit: 'QueryAction'
    code: 'querywhere.js'
,

  name: 'OrderBy'
  desc: 'Order fields'
  extra:
    icon: 'sort-by-attributes'
    accepts: ['Field']
    inherit: 'QueryAction'
    code: 'queryorderby.js'
,

  name: 'Query Page'
  desc: 'Page to retrieve'
  extra:
    icon: 'pagebreak'
    inherit: 'QueryAction'
    code: 'querypage.js'
,

  name: 'Limit'
  desc: 'Maximum number of rows to fetch'
  extra:
    icon: 'stop23'
    inherit: 'QueryAction'
    code: 'querylimit.js'

]
