app = require("./app")
mongoose = require("./app").mongoose
RestEndpoints = require('mongoose-rest-endpoints')
require('simple-errors')

RestEndpoints.log.verbose(process.env.NODE_ENV == 'development')
#RestEndpoints.log.verbose(true)

register = (k, req, show, hide, readOnly, populate) ->
  app.model(k, req, (m) ->
    if m
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

      endpoint = new RestEndpoints.endpoint('/api/{0}'.format(k.toLowerCase()), k,
        pagination:
          perPage: 10
          sortField: '_id'
        _fields:
          hidden: hide
          visible: show
          populate: populate
          readOnly: readOnly
      )

      endpoint.populate(populate)
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

#      endpoint.addMiddleware 'list', (req, res, next) ->
#        for k of req.query
#          if k.startsWith('$in_') and !(req.query[k] instanceof Array)
#            req.query[k] = req.query[k].split(',')
#            log req.query[k]
#        next()

      endpoint.tap('pre_filter', '*', (req, query, next) ->
        that = endpoint

        for k of query
          for kk of query[k]
            if kk == '$in' and query[k][kk] instanceof Array and query[k][kk].length == 1 and typeof query[k][kk][0] == 'string'
              query[k][kk] = query[k][kk][0].split(',')
        next(query)
      )

      endpoint.tap('pre_response', '*', (req, query, next) ->
        that = endpoint

        if req.method.toUpperCase() == 'GET' and query instanceof Array
          that.$modelClass.count((err, count) ->
            r = []
            for q in query
              if !hasOwner(that) or isOwned(that, q, req.user)
                r.push(q)
            epr = new RestEndpoints.request(that)
            config = epr.$$getPaginationConfig(req)
            limit = parseInt(config.perPage, 0)
            skip = Number(config.page * config.perPage || 0)
            pages = Math.round(count / config.perPage)
            page = config.page
            next([
              total: count
              displayCount: query.length
              perPage: limit
              page: page
              pages: pages
              firstPage: 1
              prevPage: Math.max(0, page - 1)
              nextPage: Math.min(pages, page + 1)
              lastPage: Math.max(0, pages)
              limit: limit
              skip: skip
              first: 0
              prev: Math.max(0, skip - limit)
              next: Math.min(count - limit, limit + skip)
              last: Math.max(0, count - limit)
            ].concat(r))
          )
        else
          next(query)
      )

      hasOwner = (endpoint) ->
        return endpoint.$modelClass.owner_id?

      isOwned = (endpoint, doc, user) ->
        return hasOwner(endpoint) and doc.owner_id? and doc.owner_id.toString() != user._id.toString()

      endpoint.tap('post_retrieve', '*', (req, doc, next) ->
        that = endpoint

        actions = []
        mt = req.method.toUpperCase()
        if mt == 'PUT'
          actions.push('update')
        else if mt == 'DELETE'
          actions.push('delete')

#        log "endpoints.post_retrieve", that.modelId
        that.$modelClass.findById(req.params.id, (err, row) ->
          if row
            req.user.can(actions, that.modelId, row, (rule) ->
              console.info "endpoints.post_retrieve", rule, doc, row, isOwned(that, doc, req.user), that.modelId
              if !rule or (!isOwned(that, doc, req.user) and rule != 'admin')
#              if !rule or (!isOwned(that, doc, req.user))
                next(Error.http(403, null, {method: req.method, model: that.modelId, id: doc._id}))
              else
                next(doc)
            )
        )
      )

      endpoint.tap('pre_save', '*', (req, doc, next) ->
        that = endpoint

        actions = []
        mt = req.method.toUpperCase()
        if mt == 'POST'
          actions.push('create')
        else if mt == 'PUT'
          actions.push('update')

#        log "endpoints.pre_save", that.modelId
        req.user.can(actions, that.modelId, doc, (rule) ->
          console.info "endpoints.pre_save", rule, isOwned(that, doc, req.user), that.modelId
          if !rule
            next(Error.http(403, null, {method: req.method, model: that.modelId, id: doc._id}))
          else
            if hasOwner(that) and !isOwned(that, doc, req.user)
              doc.owner_id = req.user._id
            next(doc)
        )
      )

      canSendField = (name, f) ->
        return !f.options.private and (!name.startsWith('_') or name == '_id' or name == '_order')

      endpoint.addMiddleware('*', (req, res, next) ->
        that = endpoint

        if req._parsedUrl
          url = req._parsedUrl
          p = url.pathname.split('/')
          if p.length > 1 and p[1] == 'api'

            if req.isAuthenticated()
              mt = req.method.toUpperCase()
              if mt == 'GET'
                action = 'read'
                if p.length == 4 and p[3].toLowerCase() == 'schema'
                  action = 'schema'
                else if p.length == 4 and p[3].toLowerCase() == 'defaults'
                  action = 'defaults'
              else if mt == 'PUT'
                action = 'write'
              else if mt == 'POST'
                action = 'create'
              else if mt == 'DELETE'
                action = 'delete'

              action_name = action
              if action == 'schema'
                action_name = "read schema"
              else if action == 'defaults'
                action_name = "read default values"

              if req.params.id?
                console.info "endpoints.middleware()", action_name, "from/to model", that.modelId, "row with id", req.params.id
              else
                console.info "endpoints.middleware()", action_name, "from/to model", that.modelId, "all rows"

              if action == 'schema'
                req.user.can('schema', that.modelId, null, (rule) ->
                  if !rule
                    next(Error.http(403, {method: req.method, model: that.modelId, id: req.params.id}))
                  else
                    fields = {}
                    that.$modelClass.schema.eachPath((name, f) ->
                      if canSendField(name, f)
                        fields[name] = f
                    )

                    console.info "schema", fields

                    res.send(fields)

                    next()
                )

              else if action == 'defaults'
                req.user.can('defaults', that.modelId, null, (rule) ->
                  if !rule
                    next(Error.http(403, {method: req.method, model: that.modelId, id: req.params.id}))
                  else
                    fields = {}

                    o = new m()
                    fields._id = o._id

                    that.$modelClass.schema.eachPath((name, f) ->
                      if canSendField(name, f) and o[name]?
                        fields[name] = o[name]
                    )

                    console.info "default values", fields

                    res.send(fields)

                    next(fields)
                )

              else if req.params.id?
                that.$modelClass.findById(req.params.id, (err, row) ->
                  req.user.can(action, that.modelId, row, (rule) ->
                    if !rule
                      next(Error.http(403, {method: req.method, model: that.modelId, id: req.params.id}))
                    else
                      next()
                  )
                )

              else
                req.user.can(action, that.modelId, null, (rule) ->
                  if !rule
                    next(Error.http(403, {method: req.method, model: that.modelId, id: req.params.id}))
                  else
                    next()
                )

              return null

            else

              next(Error.http(403, {method: req.method, model: that.modelId, id: req.params.id}))

      )

      endpoint.register(app.app)
  )

exports.register = register
