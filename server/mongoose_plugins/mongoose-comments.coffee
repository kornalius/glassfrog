mongoose = require("mongoose")
timestamps = require('mongoose-time')()
ownable = require('mongoose-ownable')
likes = require('./mongoose-likes')

CommentSchema = mongoose.Schema(
  ip:
    type: String
    readOnly: true
    label: 'IP'

  message:
    type: String
    label: 'Message'
,
  label: 'Comment'
)

CommentSchema.plugin(timestamps)
CommentSchema.plugin(ownable)
CommentSchema.plugin(likes)

CommentSchema.extraFields = [

  (user_id, newObj, cb) ->
    that = @
    newObj.isOwned = that.owner_id.toString() == user_id
    newObj.canEdit = newObj.isOwned
    newObj.canDelete = newObj.isOwned
    newObj.liked = that.likeStatus(user_id) == 1
    newObj.totalLikes = that.totalLikes()
    mongoose.model('User').findById(that.owner_id.toString(), (err, user) ->
      if user
        newObj.author = user.name.full
      cb() if cb
    )

]

#CommentSchema.method(
#
#  editComment: (user_id, ip, message) ->
#    @get(comments).push(
#      owner_id: user_id
#      ip: ip if ip?
#      message: message if message?
#    )
#    @model.save()
#
#  $edit_comment: (req, res, cb) ->
#    cb(@addComment(req.user._id.toString(), req.ip, req.params.message))
#
#)


module.exports = ((schema, options) ->

  if options and options.path?
    path = options.path + '.'
  else
    path = ''

  comments = path + 'comments'

  schema.add(
    comments: [CommentSchema]
  , path)

  schema.method(

    addComment: (user_id, ip, message) ->
      @get(comments).push(
        owner_id: user_id
        ip: ip if ip?
        message: message if message?
      )
      @model.save()

    $add_comment: (req, res, cb) ->
      cb(@addComment(req.user._id.toString(), req.ip, req.params.message))

  )

)
