mongoose = require("mongoose")
async = require('async')

module.exports = ((schema, options) ->

  if options and options.path?
    path = options.path + '.'
  else
    path = ''

  roles = path + 'roles'

  schema.add(
    roles: [
      type: mongoose.Schema.Types.ObjectId
      ref: 'Role'
      label: 'Roles'
      populate: true
      private: true
      readOnly: true
    ]
  , path)

  schema.method(

    allRoles: (cb) ->
      results = []
      @populate(roles, (err, doc) ->
        async.eachSeries(doc.get(roles), (role, callback) ->
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

    $all_roles: (req, res, cb) ->
      @allRoles(cb)

    hasRole: (name, cb) ->
      name = name.toLowerCase()
      @allRoles((roles) ->
        if roles
          for role in roles
            if role.name == name
              console.log "Role {blue}", name, "{reset} available!"
              cb(role) if cb
              return

        cb(null) if cb
      )

    $has_role: (req, res, cb) ->
      @allRoles(req.params.name, cb)

    addRole: (name, cb) ->
      that = @
      @hasRole(name, (role) ->
        if !role
          mongoose.model('Role').findOne({ name: name.toLowerCase() }, (err, role) ->
            that.get(roles).push(role._id)
            that.save()
            cb(role) if cb
          )
        cb(null) if cb
      )

    removeRole: (name, cb) ->
      that = @
      results = []
      name = name.toLowerCase()
      @populate(roles, (err, r) ->
        if r
          for role in r
            if role.name == name
              results.push(role)
          for role in results
            that.get(roles).remove(role)
          that.save()

        cb() if cb
      )

    allRules: (actions, subject, cb) ->
      if type(actions) is 'string'
        actions = actions.split(',')
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

    $all_rules: (req, res, cb) ->
      @allRules(req.params.actions, req.params.subject, cb)

    hasRule: (actions, subject, cb) ->
      @allRules(subject, actions, (rules) ->
        cb(rules != null) if cb
      )

    $has_rule: (req, res, cb) ->
      @allRules(req.params.actions, req.params.subject, cb)

    hasAdmin: (roles) ->
      for role in roles
        if role.name == 'admin'
          return true
      return false

    can: (actions, subject, rows, cb) ->
      that = @

      if type(actions) is 'string'
        actions = actions.split(',')

      action_names = []
      for action in actions
        if action == 'schema'
          action_names.push("read schema")
        else if action == 'defaults'
          action_names.push("read default values")
        else
          action_names.push(action)
      action_names = action_names.join(' or ')

      console.log "can {cyan}" + action_names + "{reset} from/to model {magenta}" + subject + "{reset}?"

      that.hasRole('admin', (isAdmin) ->
        if isAdmin
          cb('admin') if cb
        else
          that.allRules(subject, actions, (rules) ->
            if rules
              rule = mongoose.model('Role').canWithRules(that, rules, rows)
            else
              rule = null
            console.log (if !rule then "cannot" else "can") + " {cyan}" + action_names + " {reset}from/to model {magenta}" + subject + "{reset} {blue}" +  (if rule then rule else "")
            cb(rule) if cb
          )
      )

    $can: (req, res, cb) ->
      @can(req.params.actions, req.params.subject, cb)

    isAdmin: (cb) ->
      @hasRole('admin', cb)
  )
)
