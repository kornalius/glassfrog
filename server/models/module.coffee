app = require("../app")
mongoose = require("mongoose")
timestamps = require('mongoose-time')()
ownable = require('mongoose-ownable')
async = require('async')
safejson = require('safejson')
filterPlugin = require('../mongoose_plugins/mongoose-filter')
Version = require('../mongoose_plugins/mongoose-version')()
VersionClass = require('../version')

VCGlobal = require("../vc_global")
Module = require("../vc_module")
Node = require("../vc_node")
Component = require("../vc_component")

ModuleSchema = mongoose.Schema(
  name:
    type: String
    required: true
    label: 'Name'

  desc:
    type: String
    label: 'Description'

  readme:
    type: String
    label: 'Read Me'

  icon:
    type: String
    label: 'Icon'

  color:
    type: String
    label: 'Color'

  share:
    type: mongoose.Schema.Types.ObjectId
    ref: 'Share'
    label: 'Share'

  repo:
    type: mongoose.Schema.Types.ObjectId
    ref: 'Repository'
    label: 'Original repository'

  extra:
    type: String
    label: 'Extra Info'

  version:
    type: Version
    default: '0.1.0a'
    label: 'Version'
,
  label: 'Modules'
)

ModuleSchema.plugin(timestamps)
ModuleSchema.plugin(ownable)
ModuleSchema.plugin(filterPlugin)

