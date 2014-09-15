mongoose = require("mongoose")
timestamps = require('mongoose-time')()
Version = require('../mongoose_plugins/mongoose-version')()
comments = require('../mongoose_plugins/mongoose-comments')
likes = require('../mongoose_plugins/mongoose-likes')
Moment = require('moment')
safejson = require('safejson')

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

RepositorySchema.set('toObject', {virtuals: true})

RepositorySchema.plugin(timestamps)
RepositorySchema.plugin(comments)
RepositorySchema.plugin(likes)

RepositorySchema.virtual('version').get(->
  VersionClass = require("../version")
  l = { date: null, version: new VersionClass(), comments: ''}
  for h in @history
    hv = new VersionClass(h.version)
    if hv.compareTo(l.version) > 0
      l = h
  if !l.date
    l = null
  return l
)

RepositorySchema.virtual('test.name').get(->
  "test_name"
)

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

setTimeout( ->
  data = [
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
    history: [
      date: new Date()
      version: '1.0.1a'
      comments: 'Second release'
    ,
      date: new Moment().subtract('days', 7)
      version: '1.0.0a'
      comments: 'First release'
    ]
  ,
    name: 'Test Module'
    desc: 'This is a cool test module that will not be available during production, because we don\'t want people to get too addicted to it.'
    icon: 'cic-uniF7DF'
    color: 'blue'
    history: [
      date: new Date()
      version: '1.5.0r'
      comments: 'Third release'
    ,
      date: new Moment().subtract('days', 12)
      version: '1.3.2b'
      comments: 'Second release'
    ,
      date: new Moment().subtract('days', 30)
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
          f.owner_id = owner

          if f.extra
            safejson.stringify(f.extra, (err, json) ->
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
