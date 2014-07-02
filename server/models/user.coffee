app = require("../app")
mongoose = require("../app").mongoose
locking = require('mongoose-account-locking')
timestamps = require('mongoose-time')()
payment = require('../mongoose_plugins/mongoose-payment')
async = require('async')
bcrypt = require('bcrypt')
endpoints = require('../endpoints')
safejson = require('safejson')

UserSchema = mongoose.Schema(
  username:
    type: String
    unique: true
    index: true
    trim: true
    required: true
    label: 'Username'

  password:
    type: String
    trim: true
    required: true
    label: 'Password'
    private: true
    readOnly: true

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

  name:
    first:
      type: String
      required: true
      trim: true
      label: 'First Name'
      inline: true

    middle:
      type: String
      trim: true
      label: 'Middle Name'
      inline: true

    last:
      type: String
      required: true
      trim: true
      label: 'Last Name'
      inline: true

  address:
    type: String
    label: 'Address'

  city:
    type: String
    trim: true
    label: 'City'

  state:
    type: String
    trim: true
    label: 'State'

  country:
    type: String
    trim: true
    label: 'Country'

  zip:
    type: String
    trim: true
    label: 'Zip or Postal Code'

  tel:
    type: String
    trim: true
    label: 'Telephone'

  fax:
    type: String
    trim: true
    label: 'Fax'

  picture:
    type: Buffer
    label: 'Avatar'

  plan:
    type: mongoose.Schema.ObjectId
    ref: 'Plan'
    label: 'Payment plan'
    readOnly: true
    populate: true

  gender:
    type: String
    enum: ['', 'M', 'F']
    default: ''
    label: 'Gender'

  timezone:
    type: Number
    default: 0
    label: 'Timezone'

  locale:
    type: String
    default: 'en_us'
    label: 'Locale'

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

UserSchema.plugin(timestamps)
UserSchema.plugin(locking,
  maxLoginAttempts = 5
  lockTime = 2 * 60 * 60 * 1000
  username = 'username'
  password = 'password'
)
UserSchema.plugin(payment)

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

UserSchema.virtual('name.full').get( ->
  if @name.middle?
    "{0} {1} {2}".format(@name.first, @name.middle, @name.last)
  else
    "{0} {1}".format(@name.first, @name.last)
)

UserSchema.virtual('name.full').set((name) ->
  split = name.split(' ')
  @name.first = split[0]
  @name.last = split[1]
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
    name = name.toLowerCase()
    @allRoles((roles) ->
      for role in roles
        if role.name == name
          cb(role) if cb
          return
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
    @isAdmin((ok) ->
      if ok
        cb(true) if cb
        return
      else
        that.allRoles((roles) ->
          for role in roles
            role.can(that, actions, subject, row, (ok) ->
              if ok
                cb(true) if cb
                return
            )
          cb(false) if cb
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

#  generate: (nodes, cb) ->
#    s = ""
#    errors = []
#    async.eachSeries(nodes, (n, callback) ->
#      ok = true
#      name = n.name.toLowerCase()
#      for m in mongoose.models
#        if m.name.toLowerCase() == name
#          ok = false
#      if !ok
#        errors = new Error(n.name + ' is a reserved schema name')
#      if ok and n.component?
#        n.component.getServerCode((sc) ->
#          if sc
#            sc = app.safeEval(sc, errors)
#            if sc and sc.generate
#              s += sc.generate.call(n)
#          callback()
#        )
#      else
#        callback()
#    , (err) ->
#      cb(s, errors) if cb
#    )
#
#  generateAllSchemas: (cb) ->
#    errors = []
#
#    @getConnection((plan, c, prefix) ->
#      schemas = @getSchemas()
#      async.eachSeries(schemas, (n, callback) ->
#        @generate([n], (schema, err) ->
#          if err
#            errors.concat(err)
#          if schema?
#            m = c.model(prefix + n.name, JSON.parse(schema))
#            if m
#              endpoints.register(name)
#          callback()
#        )
#      , (err) ->
#        if err
#          errors.push(err)
#        cb(schemas, errors) if cb
#      )
#    )

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
