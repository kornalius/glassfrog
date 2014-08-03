module.exports = ((schema, options) ->
  schema.add(
    history: [
      date:
        type: Date
        required: true
        label: 'Date'

      action:
        type: String
        trim: true
        label: 'Middle Name'
        inline: true

      comment:
        type: String
        readOnly: true
        label: 'Comment'

      user:
        type: mongoose.Schema.ObjectId
        ref: 'User'
        readOnly: true
        populate: true
    ]
  )

  if options && options.index
    schema.path('history').index(options.index)

  schema.static(

    log: (user, action, comment) ->
      @history.push(
        user: user.id
        date: new Date()
        action: action
        comment: comment if comment?
      )
      @model.save()

  )
)
