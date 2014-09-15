mongoose = require("mongoose")
percent = require('percent')

class Percent extends mongoose.SchemaTypes.Number

  constructor: (path, options) ->
    super path, options
    @validate(@validatePercent.bind(@, options and options.required), 'percent is invalid')

  cast: (val) =>
    if type(val) is 'string'
      if percent.valid(val)
        return percent.convert(val)
      else
        return 0
    else if type(val) is 'number'
      return val
    else
      return new Error('Should pass in a number or string')

  calc: (total, decimal, sign) ->
    percent.calc(@, total, decimal, sign)

  toString: () ->
    return "{0}%".format(@)


module.exports = () ->
  mongoose.SchemaTypes.Percent = Percent
  mongoose.Types.Percent = Number
  return Percent
