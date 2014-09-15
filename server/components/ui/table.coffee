module.exports = [

  name: 'Tables'
  desc: 'Table display'
  extra:
    category: 'Views'
    options: 'c'
    icon: 'cic-layout7'
    color: 'lightpurple'
,

  name: 'Table'
  desc: 'Table display'
  extra:
    category: 'Tables'
    inherit: 'Control'
    accepts: ['Table.Column+', 'Table.Row+', 'Table.Header']
    icon: 'cic-layout7'
,

  name: 'Table.Column'
  desc: 'Table column'
  extra:
    category: 'Tables'
    inherit: 'Control'
    accepts: ['Table', 'Table.Column', 'Table.Row', 'Control+', 'ObjectRef+']
    icon: 'cic-layout4'
,

  name: 'Table.Row'
  desc: 'Table row'
  extra:
    category: 'Tables'
    inherit: 'Control'
    accepts: ['Table', 'Table.Column+']
    icon: 'cic-layout5'
]
