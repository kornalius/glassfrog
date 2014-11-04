module.exports = ((schema, options) ->
  if options and options.path?
    path = options.path + '.'
  else
    path = ''

  picture = path + 'picture'

  schema.add(
    picture:
      type: Buffer
      label: 'Picture'
  , path)
)
