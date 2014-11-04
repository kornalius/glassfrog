module.exports = [

  name: 'Table.Category'
  desc: 'Table display'
  extra:
    display: 'Table'
    category: 'View.Category'
    options: 'c'
    icon: 'cic-layout7'
    color: 'lightpurple'
,

  name: 'Table'
  desc: 'Table display'
  extra:
    category: 'Table.Category'
    inherit: 'Control'
    accepts: ['Table.Column+', 'Table.Row+', 'Table.Header']
    icon: 'cic-layout7'
,

  name: 'Table.Column'
  desc: 'Table column'
  extra:
    category: 'Table.Category'
    inherit: 'Control'
    accepts: ['Table', 'Table.Column', 'Table.Row', 'Control+', 'Object.Ref+']
    icon: 'cic-layout4'
,

  name: 'Table.Row'
  desc: 'Table row'
  extra:
    category: 'Table.Category'
    inherit: 'Control'
    accepts: ['Table', 'Table.Column+']
    icon: 'cic-layout5'
]
