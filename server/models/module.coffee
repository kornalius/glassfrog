app = require("../app")
mongoose = require("mongoose")
timestamps = require('mongoose-time')()
ownable = require('../mongoose_plugins/mongoose-ownable')
async = require('async')
Version = require('../mongoose_plugins/mongoose-version')()
VersionClass = require('../version')
fs = require('fs')

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

  tags:
    type: [String]
    label: 'Tags'

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

ModuleSchema.extraFields = [

  (user_id, newObj, cb) ->
    that = @
    @getRepo(user_id, (repo) ->
#      repo.isOwned = repo.owner_id.toString() == user_id
      newObj.isOwned = that.owner_id.toString() == user_id
      newObj.canInstall = false
      if repo
        module_version = new VersionClass(that.version)
        repo_version = new VersionClass(repo.version)
        newObj.canEdit = repo.isOwned
        newObj.needsUpdate = module_version.compareTo(repo_version) < 0
        newObj.installed = module_version.compareTo(repo_version) == 0
        newObj.canUninstall = !repo.isOwned
        newObj.canDelete = repo.isOwned
        newObj.canPublish = false
        newObj.canPublishUpdate = repo.isOwned and module_version.compareTo(repo_version) > 0
        newObj.canUnpublish = repo.isOwned
        newObj.published = true
        newObj.liked = repo.likeStatus(user_id) == 1
        newObj.totalLikes = repo.totalLikes(user_id)
        mongoose.model('User').findById(repo.owner_id.toString(), (err, user) ->
          if user
            newObj.author = user.name.full
          repo.installations((c)->
            newObj.installations = c
            cb() if cb
          )
        )
      else
        newObj.needsUpdate = false
        newObj.installed = false
        newObj.canUninstall = false
        newObj.canEdit = newObj.isOwned
        newObj.canDelete = newObj.isOwned
        newObj.canPublish = newObj.isOwned
        newObj.canPublishUpdate = false
        newObj.canUnpublish = false
        newObj.published = false
        newObj.liked = 0
        newObj.totalLikes = 0
        newObj.installations = 0
        mongoose.model('User').findById(that.owner_id.toString(), (err, user) ->
          if user
            newObj.author = user.name.full
          cb() if cb
        )
    )

]

#ModuleSchema.set('toObject', {virtuals: true})
#ModuleSchema.set('toJSON', {virtuals: true})

ModuleSchema.plugin(timestamps)
ModuleSchema.plugin(ownable)

ModuleSchema.pre('save', (next) ->
  if @tags and type(@tags) == 'string'
    @tags = @tags.split(',')

  if !@tags or type(@tags) != 'array'
    @tags = []

  @tags = @tags.map((t) -> t.toLowerCase())
  if @tags.indexOf("module") == -1
    @tags.nonAtomicPush("module")

  next()
)

ModuleSchema.virtual('latest').get(->
  return { date: @updated_at, version: @version, comments: ''}
)

