mongoose = require("mongoose")
timestamps = require('mongoose-time')()
ownable = require('mongoose-ownable')
async = require('async')

TestSchema = mongoose.Schema(
  value:
    type: String
    label: 'Value'

  hidden:
    type: String
    private: true
    label: 'Hidden field'

  dict:
    testString:
      type: String

    testBoolean:
      type: Boolean

  sub: [
    testString:
      type: String

    testBoolean:
      type: Boolean

    testDict:
      testString:
        type: String

      testBoolean:
        type: Boolean
  ]
,
  label: 'Tests'
)

TestSchema.plugin(timestamps)
TestSchema.plugin(ownable)

#TestSchema.set('toObject', {virtuals: true})
#TestSchema.set('toJSON', {virtuals: true})

TestSchema.method(
)

module.exports = mongoose.model('Test', TestSchema)

setTimeout( ->
  Test = mongoose.model('Test')
  Test.find({}, (err, tests) ->
    if tests and tests.length == 0
      async.eachSeries([0..100], (i, callback) ->
        Test.create(
          value: i
          hidden: i.toString()
          dict:
            testString: 'a'
            testBoolean: true
          sub: [
            testString: 'a'
            testBoolean: true
            testDict:
              testString: 'a.a'
              testBoolean: true
          ,
            testString: 'b'
            testBoolean: false
            testDict:
              testString: 'b.b'
              testBoolean: false
          ,
            testString: 'c'
            testBoolean: true
            testDict:
              testString: 'c.c'
              testBoolean: true
          ]
        , (err) ->
          callback()
        )
      , (err) ->
      )
  )
, 100)
