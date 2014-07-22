module.exports = [

  name: 'Query'
  desc: 'Query'
  extra:
    inherit: 'Object'
    icon: 'filter'
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
    color: 'lightgray'
,

  name: 'Query.Action'
  desc: 'Query action'
  extra:
    options: 'hp'
    icon: 'filter'
    color: 'darkgray'
,

  name: 'Query.Select'
  desc: 'Selected fields'
  extra:
    icon: 'selectionadd'
    accepts: ['FieldRef']
    inherit: 'QueryAction'
,

  name: 'Query.Where'
  desc: 'Query conditions'
  extra:
    icon: 'search5'
    accepts: []
    inherit: 'Query.Action'
,

  name: 'Query.OrderBy.Sort'
  desc: 'Ascending or descending sort order'
  extra:
    icon: 'sort-by-attributes'
    enum: ['Ascending', 'Descending']
    defaultValue: 'Ascending'
,

  name: 'Query.OrderBy'
  desc: 'Order fields'
  extra:
    icon: 'sort-by-attributes'
    accepts: ['FieldRef', 'Query.Sort']
    inherit: 'Query.Action'
,

  name: 'Query.Page'
  desc: 'Page to retrieve'
  extra:
    icon: 'pagebreak'
    inherit: 'Query.Action'
,

  name: 'Query.Limit'
  desc: 'Maximum number of rows to fetch'
  extra:
    icon: 'stop23'
    inherit: 'Query.Action'

]
