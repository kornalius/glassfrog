app = require("./app")
mongoose = require("mongoose")
RestEndpoints = require('mongoose-rest-endpoints')
url = require('url')
async = require('async')
util = require('util')

require('simple-errors')

RestEndpoints.log.verbose(process.env.NODE_ENV == 'development')
#RestEndpoints.log.verbose(true)

hasOwner = (endpoint) ->
  return endpoint.$modelClass.owner_id?

isOwned = (endpoint, doc, user) ->
  return hasOwner(endpoint) and doc.owner_id? and doc.owner_id.toString() != user._id.toString()

paginate = (endpoint, req, rows, cb) ->
  endpoint.$modelClass.count((err, count) ->
    if !err
      repr = new RestEndpoints.request(endpoint)
      config = repr.$$getPaginationConfig(req)

      limit = parseInt(config.perPage, 0)
      skip = Number(config.page * config.perPage || 0)
      pages = Math.round(count / config.perPage)
      if pages < 1
        pages = 1
      page = config.page

      rows.splice(0, 0,
        total: count
        displayCount: rows.length
        perPage: limit
        page: page
        pages: pages
        firstPage: 1
        prevPage: Math.max(1, page - 1)
        nextPage: Math.min(pages, page + 1)
        lastPage: Math.max(1, pages)
        limit: limit
        skip: skip
        first: 0
        prev: Math.max(0, skip - limit)
        next: Math.max(0, Math.min(count - limit, limit + skip))
        last: Math.max(0, count - limit)
      )

      cb(rows) if cb
    else
      cb([
        total: 0
        displayCount: 0
        perPage: 1
        page: 1
        pages: 1
        firstPage: 1
        prevPage: 1
        nextPage: 1
        lastPage: 1
        limit: 0
        skip: 0
        first: 0
        prev: 0
        next: 0
        last: 0
      ]) if cb
  )

filterHiddenFields = (endpoint, req, row) ->
  hidden = [].concat(endpoint.options._fields.hidden)

  if req.query.select?
    s = req.query.select

    if !(s instanceof Array)
      s = s.split(' ')

    for k of row
      if s.indexOf(k) == -1
        hidden.push(k)

  for k of row
    if hidden.indexOf(k) != -1
      delete row[k]

canSendField = (endpoint, name, f) ->
  return (f and !f.options.private) or (!name.startsWith('_') or name == '_id' or name == '_order')

multiPathSet = (object, path, value) ->
  nw = object
  paths = path.split('.')
  while paths.length > 1
    n = paths.shift()
    if !nw[n]
      nw[n] = {}
    nw = nw[n]
  nw[paths.shift()] = value