ModuleSchema.method(
  sanitizedId: () ->
    require('sanitize-filename')(@_id.toString())

  modulePath: (user) ->
    user.modulesPath() + '/' + @sanitizedId() + '.js'

  isBuilt: (user) ->
    require('fs').existsSync(@modulePath(user))

  build: (syntax, user) ->
    fs = require('fs')

    mpath = app.modulesPath
    if !fs.existsSync(mpath)
      fs.mkdirSync(mpath)

    upath = user.modulesPath()
    if !fs.existsSync(upath)
      fs.mkdirSync(upath)

    path = @modulePath(user)
    if fs.existsSync(path)
      fs.unlinkSync(path)

    if !syntax.error
      fs.writeFileSync(path, syntax.code)

  isOwned: (user_id, cb) ->
    cb(@owner_id.toString() == user_id) if cb

  canUninstall: (user_id, cb) ->
    cb(@repo?) if cb

  canDelete: (user_id, cb) ->
    that = @
    @isOwned(user_id, (ok) ->
      cb(ok) if cb
    )

  canUpdate: (user_id, cb) ->
    @needsUpdate(user_id, cb)

  canLike: (user_id, cb) ->
    @getRepo(user_id, (repo) ->
      if repo
        repo.canLike(user_id, cb)
      else
        cb(false) if cb
    )

  canDislike: (user_id, cb) ->
    @getRepo(user_id, (repo) ->
      if repo
        repo.canDislike(user_id, cb)
      else
        cb(false) if cb
    )

  published: (user_id, cb) ->
    that = @
    @getRepo(user_id, (repo) ->
      if repo
        that.isOwned(user_id, (ok) ->
          cb(repo and ok) if cb
        )
      else
        cb(null) if cb
    )

  canPublish: (user_id, cb) ->
    that = @
    @published(user_id, (repo) ->
      if !repo
        that.isOwned(user_id, cb)
      else
        cb(false) if cb
    )

  canUnpublish: (user_id, cb) ->
    that = @
    @published(user_id, (repo) ->
      if repo
        that.isOwned(user_id, cb)
      else
        cb(false) if cb
    )

  getRepo: (user_id, cb) ->
    if @repo?
      mongoose.model('Repository').findById(@repo.toString(), (err, repo) ->
        if !err and repo
          repo.extraFields(user_id, ->
            cb(repo) if cb
          )
        else
          cb(null) if cb
      )
    else
      cb(null) if cb

  needsUpdate: (user_id, cb) ->
    that = @
    @getRepo(user_id, (repo) ->
      if repo
        module_version = new VersionClass(that.version)
        repo_version = new VersionClass(repo.version)
        cb(module_version.compareTo(repo_version) < 0) if cb
      else
        cb(false) if cb
    )

  setExtraFields: (user_id, cb) ->
    that = @
    if @._doc?
      r = @._doc
    else
      r = @
    @getRepo(user_id, (repo) ->
      r.isOwned = that.owner_id.toString() == user_id
      r.canEdit = r.isOwned
      r.canInstall = false
      if repo
        module_version = new VersionClass(that.version)
        repo_version = new VersionClass(repo.version)
        r.needsUpdate = module_version.compareTo(repo_version) < 0
        r.installed = module_version.compareTo(repo_version) == 0
        r.canUninstall = !repo._doc.isOwned
        r.canDelete = repo._doc.isOwned
        r.canPublish = false
        r.canUnpublish = repo._doc.isOwned
        r.published = true
        r.liked = repo.likeStatus(user_id) == 1
        r.totalLikes = repo.totalLikes(user_id)
        mongoose.model('User').findById(repo.owner_id.toString(), (err, user) ->
          if user
            r.author = user.name.full
          repo.installations((c)->
            r.installations = c
            cb() if cb
          )
        )
      else
        r.needsUpdate = false
        r.installed = false
        r.canUninstall = false
        r.canDelete = r.isOwned
        r.canPublish = r.isOwned
        r.canUnpublish = false
        r.published = false
        r.liked = 0
        r.totalLikes = 0
        r.installations = 0
        mongoose.model('User').findById(that.owner_id.toString(), (err, user) ->
          if user
            r.author = user.name.full
          cb() if cb
        )
    )

  extraFields: (user_id, cb) ->
    @setExtraFields(user_id, cb)

  $update: (req, res, cb) ->
    that = @
    @canUpdate(req.user._id.toString(), (ok) ->
      if ok
        that.getRepo(req.user._id.toString(), (repo) ->
          if repo
            that.name = repo.name
            that.desc = repo.desc
            that.readme = repo.readme
            that.icon = repo.icon
            that.color = repo.color
            that.version = new VersionClass(repo.version).versionString()
            that.extra = _.cloneDeep(repo.extra)
  #          that.owner_id = req.user._id.toString()

            that._doc.isOwned = repo.owner_id.toString() == req.user._id.toString()
            that._doc.needsUpdate = false
            that._doc.installed = true
            that._doc.canUninstall = true
            that._doc.canInstall = false

            that.save()

            cb(null, repo) if cb
          else
            cb(new Error(404)) if cb
        )
      else
        cb(new Error(403)) if cb
    )

  $uninstall: (req, res, cb) ->
    that = @
    @canUninstall(req.user._id.toString(), (ok) ->
      if ok
        _id = that._id.toString()
        mongoose.model('Module').remove({ _id: _id }, (err) ->
          cb(err, _id) if cb
        )
      else
        cb(new Error(403)) if cb
    )

  $delete: (req, res, cb) ->
    that = @
    @canDelete(req.user._id.toString(), (ok) ->
      console.log "$delete()", ok
      if ok
        that.getRepo(req.user._id.toString(), (repo) ->

          doRemove = () ->
            _id = that._id.toString()
            mongoose.model('Module').remove({ _id: _id }, (err) ->
              cb(err, _id) if cb
            )

          if repo
            that.canUnpublish(req.user._id.toString(), (ok) ->
              if ok
                mongoose.model('Repository').remove({ _id: that.repo.toString() }, (err) ->
                  if !err
                    doRemove()
                  else
                    cb(err, null) if cb
                )
              else
                cb(err, null) if cb
            )
          else
            doRemove()
        )
      else
        cb(new Error(403)) if cb
    )

  $publish: (req, res, cb) ->
    that = @
    @canPublish(req.user._id.toString(), (ok) ->
      if ok
        mongoose.model('Repository').create(
          name: that.name
          desc: that.desc
          readme: that.readme
          icon: that.icon
          color: that.color
          version: new VersionClass(that.version).versionString()
          extra: _.cloneDeep(that.extra)
          owner_id: req.user._id.toString()
        , (err, repo) ->
          if repo
            that.repo = repo._id
            that.save((err) ->
              cb(err, repo) if cb
            )
          else
            cb(err, null) if cb
        )
      else
        cb(new Error(403)) if cb
    )

  $unpublish: (req, res, cb) ->
    that = @
    @canUnpublish(req.user._id.toString(), (ok) ->
      if ok
        _id = that._id.toString()
        mongoose.model('Repository').remove({ _id: that.repo.toString() }, (err) ->
          cb(err, _id) if cb
        )
      else
        cb(new Error(403)) if cb
    )

  $like: (req, res, cb) ->
    that = @
    @canLike(req.user._id.toString(), (ok) ->
      if ok
        that.getRepo(req.user._id.toString(), (repo) ->
          if repo
            repo.like(req.user._id.toString())
            repo.save((err) ->
              cb(err, repo._id) if cb
            )
          else
            cb(new Error(404)) if cb
        )
      else
        cb(new Error(403)) if cb
    )

  $dislike: (req, res, cb) ->
    that = @
    @canDislike(req.user._id.toString(), (ok) ->
      if ok
        that.getRepo(req.user._id.toString(), (repo) ->
          if repo
            repo.dislike(req.user._id.toString())
            repo.save((err) ->
              cb(err, repo._id) if cb
            )
          else
            cb(new Error(404)) if cb
        )
      else
        cb(new Error(403)) if cb
    )
)

