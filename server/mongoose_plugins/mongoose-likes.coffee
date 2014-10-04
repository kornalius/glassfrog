mongoose = require("mongoose")

module.exports = ((schema, options) ->
  schema.add(
    likes: [
      user:
        type: mongoose.Schema.ObjectId
        ref: 'User'
        readOnly: true
        label: 'User'

      liked:
        type: Number
        label: 'Like/Dislike'
    ]
  )

  schema.method(

    like: (user_id) ->
      for i in [0..@likes.length - 1]
        l = @likes[i]
        if l and l.user.toString() == user_id
          if l.liked == 1
            return
          else
            @likes.splice(i, 1)
            break
      @likes.push(
        user: user_id
        liked: 1
      )

    dislike: (user_id) ->
      for i in [0..@likes.length - 1]
        l = @likes[i]
        if l and l.user.toString() == user_id
          if l.liked == -1
            return
          else
            @likes.splice(i, 1)
            break
      @likes.push(
        user: user_id
        liked: -1
      )

    totalLikes: () ->
      t = 0
      for l in @likes
        t++ if l.liked == 1
      return t

    totalDislikes: () ->
      t = 0
      for l in @likes
        t++ if !l.liked == -1
      return t

    likeStatus: (user_id) ->
      for l in @likes
        if l.user.toString() == user_id
          return (if l.liked then 1 else -1)
      return 0

  )

)
