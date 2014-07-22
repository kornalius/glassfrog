module.exports = [

  name: 'Table'
  desc: 'Table display'
  extra:
    icon: 'table2'
    inherit: 'Control'
    accepts: ['Table.Column', 'Table.Header']
,

  name: 'Table.Header'
  desc: 'Table header'
  icon: 'tag8'
  extra:
    inherit: 'Control'
    accepts: ['Icon', 'Label']
,

  name: 'Table.Column'
  desc: 'Table column'
  extra:
    icon: 'columns'
    inherit: 'Control'
    accepts: ['Table.Column', 'FieldRef']

]
