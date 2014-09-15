mongoose = require("mongoose")
timestamps = require('mongoose-time')()
async = require('async')

RoleSchema = mongoose.Schema(
  name:
    type: String
    unique: true
    trim: true
    required: true
    label: 'Name'

  inherits:
    type: [
      type: mongoose.SchemaTypes.ObjectId
      ref: 'Role'
    ]
    default: []
    label: 'Parent roles'

  rules:
    type: [
      subject:
        type: String
        required: true
        label: 'Rule subject'

      action:  # *, read, write, create, delete, schema, defaults, share
        type: String
        label: 'Allowed rule action'

      owned:
        type: Boolean
        label: 'Only if own the record'
    ]
    label: 'Rules'

,
  label: 'Roles'
)

RoleSchema.plugin(timestamps)

RoleSchema.method(

  allRules: (subject, actions, cb) ->
    if typeof actions is 'string'
      actions = actions.split(',')
    that = @
    r = []
    @allParentRoles((roles) ->
      if roles
        roles.push(that)
        for role in roles
          for rule in role.rules
            if that.ruleMatch(rule, subject, actions)
              r.push(rule)
      cb(r) if cb
    )

  allParentRoles: (cb) ->
    r = []
    @populate('inherits', (err, rl) ->
      async.eachSeries(rl.inherits, (role, callback) ->
        role.allParentRoles((inherits) ->
          r = r.concat(inherits)
          callback()
        )
      , (err) ->
        cb(r) if cb
      )
    )

  hasParentRole: (name, cb) ->
    name = name.toLowercase()
    @allParentRoles((inherits) ->
      for role in inherits
        if role.name == name
          cb(role) if cb
          return
      cb(null) if cb
    )

  addParentRole: (parents, cb) ->
    that = @
    async.eachSeries(parents, (p, callback) ->
      that.hasParentRole(p, (role) ->
        if !role
          that.inherits.push(role._id)
        callback()
      )
    , (err) ->
      that.save()
      cb() if cb
    )

  removeParentRole: (parents, cb) ->
    that = @
    async.eachSeries(parents, (p, callback) ->
      that.hasParentRole(p, (role) ->
        if role
          that.inherits.remove(role)
        callback()
      )
    , (err)
      that.save()
      cb() if cb
    )

  hasRule: (subject, actions, cb) ->
    @allRules(subject, actions, (rules) ->
      cb(rules != null) if cb
    )

  addRule: (subject, actions, owned, cb) ->
    if typeof actions is 'string'
      actions = actions.split(',')
    for a in actions
      ok = false
      for rule in @rules
        if @ruleMatch(rule, subject, [a])
          ok = true
          break
      if !ok
        @rules.push({ action: a.toLowerCase(), subject: subject.toLowerCase(), owned: owned })

    @save()

    cb() if cb

  addRules: (rules, cb) ->
    that = @
    async.eachSeries(rules, (r, callback) ->
      that.addRule(r.subject, r.action, r.owned, () ->
        callback()
      )
    , (err) ->
      cb() if cb
    )

  removeRule: (subject, actions, cb) ->
    r = []
    for rule in @rules
      if @ruleMatch(rule, subject, actions)
        r.push(rule)

    for rule in r
      @rules.remove(rule)

    @save()

    cb() if cb

  removeRules: (rules, cb) ->
    that = @
    async.eachSeries(rules, (r, callback) ->
      that.removeRule(r.subject, r.action, () ->
        callback()
      )
    , (err) ->
      cb() if cb
    )

  ruleMatch: (rule, subject, actions) ->
    if typeof actions is 'string'
      actions = actions.split(',')
    if rule.subject == subject.toLowerCase()
      if actions
        for a in actions
          if a == '*' or a.toLowerCase() == rule.action
            return true
      else
        return true

    return false

  can: (user, actions, subject, row, cb) ->
    that = @
    @allRules(subject, actions, (rules) ->
      if rules
        rule = that.canWithRules(user, rules, actions, subject, row)
        cb(rule) if cb
      else
        cb(null) if cb
    )

  canWithRules: (user, rules, actions, subject, row) ->
    id = user._id.toString()
    for rule in rules
      if (!row or !user) or ((rule.owned and row.owner_id? and row.owner_id.toString() == id) or rule == 'admin')
        return rule
    return null

)

RoleSchema.static(

)

module.exports = mongoose.model('Role', RoleSchema)

setTimeout( ->
  Role = mongoose.model('Role')

  Role.remove({}, (err) ->

    Role.create(
      name: 'admin'
    , (err, adminRole) ->
#      console.log "create admin role", err, adminRole

#      Make first user admin
      mongoose.model('User').findOne({}, (err, user) ->
        if user
          user.roles = [adminRole._id]
          user.save()
      )

#      Create default user role and rules
      Role.findOne({ name: 'user' }, (err, userRole) ->
        if !userRole
          Role.create({ name: 'user' }, (err, userRole) ->
            userRole.addRules([
                subject: 'component'
                action: 'read'
                owned: false
              ,
                subject: 'invoice'
                action: 'read'
                owned: true
              ,
                subject: 'log'
                action: 'read'
                owned: true
              ,
                subject: 'node'
                action: 'read,write,create,delete'
                owned: true
              ,
                subject: 'share'
                action: 'read,write,create,delete'
                owned: true
              ,
                subject: 'user'
                action: 'read'
                owned: true
              ], () ->
            )
          )
      )
    )
  )

, 2000)
