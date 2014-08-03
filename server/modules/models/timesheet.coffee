app = require("../../app")
mongoose = require("../../app").mongoose
timestamps = require('mongoose-time')()
async = require('async')
endpoints = require('../../endpoints')

TimeSheetSchema = mongoose.Schema(
  client:
    type: mongoose.Schema.ObjectId
    ref: 'Contact'
    label: 'Contact'

  project:
    type: mongoose.Schema.ObjectId
    ref: 'Transaction'
    label: 'Project'

  start:
    type: Date
    label: 'Start Time'

  end:
    type: Date
    label: 'End Time'

  duration:
    type: Number
    label: 'Duration (in seconds)'
,
  label: 'Timesheet'
)

TimeSheetSchema.plugin(timestamps)

module.exports = mongoose.model('Timesheet', TimeSheetSchema)
