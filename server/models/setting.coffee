mongoose = require("mongoose")
timestamps = require('mongoose-time')()
filterPlugin = require('../mongoose_plugins/mongoose-filter')

SettingSchema = mongoose.Schema(
  key:
    type: String
    trim: true
    lowercase: true
    unique: true
    required: true
    index: true
    label: 'Key'

  value:
    type: mongoose.Schema.Types.Mixed
    label: 'Value'
,
  _id: false
  id: false
  label: 'Settings'
)

SettingSchema.plugin(timestamps)
SettingSchema.plugin(filterPlugin)

SettingSchema.static(
  getValue: (key, cb) ->
    mongoose.model('Setting').findOne({key: key}, (err, result) ->
      cb(if result then result.value else null) if cb
    )

  setValue: (key, value) ->
    mongoose.model('Setting').findOneAndUpdate({key: key}, {value: value}, {upsert: true}, (err, result) ->
    )
)

SettingSchema.method(
)

module.exports = mongoose.model('Setting', SettingSchema)
