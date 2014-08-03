module.exports = ((schema, options) ->
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

  )

)
