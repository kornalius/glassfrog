module.exports = ((schema, options) ->

  if options and options.path?
    path = options.path + '.'
  else
    path = ''

  dates = path + 'dates'

  schema.add(

    dates: [
      name:
        type: String
        trim: true
        label: 'Date Name'

      date:
        type: Date
        label: 'Date'
    ]

  , path)

)
