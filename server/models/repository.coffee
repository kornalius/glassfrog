mongoose = require("mongoose")
timestamps = require('mongoose-time')()
Version = require('../mongoose_plugins/mongoose-version')()
comments = require('../mongoose_plugins/mongoose-comments')
likes = require('../mongoose_plugins/mongoose-likes')

RepositorySchema = mongoose.Schema(
  orig:
    type: mongoose.Schema.ObjectId
    ref: 'Module'
    label: 'Original module'
    populate: true

  name:
    type: String
    required: true
    label: 'Name'

  desc:
    type: String
    required: true
    label: 'Description'

  icon:
    type: String
    label: 'icon'

  color:
    type: String
    label: 'Color'

  extra:
    type: String
    label: 'Extra Info'

  history:
    type: [
      date:
        type: Date
        label: 'Date'
      version:
        type: Version
        label: 'Version'
      comments:
        type: String
        label: 'Comments'
    ]
    label: 'History'
,
  label: 'Repositories'
)

RepositorySchema.plugin(timestamps)
RepositorySchema.plugin(comments)
RepositorySchema.plugin(likes)

RepositorySchema.method(

  latest: () ->
    VersionClass = require("../version")
    l = { date: null, version: new VersionClass(), comments: ''}
    for h in @history
      hv = new VersionClass(h.version)
      if hv.compareTo(l.version) > 0
        l = h
    if !l.date
      l = null
    return l

  isNewer: (v) ->
    l = @latest()
    if l
      return l.version.compareTo(v) > 0
    else
      return true

  cloneFrom: (module) ->
    @name = module.name
    @desc = module.desc
    @icon = module.icon
    @color = module.color
    @extra = module.extra

  new_update: (comments, cb) ->
    @cloneFrom(@orig)
    @history.push(
      date: new Date()
      version: _.clone(@orig.version)
      comments: comments
    )
    @save(cb)

)

RepositorySchema.static(

  publish: (module_id, comments, cb) ->
    console.log "publish()", module_id, comments
    mongoose.model('Repository').find({orig: module_id}, (err, repo_module) ->

      if repo_module

        mongoose.model('Module').findById(module_id, (err, module) ->

          if module

            if module.owner_id? and repo_module.owner_id? and module.owner_id.toString() == repo_module.owner_id.toString()

              if repo_module.isNewer(module.version)
                repo_module.new_update(comments, (err, r) ->
                  cb(err, r) if cb
                )

              else
                cb(new Error('Version must be greater'), null) if cb

            else
              cb(new Error('You are not the owner or the module'), null) if cb

          else
            cb(new Error('Original module not found'), null) if cb
        )

      else
        cb(new Error('Module not found'), null) if cb
    )

)

module.exports = mongoose.model('Repository', RepositorySchema)
