app = require("../app")
mongoose = require("mongoose")
locking = require('mongoose-account-locking')
timestamps = require('mongoose-time')()
async = require('async')
bcrypt = require('bcrypt')
endpoints = require('../endpoints')
safejson = require('safejson')
RestEndpoints = require('mongoose-rest-endpoints')
VCModule = require('../vc_module')

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
    type: mongoose.Schema.ObjectId
    ref: 'Plan'
    label: 'Payment plan'
    readOnly: true
    populate: true

  data:
    type: String
    label: 'JSON custom data'

  roles:
    type: [
      type: mongoose.Schema.ObjectId
      ref: 'Role'
    ]
    label: 'Roles'
    private: true
    readOnly: true

  connection:
    type:
      prefix:
        type: String
#        default: () -> String(Math.random()).substring(2,6)
        label: 'Connection prefix'
        readOnly: true

      name:
        type: String
        label: 'Connection name'
        readOnly: true

      uri:
        type: String
        label: 'Connection URI'
        readOnly: true

      port:
        type: Number
        label: 'Connection port'
        readOnly: true

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

    label: 'MongoDB connection'
    populate: true
    readOnly: true
,
  label: 'Users'
)

UserSchema.plugin(person)
UserSchema.plugin(password)
UserSchema.plugin(address)
UserSchema.plugin(picture)
UserSchema.plugin(payment)

UserSchema.set('toObject', {virtuals: true})

UserSchema.plugin(timestamps)
UserSchema.plugin(locking,
  maxLoginAttempts = 5
  lockTime = 2 * 60 * 60 * 1000
  username = 'username'
  password = 'password'
)

UserSchema.pre('save', (next) ->
  if !@plan?
    that = @
    mongoose.model('Plan').find({name: 'Free'}, (err, plan) ->
      that.plan = plan._id
      next()
    )
  else
    next()
)

UserSchema.virtual('isVerified').get( ->
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

  canCreateRecord: (model, cb) ->
    that = @
    @can(['create'], model, null, (ok) ->
      if ok
        mongoose.model('Plan').findById(that.plan, (err, plan) ->
          if !err and plan?
            plan.canCreateRecord(model, cb)
          else
            cb(false) if cb
        )
      else
        cb(false) if cb
    )

  allRoles: (cb) ->
    r = []
    @populate('roles', (err, user) ->
      async.eachSeries(user.roles, (role, callback) ->
        r.push(role)
        role.allParentRoles((inherits) ->
          if inherits
            r = r.concat(inherits)
          callback()
        )
      , (err) ->
        cb(r) if cb
      )
    )

  hasRole: (name, cb) ->
    that = @
    name = name.toLowerCase()
    @allRoles((roles) ->
      if roles
        for role in roles
          if role.name == name
            RestEndpoints.log that.username, "has role", name
            cb(role) if cb
            return

      RestEndpoints.log that.username, "does not have role", name
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
    r = []
    name = name.toLowerCase()
    @populate('roles', (err, roles) ->
      if roles
        for role in roles
          if role.name == name
            r.push(role)
        for role in r
          that.roles.remove(role)
        that.save()

      cb() if cb
    )

  allRules: (subject, actions, cb) ->
    r = []
    @allRoles((roles) ->
      async.eachSeries(roles, (role, callback) ->
        role.allRules(subject, actions, (rules) ->
          if rules
            r = r.concat(rules)
          callback()
        )
      , (err) ->
        cb(r) if cb
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

  can: (actions, subject, row, cb) ->
    that = @

#    RestEndpoints.log "can", that.username, actions, "from/to model", subject, (if row then "with data" else ""), (if row then row else ""), "?"

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

    that.allRoles((roles) ->
      if roles

        # check if admin
        if that.hasAdmin(roles)
          RestEndpoints.log that.username, "can", action_names, "from/to model", subject, 'admin'
          cb('admin') if cb
          return

        async.eachSeries(roles, (role, callback) ->
          role.can(that, actions, subject, row, (rule) ->
            callback(rule)
          )
        , (rule) ->
          RestEndpoints.log that.username, (if !rule then "cannot" else "can"), action_names, "from/to model", subject, (if rule then rule else "")
          cb(rule) if cb
        )

      else
        RestEndpoints.log that.username, "cannot", action_names, "from/to model", subject, "no roles assigned"
        cb(null) if cb
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
    safejson.parse(@data)[key]

  setData: (key, value) ->
    if !@data?
      @data = '{}'
    j = safejson.parse(@data)
    j[key] = value
    that = @
    safejson.stringify(j, (err, json) ->
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

    if @$cachedModules and @$cachedModules.length
      cb(@$cachedModules) if cb
    else
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

        mongoose.model('Share').find({ $and: [{'users.user': that.id}, {'users.state': 'active'}] }).populate('module').exec((err, shares) ->
          if shares
            for s in shares
              if plain
                r.push(s.module)
              else
                mm = s.module.toObject()
                VCModule.make(mm)
                r.push(mm)

          that.$cachedModules = (if r.length then r else null)

          cb(r) if cb
        )
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

  getModel: (name, cb) ->
    console.log "user.getModel()", name
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

  loadModel: (name, schema, cb) ->
    console.log "user.loadModel()", name
    @getModel(name, (m, plan, c, prefix) ->
      if !m or !_.isEqual(m.schema, schema)
        delete c.models[prefix + name]
        m = c.model(prefix + name, schema)
      cb(m, plan, c, prefix) if cb
    )

  unloadModel: (name, cb) ->
    console.log "user.unloadModel()", name
    @getModel(name, (m, plan, c, prefix) ->
      if m
        delete c.models[prefix + name]
      cb(m != null) if cb
    )

  unloadAllModels: (cb) ->
    that = @
    console.log "user.unloadAllModels()"
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

  model: (name, cb) ->
    that = @
    console.log "user.model()", name
    @getModel(name, (m, plan, c, prefix) ->
      if !m
        dire = require('dire')

        try
          generatedModules = dire(that.modulesPath() + '/', false, '.js')
        catch e
          console.log "dire error", e

        that.modules((modules) ->
          for mm in modules
            for s in mm.schemas()

              schema = generatedModules[mm.sanitizedId()][prefix + s.varName()]
              if schema
                m = mm
                break
            if schema
              break

          if m
            that.loadModel(name, schema, (m, plan, c, prefix) ->
              cb(m) if cb
            )
          else
            cb(null) if cb
        )
      else
        cb(m) if cb
    )

)

module.exports = mongoose.model('User', UserSchema)

setTimeout( ->
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
          console.log err
#        RestEndpoints.log "Created default admin user", err, user
      )
  )
, 100)