ModuleSchema.static(
  findByNameOrDesc: (n, cb) ->
    mongoose.model('Module').find({$or: [{name: {$regex: new RegExp(n, "i")}}, {desc: {$regex: new RegExp(n, "i")}}]}, (err, c) ->
      cb(c) if cb
    )

  modules: (user_id, cb) ->
    mongoose.model('User').findById(user_id, (err, user) ->
      if user
        user.modules((modules) ->
          cb(modules) if cb
        )
    )

  allModules: (cb) ->
    mongoose.model('Module').find({}, (err, modules) ->
      r = []
      if modules
        for m in modules
          mm = m.toObject()
          Module.make(mm)
          r.push(mm)
      VCGlobal.modules.rows = r
      cb(r) if cb
    )
)

module.exports = mongoose.model('Module', ModuleSchema)

module.exports.deleteBuiltModules = (user) ->
  fs = require('fs')
  path = user.modulesPath()
  if fs.existsSync(path)
    fs.readdirSync(path).forEach((file) ->
      fs.unlinkSync(path + '/' + file)
    )

module.exports.rebuildModules = (user, cb) ->
  VCModule = require("../vc_module")
  @deleteBuiltModules(user)
  user.modules(true, (modules) ->
    done = []
    for m in modules
      mm = m.toObject()
      VCModule.make(mm)
      syntax = mm.generateCode(false, user)
      m.build(syntax, user)
      if !syntax.error
        done.push(m)
    cb(done) if cb
  )

setTimeout( ->
  data = [
    name: 'Travel Reservation'
    desc: 'Make flight reservations a breeze with this amazing module'
    icon: 'cic-airplane'
    color: 'lightblue'
    extra:
      root:
        name: 'Root'
        component: 'root'
        nodes: [
          name: 'Config'
          component: 'Module.Config'
        ,
          name: 'Plane'
          component: 'Schema'
          nodes: [
            name: 'FlightNo'
            component: 'Field'
            args:
              'options': ['Selected', 'Required', 'Indexed']
            nodes: [
              component: 'Field.Text'
            ,
              component: 'Font.Bold'
            ,
              component: 'LightBlue'
            ]
          ,
            name: 'SeatNo'
            component: 'Field'
            nodes: [
              component: 'Field.Percent'
            ,
              component: 'Field.Round'
              args:
                'round': 2
            ]
          ,
            name: 'myMethod'
            component: 'Schema.Method'
            nodes: [
              name: 'alert'
              component: 'alert'
              args:
                'Message': 'Very Nice!'
            ]
          ]
        ]
  ,
    name: 'Briefcases organizer'
    desc: 'Organizes all your briefcases to fit the most heroin possible ;)'
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
  ,
    name: 'Another Module'
    desc: 'This is my second test module'
    extra:
      root:
        name: 'Root'
        component: 'root'
        nodes: [
        ]
  ]

  M = mongoose.model('Module')

  M.remove({}, (err) ->

    mongoose.model('User').find({}, (err, users) ->
      if users
        owner = users[0]._id.toString()

        dd = data.map((d) ->
          f = _.clone(d)

          f.name = _.str.classify(f.name)
          f.owner_id = owner

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
