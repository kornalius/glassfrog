module.exports = [

  name: 'Queries'
  desc: 'Query'
  extra:
    display: 'Query'
    category: 'Databases'
    options: 'c'
    icon: 'cic-filter'
    color: 'lightgreen'
,

  name: 'Query'
  desc: 'Query'
  extra:
    category: 'Queries'
    inherit: 'Object'
    icon: 'cic-filter'
    defaults: [
      'Query.Select'
    ,
      'Query.Where'
    ,
      'Query.OrderBy'
    ,
      name: 'Query.Limit'
      value: 10
    ]
    accepts: ['Query.Action']
    color: 'lightgreen'
,

  name: 'Query.Action'
  desc: 'Query action'
  extra:
    category: 'Queries'
    options: 'hp!'
    icon: 'cic-filter'
    color: 'lightgreen'
,

  name: 'Query.Select'
  desc: 'Selected fields'
  extra:
    icon: 'cic-selectionadd'
    accepts: ['FieldRef+']
    inherit: 'Query.Action'
,

  name: 'Query.Where'
  desc: 'Query conditions'
  extra:
    icon: 'cic-search5'
    accepts: ['Condition+']
    inherit: 'Query.Action'
,

  name: 'Query.Sort'
  desc: 'Sort rows'
  extra:
    icon: 'cic-sort-by-attributes'
    options: '!'
    args:
      'Reverse':
        component: 'Boolean'
      'Field':
        enum: ['@Fields']
        component: 'String'
    inherit: 'Query.Action'
,

  name: 'Query.Page'
  desc: 'Page # to retrieve'
  extra:
    icon: 'cic-pagebreak'
    inherit: 'Query.Action'
,

  name: 'Query.Limit'
  desc: 'Maximum number of rows to fetch'
  extra:
    icon: 'cic-stop23'
    inherit: 'Query.Action'

]
