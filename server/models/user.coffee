app = require("../app")
mongoose = require("mongoose")
locking = require('mongoose-account-locking')
timestamps = require('mongoose-time')()
async = require('async')
bcrypt = require('bcrypt')
endpoints = require('../endpoints')
safejson = require('safejson')
VCModule = require('../vc_module')
filterPlugin = require('../mongoose_plugins/mongoose-filter')

person = require('../mongoose_plugins/mongoose-person')
password = require('../mongoose_plugins/mongoose-password')
address = require('../mongoose_plugins/mongoose-address')
picture = require('../mongoose_plugins/mongoose-picture')
payment = require('../mongoose_plugins/mongoose-payment')

UserSchema = mongoose.Schema(
  username:
    type: String
    unique: true
    index: true
    trim: true
    required: true
    label: 'Username'

  email:
    type: String
    unique: true
    index: true
    trim: true
    required: true
    label: 'Email'

  hashedEmail:
    type: String
    private: true
    readOnly: true

  accessToken:
    type: String
    private: true
    readOnly: true

  activationEmailSent:
    type: Date
    private: true
    readOnly: true

  status:
    type: String
    enum: ['active', 'disabled', 'locked']
    default: 'disabled'
    required: true
    readOnly: true
    label: 'Status'

  plan:
    type: mongoose.Schema.Types.ObjectId
    ref: 'Plan'
    label: 'Payment plan'
    readOnly: true
    populate: true

  data:
    type: String
    label: 'JSON custom data'

  roles: [
    type: mongoose.Schema.Types.ObjectId
    ref: 'Role'
    label: 'Roles'
    populate: true
    private: true
    readOnly: true
  ]

  connection:
    prefix:
      type: String
#        default: () -> String(Math.random()).substring(2,6)
      label: 'Connection prefix'
      readOnly: true
      private: true

    name:
      type: String
      label: 'Connection name'
      readOnly: true
      private: true

    uri:
      type: String
      label: 'Connection URI'
      readOnly: true
      private: true

    port:
      type: Number
      label: 'Connection port'
      readOnly: true
      private: true

    username:
      type: String
      label: 'Connection username'
      private: true
      readOnly: true

    password:
      type: String
      label: 'Connection password'
      readOnly: true
      private: true
,
  label: 'Users'
)

UserSchema.plugin(person)
UserSchema.plugin(password)
UserSchema.plugin(address)
UserSchema.plugin(picture)
UserSchema.plugin(payment)

UserSchema.plugin(timestamps)
UserSchema.plugin(locking,
  maxLoginAttempts = 5
  lockTime = 2 * 60 * 60 * 1000
  username = 'username'
  password = 'password'
)

UserSchema.plugin(filterPlugin)

UserSchema.set('toObject', {virtuals: true})
#UserSchema.set('toJSON', {virtuals: true})

UserSchema.pre('save', (next) ->
  if !@plan?
    that = @
    mongoose.model('Plan').findOne({name: 'Free'}, (err, plan) ->
      if plan
        that.plan = plan._id
      next()
    )
  else
    next()
)

UserSchema.virtual('isVerified').get(->
  @status == 'active'
)

