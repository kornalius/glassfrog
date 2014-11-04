mongoose = require("mongoose")

module.exports = ((schema, options) ->

  if options and options.path?
    path = options.path + '.'
  else
    path = ''

  likes = path + 'likes'

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
  , path)

  schema.method(

    like: (user_id) ->
      ll = @get(likes)
      for i in [0..ll.length - 1]
        l = ll[i]
        if l and l.user.toString() == user_id
          if l.liked == 1
            return
          else
            ll.splice(i, 1)
            break
      ll.push(
        user: user_id
        liked: 1
      )
      @set(likes, ll)

    dislike: (user_id) ->
      ll = @get(likes)
      for i in [0..ll.length - 1]
        l = ll[i]
        if l and l.user.toString() == user_id
          if l.liked == -1
            return
          else
            ll.splice(i, 1)
            break
      ll.push(
        user: user_id
        liked: -1
      )
      @set(likes, ll)

    totalLikes: () ->
      t = 0
      for l in @get(likes)
        t++ if l.liked == 1
      return t

    totalDislikes: () ->
      t = 0
      for l in @get(likes)
        t++ if !l.liked == -1
      return t

    likeStatus: (user_id) ->
      for l in @get(likes)
        if l.user.toString() == user_id
          return (if l.liked then 1 else -1)
      return 0

  )

)
