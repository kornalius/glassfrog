module.exports = ((schema, options) ->

  if options and options.path?
    path = options.path + '.'
  else
    path = ''

  history = path + 'history'

  schema.add(
    history: [
      date:
        type: Date
        required: true
        readOnly: true
        label: 'Date'

      action:
        type: String
        trim: true
        label: 'Middle Name'
        readOnly: true
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
  , path)

  if options && options.index
    schema.path(history).index(options.index)

  schema.static(

    log: (user_id, action, comment) ->
      @get(history).push(
        user: user_id
        date: new Date()
        action: action
        comment: comment if comment?
      )
      @model.save()

  )
)
