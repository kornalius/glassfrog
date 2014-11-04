module.exports = ((schema, options) ->

  if options and options.path?
    path = options.path + '.'
  else
    path = ''

  password = path + 'password'

  schema.add(
    password:
      type: String
      trim: true
      required: true
      label: 'Password'
      private: true
      readOnly: true
  , path)

  if options && options.index
    schema.path(password).index(options.index)
)
