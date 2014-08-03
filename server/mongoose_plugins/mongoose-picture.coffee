module.exports = ((schema, options) ->
  schema.add(
    picture:
      type: Buffer
      label: 'Picture'
  )
)
