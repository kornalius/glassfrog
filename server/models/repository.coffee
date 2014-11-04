mongoose = require("mongoose")
timestamps = require('mongoose-time')()
Version = require('../mongoose_plugins/mongoose-version')()
ownable = require('mongoose-ownable')
comments = require('../mongoose_plugins/mongoose-comments')
likes = require('../mongoose_plugins/mongoose-likes')
Moment = require('moment')
VersionClass = require('../version')

RepositorySchema = mongoose.Schema(
  name:
    type: String
    required: true
    label: 'Name'

  desc:
    type: String
    required: true
    label: 'Description'

  readme:
    type: String
    label: 'Read Me'

  icon:
    type: String
    label: 'icon'

  color:
    type: String
    label: 'Color'

  tags:
    type: [String]
    label: 'Tags'

  extra:
    type: String
    label: 'Extra Info'

  history: [
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
,
  label: 'Repositories'
  readOnly: true
)

RepositorySchema.extraFields = [

  (user_id, newObj, cb) ->
    that = @
    mongoose.model('Module').findOne({ owner_id: user_id, repo: that._id.toString() }, (err, module) ->
      newObj.isOwned = that.owner_id.toString() == user_id
      if module
        module_version = new VersionClass(module.version)
        repo_version = new VersionClass(that.version)
        newObj.needsUpdate = module_version.compareTo(repo_version) < 0
        newObj.installed = module_version.compareTo(repo_version) == 0
        newObj.canInstall = false
        newObj.canUninstall = !newObj.isOwned
        newObj.published = true
        newObj.canPublish = false
        newObj.canPublishUpdate = false
        newObj.canUnpublish = newObj.isOwned
        newObj.canDelete = false
        newObj.canEdit = newObj.isOwned
      else
        newObj.needsUpdate = false
        newObj.installed = false
        newObj.canInstall = true
        newObj.canUninstall = false
        newObj.published = false
        newObj.canPublish = false
        newObj.canPublishUpdate = false
        newObj.canUnpublish = false
        newObj.canDelete = false
        newObj.canEdit = false
      mongoose.model('User').findById(that.owner_id.toString(), (err, user) ->
        if user
          newObj.author = user.name.full
        that.installations((c) ->
          newObj.installations = c
          cb() if cb
        )
      )
    )

]

#RepositorySchema.set('toObject', {virtuals: true})
#RepositorySchema.set('toJSON', {virtuals: true})

RepositorySchema.plugin(timestamps)
RepositorySchema.plugin(comments)
RepositorySchema.plugin(likes)
RepositorySchema.plugin(ownable)

RepositorySchema.virtual('version').get(->
  l = new VersionClass()
  for h in @history
    hv = new VersionClass(h.version)
    if hv.compareTo(l) > 0
      l = hv
      ok = true
  if ok
    return l.versionString()
  else
    return null
)

RepositorySchema.virtual('latest').get(->
  l = { date: null, version: new VersionClass(), comments: ''}
  for h in @history
    hv = new VersionClass(h.version)
    if hv.compareTo(l.version) > 0
      l.date = h.date
      l.version = hv
      l.comments = h.comments
  if !l.date
    l = null
  if l
    l.version = l.version.versionString()
  return l
)

RepositorySchema.method(

  installations: (cb) ->
    mongoose.model('Module').count({ repo: @_id.toString(), version: @version }, (err, c) ->
      cb(c) if cb
    )

  isOwned: (user_id, cb) ->
    cb(@owner_id.toString() == user_id) if cb

  installed: (user_id, cb) ->
    mongoose.model('Module').findOne({ owner_id: user_id, repo: @_id.toString(), version: @version }, (err, module) ->
      cb(module) if cb
    )

  canInstall: (user_id, cb) ->
    that = @
    @installed(user_id, (module) ->
      if module
        cb(false) if cb
        return
      that.isOwned(user_id, (ok) ->
        cb(!ok) if cb
      )
    )

  canUninstall: (user_id, cb) ->
    @installed(user_id, (module) ->
      cb(module != null) if cb
    )

  canUpdate: (user_id, cb) ->
    @needsUpdate(user_id, cb)

  canLike: (user_id, cb) ->
    cb(@owner_id.toString() != user_id)

  canDislike: (user_id, cb) ->
    cb(@owner_id.toString() != user_id)

  needsUpdate: (user_id, cb) ->
    that = @
    @installed(user_id, (module) ->
      if module
        module_version = new VersionClass(module.version)
        repo_version = new VersionClass(that.version)
        cb(module_version.compareTo(repo_version) < 0) if cb
      else
        cb(false) if cb
    )

  $install: (req, res, cb) ->
    that = @
    @canInstall(req.user._id.toString(), (ok) ->
      if ok
        mongoose.model('Module').create(
          name: that.name
          desc: that.desc
          readme: that.readme
          tags: _.clone(that.tags)
          icon: that.icon
          color: that.color
          repo: that._id.toString()
          version: new VersionClass(that.version).versionString()
          extra: _.cloneDeep(that.extra)
          owner_id: req.user._id.toString()
        , (err, module) ->
          cb(err, module) if cb
        )
      else
        cb(new Error(403)) if cb
    )

  $update: (req, res, cb) ->
    that = @
    that.installed(req.user._id.toString(), (module) ->
      if module
        module.$update(req, res, cb)
      else
        cb(new Error(404)) if cb
    )

  $uninstall: (req, res, cb) ->
    @installed(req.user._id.toString(), (module) ->
      if module
        module.$uninstall(req, res, cb)
      else
        cb(new Error(404), false) if cb
    )

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

RepositorySchema.static(

)

module.exports = mongoose.model('Repository', RepositorySchema)

setTimeout( ->
  data = [
    name: 'Briefcases organizer'
    desc: 'Organizes all your briefcases to fit the most heroin possible ;)'
    readme: '#Markdown directive\n*It works!*'
    tags: ["module", "briefcase", "organizer", "heroin"]
    icon: 'cic-suitcase6'
    color: 'darkorange'
    extra:
      root:
        name: 'Root'
        component: 'root'
        nodes: [
          name: 'Briefcase'
          component: 'Schema'
          nodes: [
            name: 'Kg'
            component: 'Field'
            nodes: [
              component: 'Number'
            ]
          ]
        ]
    history: [
      date: new Date()
      version: '1.0.1a'
      comments: 'Second release'
    ,
      date: new Moment().subtract(7, 'days')
      version: '1.0.0a'
      comments: 'First release'
    ]
  ,
    name: 'Test Module'
    desc: 'This is a cool test module that will not be available during production, because we don\'t want people to get too addicted to it.'
    readme: '#Markdown directive\n*It works!*'
    tags: ["module", "test", "cool"]
    icon: 'cic-uniF7DF'
    color: 'blue'
    history: [
      date: new Date()
      version: '1.5.0r'
      comments: 'Third release'
    ,
      date: new Moment().subtract(12, 'days')
      version: '1.3.2b'
      comments: 'Second release'
    ,
      date: new Moment().subtract(30, 'days')
      version: '1.0.0r'
      comments: 'First release'
    ]
  ,
    name: 'Test Module'
    desc: 'This is a cool test module that will not be available during production, because we don\'t want people to get too addicted to it.'
    readme: '#Markdown directive\n*It works!*'
    tags: ["module", "test", "cool"]
    icon: 'cic-uniF7DF'
    color: 'blue'
    history: [
      date: new Date()
      version: '1.5.0r'
      comments: 'Third release'
    ,
      date: new Moment().subtract(12, 'days')
      version: '1.3.2b'
      comments: 'Second release'
    ,
      date: new Moment().subtract(30, 'days')
      version: '1.0.0r'
      comments: 'First release'
    ]
  ,
    name: 'Test Module'
    desc: 'This is a cool test module that will not be available during production, because we don\'t want people to get too addicted to it.'
    readme: '#Markdown directive\n*It works!*'
    tags: ["module", "test", "cool"]
    icon: 'cic-uniF7DF'
    color: 'blue'
    history: [
      date: new Date()
      version: '1.5.0r'
      comments: 'Third release'
    ,
      date: new Moment().subtract(12, 'days')
      version: '1.3.2b'
      comments: 'Second release'
    ,
      date: new Moment().subtract(30, 'days')
      version: '1.0.0r'
      comments: 'First release'
    ]
  ,
    name: 'Test Module'
    desc: 'This is a cool test module that will not be available during production, because we don\'t want people to get too addicted to it.'
    readme: '#Markdown directive\n*It works!*'
    tags: ["module", "test", "cool"]
    icon: 'cic-uniF7DF'
    color: 'blue'
    history: [
      date: new Date()
      version: '1.5.0r'
      comments: 'Third release'
    ,
      date: new Moment().subtract(12, 'days')
      version: '1.3.2b'
      comments: 'Second release'
    ,
      date: new Moment().subtract(30, 'days')
      version: '1.0.0r'
      comments: 'First release'
    ]
  ,
    name: 'Test Module'
    desc: 'This is a cool test module that will not be available during production, because we don\'t want people to get too addicted to it.'
    readme: '#Markdown directive\n*It works!*'
    tags: ["module", "test", "cool"]
    icon: 'cic-uniF7DF'
    color: 'blue'
    history: [
      date: new Date()
      version: '1.5.0r'
      comments: 'Third release'
    ,
      date: new Moment().subtract(12, 'days')
      version: '1.3.2b'
      comments: 'Second release'
    ,
      date: new Moment().subtract(30, 'days')
      version: '1.0.0r'
      comments: 'First release'
    ]
  ,
    name: 'Test Module'
    desc: 'This is a cool test module that will not be available during production, because we don\'t want people to get too addicted to it.'
    readme: '#Markdown directive\n*It works!*'
    tags: ["module", "test", "cool"]
    icon: 'cic-uniF7DF'
    color: 'blue'
    history: [
      date: new Date()
      version: '1.5.0r'
      comments: 'Third release'
    ,
      date: new Moment().subtract(12, 'days')
      version: '1.3.2b'
      comments: 'Second release'
    ,
      date: new Moment().subtract(30, 'days')
      version: '1.0.0r'
      comments: 'First release'
    ]
  ,
    name: 'Test Module'
    desc: 'This is a cool test module that will not be available during production, because we don\'t want people to get too addicted to it.'
    readme: '#Markdown directive\n*It works!*'
    tags: ["module", "test", "cool"]
    icon: 'cic-uniF7DF'
    color: 'blue'
    history: [
      date: new Date()
      version: '1.5.0r'
      comments: 'Third release'
    ,
      date: new Moment().subtract(12, 'days')
      version: '1.3.2b'
      comments: 'Second release'
    ,
      date: new Moment().subtract(30, 'days')
      version: '1.0.0r'
      comments: 'First release'
    ]
  ,
    name: 'Test Module'
    desc: 'This is a cool test module that will not be available during production, because we don\'t want people to get too addicted to it.'
    readme: '#Markdown directive\n*It works!*'
    tags: ["module", "test", "cool"]
    icon: 'cic-uniF7DF'
    color: 'blue'
    history: [
      date: new Date()
      version: '1.5.0r'
      comments: 'Third release'
    ,
      date: new Moment().subtract(12, 'days')
      version: '1.3.2b'
      comments: 'Second release'
    ,
      date: new Moment().subtract(30, 'days')
      version: '1.0.0r'
      comments: 'First release'
    ]
  ,
    name: 'Test Module'
    desc: 'This is a cool test module that will not be available during production, because we don\'t want people to get too addicted to it.'
    readme: '#Markdown directive\n*It works!*'
    tags: ["module", "test", "cool"]
    icon: 'cic-uniF7DF'
    color: 'blue'
    history: [
      date: new Date()
      version: '1.5.0r'
      comments: 'Third release'
    ,
      date: new Moment().subtract(12, 'days')
      version: '1.3.2b'
      comments: 'Second release'
    ,
      date: new Moment().subtract(30, 'days')
      version: '1.0.0r'
      comments: 'First release'
    ]
  ,
    name: 'Test Module'
    desc: 'This is a cool test module that will not be available during production, because we don\'t want people to get too addicted to it.'
    readme: '### Markdown directive\n*It works!*\n*This* **is** [markdown](https://daringfireball.net/projects/markdown/) in the view.'
    tags: ["module", "test", "cool"]
    icon: 'cic-uniF7DF'
    color: 'blue'
    history: [
      date: new Date()
      version: '1.5.0r'
      comments: 'Third release'
    ,
      date: new Moment().subtract(12, 'days')
      version: '1.3.2b'
      comments: 'Second release'
    ,
      date: new Moment().subtract(30, 'days')
      version: '1.0.0r'
      comments: 'First release'
    ]
  ]

  M = mongoose.model('Repository')

  M.remove({}, (err) ->

    mongoose.model('User').find({}, (err, users) ->
      if users
        owner = users[0]._id.toString()

        dd = data.map((d) ->
          f = _.cloneDeep(d)

          f.name = _.str.classify(f.name)
          f.owner_id = '89127872913921'

          if f.extra
            jsonToString(f.extra, (err, json) ->
              if !err
                f.extra = json
              else
                throw err
            )

          return f
        )

        M.create(dd, (err) ->
          if err
            console.log err
        )
    )
  )

, 1000)
