module.exports = ((schema, options) ->
  schema.add(
    password:
      type: String
      trim: true
      required: true
      label: 'Password'
      private: true
      readOnly: true
  )

  if options && options.index
    schema.path('password').index(options.index)
)
