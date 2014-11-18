mongoose = require("mongoose")
timestamps = require('mongoose-time')()
Version = require('../mongoose_plugins/mongoose-version')()
ownable = require('../mongoose_plugins/mongoose-ownable')
comments = require('../mongoose_plugins/mongoose-comments')
likes = require('../mongoose_plugins/mongoose-likes')
Moment = require('moment')
VersionClass = require('../version')

BlogSchema = mongoose.Schema(
  title:
    type: String
    required: true
    label: 'Title'

  content:
    type: String
    label: 'Content'

  tags:
    type: [String]
    label: 'Tags'
,
  label: 'Blogs'
)

BlogSchema.extraFields = [

  (user_id, newObj, cb) ->
    that = @
    newObj.isOwned = that.owner_id.toString() == user_id
    newObj.liked = that.likeStatus(user_id) == 1
    newObj.totalLikes = that.totalLikes()
    mongoose.model('User').findById(that.owner_id.toString(), (err, user) ->
      if user
        newObj.author = user.name.full
      cb() if cb
    )

]

#BlogSchema.set('toObject', {virtuals: true})
#BlogSchema.set('toJSON', {virtuals: true})

BlogSchema.plugin(timestamps)
BlogSchema.plugin(comments)
BlogSchema.plugin(likes)
BlogSchema.plugin(ownable)

BlogSchema.method(

  isOwned: (user_id, cb) ->
    cb(@owner_id.toString() == user_id) if cb

  canLike: (user_id, cb) ->
    cb(@owner_id.toString() != user_id) if cb

  canDislike: (user_id, cb) ->
    cb(@owner_id.toString() != user_id) if cb

  $like: (req, res, cb) ->
    that = @
    @canLike(req.user._id.toString(), (ok) ->
      if ok?
        that.like(req.user._id.toString())
        that.save((err) ->
          cb(err, that._id) if cb
        )
      else
        cb(new Error(403, 'Cannot like/unlike a module you own')) if cb
    )

  $dislike: (req, res, cb) ->
    that = @
    @canDislike(req.user._id.toString(), (ok) ->
      if ok
        that.dislike(req.user._id.toString())
        that.save((err) ->
          cb(err, that._id) if cb
        )
      else
        cb(new Error(403, 'Cannot like/unlike a module you own')) if cb
    )
)

BlogSchema.static(

)

module.exports = mongoose.model('Blog', BlogSchema)

if true
  setTimeout( ->
    data = [
      title: 'Today is the official launch day for Glassfrog'
      content: '**We are celebrating** a long and hard year of hard work and dedication. That\'s right, GlassFrog, is officially released and ready to be used. kdjkj adjkljsa kldj skld lshdjkhsaj dhsjkdh jksadh jksah djk hsajdkskldjaslk dhsalkdjlksaj dklsadj lksajd lksaj dkl saj dklsaj dklsaj dlsaj dlkashgdjksaghdkalsgdlhj agsdjkl;giuqt9 iqw h[ekwqmkdfb ijds -iquw9h eoih uidsagh'
      tags: ['today', 'joke', 'official', 'launch', 'glassfrog', 'celebration', 'first']
      comments: [
        message: 'crazy shit!'
      ,
        message: 'I will believe it when I see it.'
      ,
        message: 'Yeah right! :/'
      ,
        message: 'Earn 1000$ per week without even working! :/'
      ]
    ,
      title: 'Wrong wrong wrong'
      content: 'It is not true, GlassFrog, is not officially released. We were just fooling with you guys! HAHA!'
      tags: ['wrong', 'second']
      comments: [
        message: 'Ah, I knew it!'
      ,
        message: 'ArianeSoft is the devil!'
      ]
    ]

    M = mongoose.model('Blog')

    M.remove({}, (err) ->

      mongoose.model('User').find({}, (err, users) ->
        if users
          owner = users[0]._id.toString()

          dd = data.map((d) ->
            f = _.cloneDeep(d)
            f.owner_id = owner
            if f.comments
              for c in f.comments
                c.owner_id = owner
                c.ip = '127.0.0.1'
                c.likes = [{owner_id: owner, liked: 1}]
            return f
          )

          M.create(dd, (err, d) ->
            if err
              console.log err
          )
      )
    )

  , 1000)
