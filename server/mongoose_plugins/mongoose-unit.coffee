module.exports = ((schema, options) ->

  if options and options.path?
    path = options.path + '.'
  else
    path = ''

  unit = path + 'unit'

  schema.add(

    weight:
      unit:
        type: String
        enum: ['ml', 'oz', 'lb', 'kg', 't']
        default: 'lb'
        label: 'Weight Unit'

      value:
        type: Number
        default: 0
        label: 'Weight'

    size:
      unit:
        type: String
        enum: ['xxs', 'xs', 'sm', 'md', 'lg', 'xl', 'xxl', 'xxxl']
        default: 'md'
        label: 'Size Unit'

    dimensions:
      unit:
        type: String
        enum: ['mm', 'cm', 'in', 'ft', 'km', 'mile']
        default: 'in'
        label: 'Dimensions Unit'

      width:
        type: Number
        default: 0
        label: 'Width'

      height:
        type: Number
        default: 0
        label: 'Height'

    packing:
      unit:
        type: String
        enum: ['ea', 'case', 'basket', 'ctn', 'pkg']
        default: 'ea'
        label: 'Packing Unit'

      value:
        type: Number
        default: 0
        label: 'Unit(s) Per Pack'

    time:
      unit:
        type: String
        enum: ['minute', 'hour', 'day', 'month', 'year']
        default: 'hour'
        label: 'Time Unit'

  , path)

)