register = () ->

  endpoint = new RestEndpoints.endpoint('/api/:model', null,
    pagination:
      perPage: 10
      sortField: '_id'
  )

  endpoint.tap('pre_filter', '*', (req, query, next) ->
    for k of query
      for kk of query[k]
        if kk == '$in' and query[k][kk] instanceof Array and query[k][kk].length == 1 and typeof query[k][kk][0] == 'string'
          query[k][kk] = query[k][kk][0].split(',')
    next(query)
  )

  endpoint.addMiddleware('*', (req, res, next) ->

    console.log util.inspect(endpoint.$modelClass, {colors: true, depth: 0, showHidden: true})

    if !app.validUser(req)
      console.trace "403"
      next(new Error(403))
      return

    model = null
    if req.params.model?
      model = req.params.model.toProperCase()

    if !model
      console.trace "404"
      next(new Error(404))
      return

    mt = req.method.toUpperCase()

    mn = model.toLowerCase()
    if mt == 'POST' or mt == 'PUT' or mt == 'DELETE'
      if mn == 'component' or mn == 'plan' or mn == 'log' or mn == 'invoice' or mn == 'role' or mn == 'activate'
        console.trace "403"
        next(new Error(403))
        return

    req.user.model(model, (m) ->
      if m
        endpoint.$modelClass = m

        hide = []
        show = []
        readOnly = []
        populate = []
        m.schema.eachPath((name, field) ->
          if field.options.private
            hide.push(name)
          else
            show.push(name)

          if field.options.readOnly
            readOnly.push(name)

          if field.options.populate
            populate.push(name)
        )
        for k of m.schema.virtuals
          v = m.schema.virtuals[k]
          show.push(v.path)

        endpoint.options._fields = {}
        endpoint.options._fields.hidden = hide
        endpoint.options._fields.visible = show
        endpoint.options._fields.populate = populate
        endpoint.options._fields.readOnly = readOnly

        q = []
        for s in show
          q.push(s)
          q.push('$gt_' + s)
          q.push('$lt_' + s)
          q.push('$gte_' + s)
          q.push('$lte_' + s)
          q.push('$ne_' + s)
          q.push('$in_' + s)
          q.push('$regex_' + s)
          q.push('$regexi_' + s)
        endpoint.allowQueryParam(q)
        #  endpoint.allowBulkPost()

        if mt == 'GET'
          action = 'read'
          action_name = 'read'
          if req.params.action?
            if req.params.action == 'schema'
              action = 'schema'
              action_name = "read schema"
              delete req.params.id
            else if req.params.action == 'defaults'
              action = 'defaults'
              action_name = "read default values"
              delete req.params.id
        else if mt == 'PUT'
          action = 'write'
          action_name = 'write'
        else if mt == 'POST'
          action = 'create'
          action_name = 'create'
        else if mt == 'DELETE'
          action = 'delete'
          action_name = 'delete'

        if req.params.id?
          RestEndpoints.log "endpoints.middleware()", action_name, "from/to model", endpoint.$modelClass.modelName, "row with id", req.params.id
        else
          RestEndpoints.log "endpoints.middleware()", action_name, "from/to model", endpoint.$modelClass.modelName, "all rows"

        if action == 'schema' or action == 'defaults'
          req.user.can(action, endpoint.$modelClass.modelName, null, (rule) ->
            if !rule
              console.trace "403"
              next(new Error(403))
              return
            else
              fields = {}

              if action == 'defaults'
                o = new endpoint.$modelClass()
                fields._id = o._id
                endpoint.$modelClass.schema.eachPath((name, f) ->
                  if canSendField(endpoint, name, f)
                    fields[name] = o[name]
                )
                for k of endpoint.$modelClass.schema.virtuals
                  v = endpoint.$modelClass.schema.virtuals[k]
                  if canSendField(endpoint, v.path, null)
                    multiPathSet(fields, v.path, o[v.path])

              else
                endpoint.$modelClass.schema.eachPath((name, f) ->
                  if canSendField(endpoint, name, f)
                    fields[name] = f
                )
                for k of endpoint.$modelClass.schema.virtuals
                  v = endpoint.$modelClass.schema.virtuals[k]
                  if canSendField(endpoint, v.path, null)
                    multiPathSet(fields, v.path, o[v.path])

              res.send(fields)
              console.trace action, fields
              next(fields)
              return
          )

        next()

      else
        console.trace "403"
        next(new Error(403))
    )

  )


  endpoint.tap('pre_response', '*', (req, json, next) ->
    that = @$$endpoint

    console.log util.inspect(that.$modelClass, {colors: true, depth: 0, showHidden: true})

    if json instanceof Array
      rows = []
      rules = {}
      req.user.allRoles((roles) ->
        if roles

          # check if admin
          if req.user.hasAdmin(roles)
            for row in json
              filterHiddenFields(that, req, row)

            paginate(that, req, json, (results) ->
              next(results)
            )
            return

          async.eachSeries(json, (row, rowCallback) ->

            console.log row

            async.eachSeries(roles, (role, roleCallback) ->

              console.log role

              if rules[role.name]?
                roleCallback(role.canWithRules(req.user, rules[role.name], 'read', that.$modelClass.modelName, row))
              else
                role.allRules(that.$modelClass.modelName, 'read', (_rules) ->
                  if !_rules
                    _rules = []
                  rules[role.name] = _rules
                  roleCallback(role.canWithRules(req.user, rules[role.name], 'read', that.$modelClass.modelName, row))
                )
            , (rule) ->
              if rule
                filterHiddenFields(that, req, row)
                rows.push(row)
              rowCallback()
            )

          , (err) ->
            console.log rows, err

            paginate(that, req, rows, (results) ->
              next(results)
            )
          )

        else
          console.trace "403"
          next(new Error(403))
      )

    else
      filterHiddenFields(that, req, json)
      req.user.can('read', that.$modelClass.modelName, json, (rule) ->
        if rule
          next(json)
        else
          console.trace "403"
          next(new Error(403))
      )
  )


  endpoint.tap('post_retrieve', '*', (req, doc, next) ->
    that = @$$endpoint

    console.log util.inspect(that.$modelClass, {colors: true, depth: 0, showHidden: true})

    action = null
    mt = req.method.toUpperCase()
    if mt == 'GET'
      action = 'read'
    else if mt == 'PUT'
      action = 'write'
    else if mt == 'POST'
      action = 'create'
    else if mt == 'DELETE'
      action = 'delete'

    if req.params.id?
      RestEndpoints.log "endpoints.post_retrieve", that.$modelClass.modelName, req.params.id
    else
      RestEndpoints.log "endpoints.post_retrieve", that.$modelClass.modelName

    req.user.can(action, that.$modelClass.modelName, doc, (rule) ->

      RestEndpoints.log "endpoints.post_retrieve", rule, that.$modelClass.modelName, req.params.id

      if !rule
#        if !rule or (!isOwned(that, doc, req.user) and rule != 'admin')
        next(new Error(403))
      else
        next(doc)
    )
  )


  endpoint.tap('pre_save', '*', (req, doc, next) ->
    that = @$$endpoint

    console.log util.inspect(that.$modelClass, {colors: true, depth: 0, showHidden: true})

    RestEndpoints.log "endpoints.pre_save", isOwned(that, doc, req.user), that.$modelClass.modelName

    action = null
    mt = req.method.toUpperCase()
    if mt == 'GET'
      action = 'read'
    else if mt == 'PUT'
      action = 'write'
    else if mt == 'POST'
      action = 'create'
    else if mt == 'DELETE'
      action = 'delete'

    req.user.can(action, that.$modelClass.modelName, doc, (rule) ->

      RestEndpoints.log "endpoints.pre_save", rule, isOwned(that, doc, req.user), that.$modelClass.modelName

      if !rule
        next(new Error(403))
      else

        for k of that.options._fields.readOnly
          delete doc[k]

        for k of that.$modelClass.schema.virtuals
          delete doc[k]

        console.log "<<<", doc, ">>>"

        if hasOwner(that) and !isOwned(that, doc, req.user)
          doc.owner_id = req.user._id

        if that.$modelClass.db == mongoose.connection and that.$modelClass.modelName == 'Module'
          require('./models/module').rebuildModules(req.user, () ->
            next(doc)
          )
          return

        next(doc)
    )
  )


  endpoint.register(app.app)


exports.register = register
