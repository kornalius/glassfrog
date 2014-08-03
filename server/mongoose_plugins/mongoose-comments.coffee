module.exports = ((schema, options) ->
  schema.add(
    comments: [
      user:
        type: mongoose.Schema.ObjectId
        ref: 'User'
        readOnly: true
        populate: true

      ip:
        type: String
        readOnly: true
        label: 'IP'

      message:
        type: String
        readOnly: false
        label: 'Message'
    ]
  )

  schema.static(
    addComment: (user, schema, message, ip) ->
      @create(
        user: user.id
        schemaName: schema if schema?
        message: message if message?
        ip: ip if ip?
      , (err, c) ->
        if c
          @comments.push(c)
      )
  )

)