ModuleSchema.method(
  sanitizedId: () ->
    require('sanitize-filename')(@_id.toString())

  modulePath: (user, codetype) ->
    if codetype?
      e = '_' + codetype.toLowerCase()
    else
      e = ''
    user.modulesPath() + '/' + @sanitizedId() + e + '.js'

  isBuilt: (user, codetype, cb) ->
    if cb
      fs.exists(@modulePath(user, codetype), (exists) ->
        cb(exists)
      )
    else
      fs.existsSync(@modulePath(user, codetype))

  makeDirs: (user, cb) ->
    mpath = app.modulesPath
    upath = user.modulesPath()
    if cb
      fs.mkdir(mpath, (err) ->
        if !err
          fs.mkdir(upath, (err) ->
            cb(err)
          )
        else
          cb(err)
      )
    else
      e = null
      if !fs.existsSync(mpath)
        try
          fs.mkdirSync(mpath)
        catch err
          e = err

      if !e
        if !fs.existsSync(upath)
          try
            fs.mkdirSync(upath)
          catch err
            e = err
      return e

  deleteBuiltFile: (user, codetype, cb) ->
    path = @modulePath(user, codetype)
    if cb
      fs.unlink(path, (err) ->
        cb(err)
      )
    else
      e = null
      if fs.existsSync(path)
        try
          fs.unlinkSync(path)
        catch err
          e = err
      return e

  deleteBuiltFiles: (user, cb) ->
    codetypes = ['server', 'client', 'html']
    if cb
      that = @
      async.eachSeries(codetypes, (t, callback) ->
        that.deleteBuiltFile(user, t, (err) ->
          callback()
        )
      , (err) ->
        cb()
      )
    else
      for t in codetypes
        @deleteBuiltFile(user, t)

  makeFile: (syntax, user, codetype, cb) ->
    path = @modulePath(user, codetype)
    if cb
      that = @
      that.makeDirs(user, (err) ->
        that.deleteBuiltFile(user, codetype, (err) ->
          fs.writeFile(path, syntax.code, (err) ->
            if err
              console.log err
            cb(err)
          )
        )
      )
    else
      e = null
      @makeDirs(user)
      @deleteBuiltFile(user, codetype)
      try
        fs.writeFileSync(path, syntax.code)
      catch err
        console.log err
        e = err
      return e

  build: (codetype, user, cb) ->
    that = @

    if !that.$data
      m = that.toObject()
      require('../vc_module').make(m)
    else
      m = that

    if m.generateCode
      syntax = m.generateCode(codetype, user)
      if syntax.error
        cb(null, syntax) if cb
      else
        that.makeFile(syntax, user, codetype, (err) ->
          if err
            console.log err
          cb(null, syntax) if cb
        )
    else
      cb(null, null)

  buildModule: (user, cb) ->
    that = @
    done = []
    that.deleteBuiltFiles(user, (err) ->
      if !err
        async.eachSeries(['server', 'client', 'html'], (t, callback) ->
          that.build(t, user, (err, syntax) ->
            if syntax and syntax.error
              e = {'$e': {desc: syntax.error.desc, message: syntax.error.message, messageHtml: syntax.error.messageHtml, _id: syntax.error._id, name: syntax.error.name, pos: syntax.error.loc.pos, line: syntax.error.loc.line, col: syntax.error.loc.column}}
            else
              e = null
            done.push({ module: that, type: t, syntax: syntax, error: e })
            callback()
          )
        , (err) ->
          cb(done) if cb
        )
      else
        console.log err
        cb(done) if cb
    )

  $build: (req, res, cb) ->
    console.log "$build()", req.query, req.params
    that = @

    mongoose.model('Module').findOne({ owner_id: req.user._id.toString(), _id: req.params.id }, (err, m) ->
      if m
        that.buildModule(req.user, (done) ->
          for d in done
            if d.error and d.error
              cb(null, d.error) if cb
              return
          cb(null, null) if cb
        )
      else
        cb(new Error(404))
    )

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

  canPublishUpdate: (user_id, cb) ->
    that = @
    @published(user_id, (repo) ->
      if repo
        that.isOwned(user_id, (ok) ->
          console.log that.version, repo.version, (new VersionClass(that.version)).compareTo(new VersionClass(repo.version))
          cb(ok and (new VersionClass(that.version)).compareTo(new VersionClass(repo.version)) > 0) if cb
        )
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
      m = mongoose.model('Repository')
      m.findById(@repo.toString(), (err, repo) ->
        if !err and repo
#          require('../endpoints').addExtraFields(user_id, repo, m.schema, ->
          cb(repo) if cb
#          )
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

  $update: (req, res, cb) ->
    that = @
    @canUpdate(req.user._id.toString(), (ok) ->
      if ok
        that.getRepo(req.user._id.toString(), (repo) ->
          if repo
            that.name = repo.name
            that.desc = repo.desc
            that.readme = repo.readme
            that.tags = _.clone(repo.tags)
            that.icon = repo.icon
            that.color = repo.color
            that.version = new VersionClass(repo.version)
            that.extra = _.cloneDeep(repo.extra)

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
          tags: _.clone(that.tags)
          icon: that.icon
          color: that.color
          history: [
            version: new VersionClass(that.version).versionString()
            date: new Date()
          ]
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

  $publishupdate: (req, res, cb) ->
    that = @
    @canPublishUpdate(req.user._id.toString(), (ok) ->
      if ok
        that.getRepo(req.user._id.toString(), (repo) ->
          if repo
            repo.name = that.name
            repo.desc = that.desc
            repo.readme = that.readme
            repo.tags = _.clone(that.tags)
            repo.icon = that.icon
            repo.color = that.color
            repo.extra = _.cloneDeep(that.extra)
            if !repo.history
              repo.history = []
            repo.history.push(
              version: new VersionClass(that.version).versionString()
              date: new Date()
            )
            repo.save((err, repo) ->
              cb(err, repo) if cb
            )
          else
            cb(new Error(404)) if cb
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
        cb(new Error(403, 'Cannot like/unlike a module you own')) if cb
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
        cb(new Error(403, 'Cannot like/unlike a module you own')) if cb
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

module.exports.deleteBuiltModules = (user, cb) ->
  path = user.modulesPath()
  if cb
    fs.exists(path, (exists) ->
      if exists
        fs.readdir(path, (err, files) ->
          if !err
            async.eachSeries(files, (file, callback) ->
              fs.unlink(path + '/' + file, (err) ->
                callback()
              )
            , (err) ->
              cb(err)
            )
          else
            cb(err)
        )
      else
        cb()
    )
  else
    e = null
    if fs.existsSync(path)
      fs.readdirSync(path).forEach((file) ->
        try
          fs.unlinkSync(path + '/' + file)
        catch err
          console.log err
          e = err
      )
    return e

module.exports.rebuildModules = (user, cb) ->
  @deleteBuiltModules(user, ->
    user.modules(true, (modules) ->
      if modules
        done = []
        async.eachSeries(modules, (m, callback) ->
          m.buildModule(user, (err) ->
            done.push({ module: m, error: (if syntax then syntax.error else null) })
            callback()
          )
        , (err) ->
          cb(done) if cb
        )
      else
        cb(done) if cb
    )
  )


if false
  setTimeout( ->
    data = [
      name: 'Travel Reservation'
      desc: 'Make flight reservations a breeze with this amazing module'
      tags: ["module", "travel", "reservation"]
      icon: 'cic-airplane'
      color: 'lightblue'
      extra:
        root:
          _id: makeId()
          name: 'Root'
          component: 'root'
          nodes: [
            _id: makeId()
            name: 'Config'
            component: 'Module.Config'
          ,
            _id: makeId()
            name: 'Plane'
            component: 'Schema'
            nodes: [
              _id: makeId()
              name: 'FlightNo'
              component: 'Field'
              args:
                'options': ['Required', 'Trimmed']
              nodes: [
                _id: makeId()
                component: 'Field.Text'
              ,
                _id: makeId()
                component: 'Font.Bold'
              ,
                _id: makeId()
                component: 'LightBlue'
              ]
            ,
              _id: makeId()
              name: 'SeatNo'
              component: 'Field'
              nodes: [
                _id: makeId()
                component: 'Field.Percent'
              ,
                _id: makeId()
                component: 'Field.Round'
                args:
                  'round': 2
              ]
            ,
              _id: makeId()
              name: 'myMethod'
              component: 'Schema.Method'
              nodes: [
                _id: makeId()
                name: 'alert'
                component: 'alert'
                args:
                  'Message': 'Very Nice!'
              ]
            ]
          ]
    ,
      _id: makeId()
      name: 'Briefcases organizer'
      desc: 'Organizes all your briefcases to fit the most heroin possible ;)'
      tags: ["module", "briefcase", "organizer", "heroin"]
      icon: 'cic-suitcase6'
      color: 'darkorange'
      extra:
        root:
          _id: makeId()
          name: 'Root'
          component: 'root'
          nodes: [
            _id: makeId()
            name: 'Briefcase'
            component: 'Schema'
            nodes: [
              _id: makeId()
              name: 'Kg'
              component: 'Field'
              nodes: [
                _id: makeId()
                component: 'Number'
              ]
            ]
          ]
    ,
      _id: makeId()
      name: 'Another Module'
      desc: 'This is my second test module'
      tags: ["module"]
      extra:
        root:
          _id: makeId()
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
              jsonToString(f.extra, (err, string) ->
                if !err
                  f.extra = string
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
