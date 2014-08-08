mongoose = require("mongoose")

module.exports = ((schema, options) ->
  schema.add(
    comments: [
      user:
        type: mongoose.Schema.ObjectId
        ref: 'User'
        readOnly: true
        label: 'User'

      ip:
        type: String
        readOnly: true
        label: 'IP'

      message:
        type: String
        label: 'Message'
    ]
  )

  schema.method(

    addComment: (user_id, message, ip) ->
      @comments.push(
        user: user_id
        message: message if message?
        ip: ip if ip?
      )
      @model.save()

  )

)