UserSchema.method(
  cryptEmail: (cb) ->
    that = @
    bcrypt.genSalt(10, (err, salt) ->
      if !err?
        bcrypt.hash(that.email, salt, (err, hash) ->
          if !err?
            that.hashedEmail = hash
            that.save()
          cb() if cb
        )
    )

  generateRandomToken: () ->
    chars = "_!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    token = new Date().getTime() + '_'
    for x in [0..16]
      i = Math.floor(Math.random() * 62)
      token += chars.charAt(i)
    return token

  userPlan: (cb) ->
    mongoose.model('Plan').findById(@plan, (err, plan) ->
      cb(plan) if cb
    )

  allRoles: (cb) ->
    results = []
    @populate('roles', (err, user) ->
      async.eachSeries(user.roles, (role, callback) ->
        results.push(role)
        role.allParentRoles((inherits) ->
          if inherits
            results = results.concat(inherits)
          callback()
        )
      , (err) ->
        cb(results) if cb
      )
    )

  hasRole: (name, cb) ->
    that = @
    name = name.toLowerCase()
    @allRoles((roles) ->
      if roles
        for role in roles
          if role.name == name
            console.log "{yellow}" + that.username, "{reset}has role{blue}", name
            cb(role) if cb
            return

#      console.log that.username, "does not have role", name
      cb(null) if cb
    )

  addRole: (name, cb) ->
    that = @
    @hasRole(name, (role) ->
      if !role
        mongoose.model('Role').findOne({ name: name.toLowerCase() }, (err, role) ->
          that.roles.push(role._id)
          that.save()
          cb(role) if cb
        )
      cb(null) if cb
    )

  removeRole: (name, cb) ->
    that = @
    results = []
    name = name.toLowerCase()
    @populate('roles', (err, roles) ->
      if roles
        for role in roles
          if role.name == name
            results.push(role)
        for role in results
          that.roles.remove(role)
        that.save()

      cb() if cb
    )

  allRules: (subject, actions, cb) ->
    results = []
    @allRoles((roles) ->
      async.eachSeries(roles, (role, callback) ->
        role.allRules(subject, actions, (rules) ->
          if rules
            results = results.concat(rules)
          callback()
        )
      , (err) ->
        cb(results) if cb
      )
    )

  hasRule: (subject, actions, cb) ->
    @allRules(subject, actions, (rules) ->
      cb(rules != null) if cb
    )

  hasAdmin: (roles) ->
    for role in roles
      if role.name == 'admin'
        return true
    return false

  can: (actions, subject, rows, cb) ->
    that = @

    if type(actions) is 'string'
      actions = [actions]

    action_names = []
    for action in actions
      if action == 'schema'
        action_names.push("read schema")
      else if action == 'defaults'
        action_names.push("read default values")
      else
        action_names.push(action)
    action_names = action_names.join(' or ')

    console.log "can {yellow}" + that.username + " {cyan}" + action_names + "{reset} from/to model {magenta}" + subject + "{reset}?"

    that.hasRole('admin', (isAdmin) ->
      if isAdmin
        cb('admin') if cb
      else
        that.allRules(subject, actions, (rules) ->
          if rules
            rule = mongoose.model('Role').canWithRules(that, rules, rows)
          else
            rule = null
          console.log "{yellow}" + that.username + "{reset} " + (if !rule then "cannot" else "can") + " {cyan}" + action_names + " {reset}from/to model {magenta}" + subject + "{reset} {blue}" +  (if rule then rule else "")
          cb(rule) if cb
        )
    )

  isAdmin: (cb) ->
    @hasRole('admin', cb) if cb

  isActive: (cb) ->
    cb(@status == 'active') if cb

  isDisabled: (cb) ->
    cb(@status == 'disabled' or @status == 'locked') if cb

  isLockedOut: (cb) ->
    cb(@status == 'locked') if cb

  isPaidPlan: (cb) ->
    @populate('plan', (err, plan) ->
      cb(plan and plan.isPaidPlan()) if cb
    )

  getData: (key) ->
    if !@data?
      @data = '{}'
    jsonToString(@data)[key]

  setData: (key, value) ->
    if !@data?
      @data = '{}'
    j = stringToJson(@data)
    j[key] = value
    that = @
    jsonToString(j, (err, json) ->
      if !err
        that.data = json
        that.save()
      else
        throw err
    )

  modules: (plain, cb) ->
    if type(plain) is 'function'
      cb = plain
      plain = false

    that = @
    r = []
    mongoose.model('Module').find({owner_id: that.id}, (err, modules) ->
      if modules
        for m in modules
          if plain
            r.push(m)
          else
            mm = m.toObject()
            VCModule.make(mm)
            r.push(mm)

#      mongoose.model('Share').find({ $and: [
#        {'users.user': that.id},
#        {'users.state': 'active'}
#      ] }).populate('module').exec((err, shares) ->
#        if shares
#          for s in shares
#            if plain
#              r.push(s.module)
#            else
#              mm = s.module.toObject()
#              VCModule.make(mm)
#              r.push(mm)
#
#        cb(r) if cb
#      )

      cb(r) if cb
    )

  getConnection: (cb) ->
    that = @
    @populate('plan', (plan) ->
      prefix = ''
      c = mongoose.connection

      if plan
        if plan.canCreateConnection() and that.connection.name?
          cn = that.connection.name
          c = mongoose.connections[cn]
          if !c
            if plan.canHaveOwnDatabase()
              uri = app.mongoUri
              if plan.canUseExternalConnection() and that.connection.uri?
                uri = that.connection.uri
            c = mongoose.createConnection(uri + cn)
        else
          if plan.canUseOwnCollection() and that.connection.prefix?
            prefix = that.connection.prefix + '_'

      cb(plan, c, prefix) if cb
    )

  getModelSync: (name, req) ->
    m = null
    console.log "{yellow}user.getModelSync(){reset}", name
    if req.user and req.c
      if mongoose.modelNames().indexOf(req.prefix + name) != -1
        m = mongoose.model(req.prefix + name)
      if !m and req.c.modelNames().indexOf(req.prefix + name) != -1
        m = req.c.model(req.prefix + name)
    return m

  getModel: (name, cb) ->
    console.log "{yellow}user.getModel(){reset}", name
    @getConnection((plan, c, prefix) ->
      if c
        m = null

        if mongoose.modelNames().indexOf(prefix + name) != -1
          m = mongoose.model(prefix + name)

        if !m and c.modelNames().indexOf(prefix + name) != -1
          m = c.model(prefix + name)

        cb(m, plan, c, prefix) if cb

      else
        cb(null, plan, c, prefix) if cb
    )

  loadModelSync: (name, schema, req) ->
    console.log "{yellow}user.loadModelSync(){reset}", name
    m = @getModelSync(name, req)
    if !m or !_.isEqual(m.schema, schema)
      delete req.c.models[req.prefix + name]
      m = req.c.model(req.prefix + name, schema)
    return m

  loadModel: (name, schema, cb) ->
    console.log "{yellow}user.loadModel(){reset}", name
    @getModel(name, (m, plan, c, prefix) ->
      if !m or !_.isEqual(m.schema, schema)
        delete c.models[prefix + name]
        m = c.model(prefix + name, schema)
      cb(m, plan, c, prefix) if cb
    )

  unloadModelSync: (name, req) ->
    console.log "{yellow}user.unloadModelSync(){reset}", name
    m = @getModelSync(name, req)
    if m
      delete req.c.models[req.prefix + name]
    return m

  unloadModel: (name, cb) ->
    console.log "{yellow}user.unloadModel(){reset}", name
    @getModel(name, (m, plan, c, prefix) ->
      if m
        delete c.models[prefix + name]
      cb(m != null) if cb
    )

  unloadAllModelsSync: (req) ->
    console.log "{yellow}user.unloadAllModelsSync(){reset}"
    if req.modules
      for m in req.modules
        for s in m.schemas()
          delete req.c.models[req.prefix + s.varName()]

  unloadAllModels: (cb) ->
    that = @
    console.log "{yellow}user.unloadAllModels(){reset}"
    @getConnection((plan, c, prefix) ->
      that.modules((modules) ->
        for m in modules
          for s in m.schemas()
            delete c.models[prefix + s.varName()]
        cb() if cb
      )
    )

  sanitizedId: () ->
    require('sanitize-filename')(@_id.toString())

  modulesPath: () ->
    app.modulesPath + '/' + @sanitizedId()

  createRequestVars: (req, cb) ->
    that = @
    that.modules((modules) ->
      req.modules = (if modules then modules else [])
      that.getConnection((plan, c, prefix) ->
        req.c = c
        req.plan = plan
        req.prefix = prefix
        console.log "createRequestVars()", "c:", req.c.name, "plan:", req.plan?.name, "prefix:", req.prefix, "modules:", req.modules?.length
        cb() if cb
      )
    )

  modelSync: (name, req) ->
    console.log "{yellow}user.fastModel(){reset}", name
    m = @getModelSync(name, req)
    if !m
      dire = require('dire')

      mp = @modulesPath()

      generatedModules = []
      try
        if require('fs').existsSync(mp)
          generatedModules = dire(mp + '/', false, '.js')
      catch e
        console.log "{error}dire error", e

      console.log generatedModules

      for mm in req.modules
        for s in mm.schemas()

          gm = generatedModules[require('sanitize-filename')(mm.id().toString())]
          if gm
            schema = gm[req.prefix + s.varName()]
            if schema
              m = mm
              break

        if schema
          break

      if m
        @loadModelSync(name, schema, req)

    return m

  model: (name, cb) ->
    that = @
    console.log "{yellow}user.model(){reset}", name
    @getModel(name, (m, plan, c, prefix) ->
      if !m
        dire = require('dire')

        try
          if require('fs').existsSync(that.modulesPath())
            generatedModules = dire(that.modulesPath() + '/', false, '.js')
          else
            generatedModules = []
        catch e
          console.log "{error}dire error", e

        console.log generatedModules

        that.modules((modules) ->
          for mm in modules
            for s in mm.schemas()

              gm = generatedModules[require('sanitize-filename')(mm.id().toString())]
              if gm
                schema = gm[prefix + s.varName()]
                if schema
                  m = mm
                  break

            if schema
              break

          if m
            that.loadModel(name, schema, (m, plan, c, prefix) ->
              cb(m, plan, c, prefix) if cb
            )
          else
            cb(null, plan, c, prefix) if cb
        )
      else
        cb(m, plan, c, prefix) if cb
    )
)

module.exports = mongoose.model('User', UserSchema)

setTimeout(->
  adminUser =
    username: 'kornalius'
    email: 'arianesoftinc@gmail.com'
    password: 'test'
    name:
      first: 'Alain'
      last: 'Deschenes'
    status: 'active'
    connection:
      name: 'admin'


  mongoose.model('User').findOne({ username: adminUser.username }, (err, user) ->
    if !user
      mongoose.model('User').create(adminUser, (err, user) ->
        if err
          console.log "{error}" + err
#        console.log "Created default admin user", err, user
      )
  )
, 100)
