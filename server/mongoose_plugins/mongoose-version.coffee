mongoose = require("mongoose")
VersionClass = require('../version')

class Version extends mongoose.SchemaTypes.String

  constructor: (path, options) ->
    super path, options
    @validate(@validateVersion.bind(@, options and options.required), 'version is invalid')

  cast: (val) =>
    if val instanceof VersionClass
      return val.versionString()
    else if type(val) is 'object' and val.major? and val.minor?
      return new VersionClass(val).versionString()
    else if val?
      return val
    else
      return ''

  validateVersion: (required, v) ->
    if required or v
      return VersionClass.validate(v)
    else
      return true

module.exports = () ->
  mongoose.SchemaTypes.Version = Version
  mongoose.Types.Version = String
  return Version
