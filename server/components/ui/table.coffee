module.exports = [

  name: 'Table'
  desc: 'Table display'
  extra:
    icon: 'table2'
    options: 'l'
    inherit: 'Control'
    accepts: ['Column', 'Header']
,

  name: 'Header'
  desc: 'Table header'
  icon: 'tag8'
  extra:
    options: 'l'
    inherit: 'Control'
    accepts: ['Icon']
,

  name: 'Column'
  desc: 'Table column'
  extra:
    icon: 'columns'
    inherit: 'Control'
    accepts: ['Column', 'Field']

]
