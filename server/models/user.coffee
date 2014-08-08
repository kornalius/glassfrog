app = require("../app")
mongoose = require("mongoose")
locking = require('mongoose-account-locking')
timestamps = require('mongoose-time')()
async = require('async')
bcrypt = require('bcrypt')
endpoints = require('../endpoints')
safejson = require('safejson')

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
        readOnly: true

      password:
        type: String
        label: 'Connection password'
        readOnly: true
        private: true

    label: 'MongoDB connection'
    private: true
    readOnly: true
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
  @isActive()
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
    @can(['write'], model, null, (ok) ->
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
            console.log that.username, "has role", name
            cb(role) if cb
            return
      console.log that.username, "does not have role", name
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
          return
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

  can: (actions, subject, row, cb) ->
    that = @

    if row?
      console.log "can", that.username, actions, "from/to model", subject, "with data", row, "?"
    else
      console.log "can", that.username, actions, "from/to model", subject, "?"

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

    @isAdmin((adminRole) ->
      if adminRole
        console.log that.username, "can", action_names, "from/to model", subject
        cb('admin') if cb
      else
        that.allRoles((roles) ->
          if roles
            r = null
            async.eachSeries(roles, (role, callback) ->
              if !r and role
                role.can(that, actions, subject, row, (rule) ->
                  if rule
                    r = rule
                  callback()
                )
              else
                callback()
            , (err) ->
              console.log that.username, "cannot", action_names, "from/to model", subject
              cb(r) if cb
            )
          else
            console.log that.username, "cannot", action_names, "from/to model", subject
            cb(null) if cb
        )
    )

  isAdmin: (cb) ->
    @hasRole('admin', cb)

  isActive: (cb) ->
    @status == 'active'

  isDisabled: (cb) ->
    @status == 'disabled' or @status == 'locked'

  isLockedOut: (cb) ->
    @status == 'locked'

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

  modules: (cb) ->
    that = @
    r = []
    mongoose.model('Module').find({owner_id: that.id}, (err, modules) ->
      if modules
        for m in modules
          r.push(m)

      mongoose.model('Share').find({ $and: [{'users.user': that.id}, {'users.state': 'active'}] }).populate('module').exec((err, shares) ->
        if shares
          for s in shares
            r.push(s.module)

        cb(r) if cb
      )
    )

  getConnection: (cb) ->
    @populate('plan', (plan) ->
      prefix = ''

      if plan.canCreateConnection() and @connection.name?
        cn = @connection.name
        c = mongoose.connections[cn]
        if !c
          if plan.canHaveOwnDatabase()
            uri = app.mongoUri
            if plan.canUseExternalConnection() and @connection.uri?
              uri = @connection.uri
          c = mongoose.createConnection(uri + cn)

      else
        c = mongoose.connection
        if plan.canUseOwnCollection() and @connection.prefix?
          prefix = @connection.prefix + '_'

      cb(plan, c, prefix) if cb
    )

  model: (name, cb) ->
    @getConnection((plan, c, prefix) ->
      if c
        m = c.model(prefix + name)
      else
        m = null
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

  mongoose.model('User').findOne({ username: adminUser.username }, (err, user) ->
    if !user
      mongoose.model('User').create(adminUser, (err, user) ->
#        console.log "Created default admin user", err, user
      )
  )
, 100)
