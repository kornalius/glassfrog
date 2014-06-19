app = require("./app")
mongoose = require("./app").mongoose
RestEndpoints = require('mongoose-rest-endpoints')

#RestEndpoints.log.verbose(process.env.NODE_ENV == 'development')
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
#            console.log req.query[k]
#        next()

      endpoint.tap('pre_filter', '*', (req, query, next) ->
        for k of query
          for kk of query[k]
            if kk == '$in' and query[k][kk] instanceof Array and query[k][kk].length == 1 and typeof query[k][kk][0] == 'string'
              query[k][kk] = query[k][kk][0].split(',')
        next(query)
      )

      endpoint.tap('pre_response', '*', (req, query, next) ->
        that = @
        if req.method.toUpperCase() == 'GET' and query instanceof Array
          that.$$modelClass.count((err, count) ->
            r = []
            for q in query
              if !hasOwner(that) or isOwned(that, q, req.user)
                r.push(q)
            config = that.$$getPaginationConfig(req)
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
        return endpoint.$$modelClass.schema.owner_id?

      isOwned = (endpoint, doc, user) ->
        return hasOwner(endpoint) and doc.owner_id? and doc.owner_id.toString() != user._id.toString()

      endpoint.tap('post_retrieve', '*', (req, doc, next) ->
        actions = []
        mt = req.method.toUpperCase()
        if mt == 'PUT'
          actions.push('update')
        else if mt == 'DELETE'
          actions.push('delete')
        that = @
        console.log "post_retrieve", actions, that
        req.user.can(actions, that.$$modelClass.schema.name, (rule) ->
          console.log "post_retrieve", rule, isOwned(that, doc, req.user)
          if !rule or !isOwned(that, doc, req.user)
            error = new Error('Unauthorized')
            error.code = 403
            next(error)
          else
            next(doc)
        )
      )

      endpoint.tap('pre_save', '*', (req, doc, next) ->
        actions = []
        mt = req.method.toUpperCase()
        if mt == 'POST'
          actions.push('create')
        else if mt == 'PUT'
          actions.push('update')
        that = @
        console.log "that.$$modelClass.schema", that.$$modelClass.schema
        req.user.can(actions, that.$$modelClass.schema.name, (rule) ->
          if !rule
            error = new Error('Unauthorized')
            error.code = 403
            next(error)
          else
            if hasOwner(that) and !isOwned(that, doc, req.user)
              doc.owner_id = req.user._id
            next(doc)
        )
      )

      canSendField = (name, f) ->
        return !f.options.private and (!name.startsWith('_') or name == '_id')

      endpoint.addMiddleware('*', (req, res, next) ->
        if req._parsedUrl
          url = req._parsedUrl
          p = url.pathname.split('/')
          if p.length > 2 and p[1] == 'api'

            model = p[2].toProperCase()

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

    #          console.log action, model, req.params.id

              if action == 'schema'
                app.model(model, req, (m) ->
                  if m
                    req.user.can('schema', model, null, (ok) ->
                      if !ok
                        return res.send(403)
                      else
                        fields = {}
                        m.schema.eachPath((name, f) ->
                          if canSendField(name, f)
                            fields[name] = f
                        )
                        return res.send(fields)
                    )
                  else
                    return res.send(500, 'Schema not found')
                )

              else if action == 'defaults'
                app.model(model, req, (m) ->
                  if m
                    req.user.can('defaults', model, null, (ok) ->
                      if !ok
                        return res.send(403)
                      else
                        fields = {}

                        o = new m()
                        fields._id = o._id

                        m.schema.eachPath((name, f) ->
                          if canSendField(name, f) and o[name]?
                            fields[name] = o[name]
                        )
                        console.log fields
                        return res.send(fields)
                    )
                  else
                    return res.send(500, 'Schema not found')
                )

              else if req.params.id?
                app.model(model, req, (m) ->
                  if m
                    m.findById(req.params.id, (err, row) ->
                      req.user.can(action, model, row, (ok) ->
                        if !ok
                          return res.send(403)
                        else
                          return next()
                      )
                    )
                  else
                    return res.send(403)
                )

              else
                req.user.can(action, model, null, (ok) ->
                  if !ok
                    return res.send(403)
                  else
                    return next()
                )

              return

        return next()
      )

      endpoint.register(app.app)
  )

exports.register = register
