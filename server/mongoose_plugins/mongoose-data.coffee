mongoose = require("mongoose")

module.exports = ((schema, options) ->

  if options and options.path?
    path = options.path + '.'
  else
    path = ''

  data = path + 'data'

  schema.add(
    data:
      type: String
      label: 'JSON custom data'
  , path)

  schema.method(

    dataExists: (key) ->
      return @get(data)[key]?

    getData: (key) ->
      return @get(data)[key]

    setData: (key, value) ->
      @get(data)[key] = value
      @save()

    deleteData: (key) ->
      delete @get(data)[key]
      @save()
  )

)
