mongoose = require("mongoose")
timestamps = require('mongoose-time')()
ownable = require('../mongoose_plugins/mongoose-ownable')

LikeSchema = mongoose.Schema(
  liked:
    type: Number
    label: 'Like/Dislike'
,
  label: 'Like'
)

LikeSchema.plugin(timestamps)
LikeSchema.plugin(ownable)

LikeSchema.extraFields = [

  (user_id, newObj, cb) ->
    that = @
    newObj.isOwned = that.owner_id.toString() == user_id
    mongoose.model('User').findById(that.owner_id.toString(), (err, user) ->
      if user
        newObj.author = user.name.full
      cb() if cb
    )

]

module.exports = ((schema, options) ->

  if options and options.path?
    path = options.path + '.'
  else
    path = ''

  likes = path + 'likes'

  schema.add(
    likes: [LikeSchema]
#    test:
#      type: String
#      get: (val) ->
#        return "getter worked"
  , path)

  if !schema.extraFields
    schema.extraFields = []

  schema.extraFields.push(

    (user_id, newObj, cb) ->
      that = @
      newObj.liked = that.likeStatus(user_id) == 1
      newObj.totalLikes = that.totalLikes()
      cb() if cb

  )

  schema.method(

    like: (user_id) ->
      ll = @get(likes)
      for i in [0..ll.length - 1]
        l = ll[i]
        if l and l.owner_id.toString() == user_id
          if l.liked == 1
            return
          else
            ll.splice(i, 1)
            break
      ll.push(
        owner_id: user_id
        liked: 1
      )
      @set(likes, ll)

    dislike: (user_id) ->
      ll = @get(likes)
      for i in [0..ll.length - 1]
        l = ll[i]
        if l and l.owner_id.toString() == user_id
          if l.liked == -1
            return
          else
            ll.splice(i, 1)
            break
      ll.push(
        owner_id: user_id
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
        if l.owner_id.toString() == user_id
          return (if l.liked then 1 else -1)
      return 0

    $like: (req, res, cb) ->
      @like(req.owner_id._id.toString())
      cb() if cb

    $dislike: (req, res, cb) ->
      @dislike(req.owner_id._id.toString())
      cb() if cb

    $total_likes: (req, res, cb) ->
      cb(@totalLikes()) if cb

    $total_dislikes: (req, res, cb) ->
      cb(@totalDislikes()) if cb

    $like_status: (req, res, cb) ->
      cb(@likeStatus(req.owner_id._id.toString())) if cb
  )

)
