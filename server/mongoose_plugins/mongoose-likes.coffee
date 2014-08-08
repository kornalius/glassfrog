mongoose = require("mongoose")

module.exports = ((schema, options) ->
  schema.add(
    likes: [
      user:
        type: mongoose.Schema.ObjectId
        ref: 'User'
        readOnly: true
        label: 'User'

      ip:
        type: String
        readOnly: true
        label: 'IP'

      like:
        type: Boolean
        label: 'Like/Dislike'
    ]
  )

  schema.method(

    like: (user_id, ip) ->
      for i in [0..@likes.length - 1]
        l = @likes[i]
        if l.user._id == user_id
          if l.like
            return
          else
            @likes.splice(i, 1)
            break
      @likes.push(
        user: user_id
        ip: ip if ip?
        like: 1
      )
      @model.save()

    dislike: (user_id, ip) ->
      for i in [0..@likes.length - 1]
        l = @likes[i]
        if l.user._id == user_id
          if !l.like
            return
          else
            @likes.splice(i, 1)
            break
      @likes.push(
        user: user_id
        ip: ip if ip?
        like: -1
      )
      @model.save()

    totalLikes: () ->
      t = 0
      for l in @likes
        t++ if l.like
      return t

    totalDislikes: () ->
      t = 0
      for l in @likes
        t++ if !l.like
      return t

    likeStatus: (user_id) ->
      for l in @likes
        if l.user == user_id
          return (if l.like then 1 else -1)
      return 0

  )

)
