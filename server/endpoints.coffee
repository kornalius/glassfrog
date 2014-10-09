_app = require("./app")
app = _app.app
mongoose = require("mongoose")
url = require('url')
async = require('async')
util = require('util')
require('simple-errors')
query = require('humanquery')

MAX_LIMIT = 500

class AccessError extends mongoose.Error
  constructor: (@name, @path) ->
    super('Access denied in model "' + @name + '" at path "' + @path + '"')
    Error.captureStacklog(@, arguments.callee)
    @name = 'AccessError'

processJSON = (o) ->
  if o.toJSON
    j = o.toJSON()
  else
    try
      j = o
    catch e
      j = {}
      console.log e
  return j

__send = (res, data, err, asArray) ->
  s = {status: (if !err then 'ok' else 'error')}
  if err
    if type(err) is 'number'
      err = new Error(err)
    s.err = {code: err.code, message: err.message}

  if asArray
    if type(data) != 'array'
      data = [s, data]
    else if hasPagination(data)
      data[0] = _.extend({}, data[0], s)
    else
      data.splice(0, 0, s)
  else
    if type(data) == 'array' and data.length == 1
      data = data[0]
    data = _.extend({}, data, s)

  res.setHeader('content-type', 'application/json')
#  res.setHeader('X-Total-Count', 0)

  res.json(data)

send = (req, res, options, cb) ->
  results = null
  model = null
  err = null
  asArray = false

  if options
    if type(options) is 'number'
      err = new Error(options)
    else if options instanceof Error
      err = options
    else
      results = options.results
      model = options.model
      err = options.err
      asArray = options.asArray

  if !results
    results = {}

  if model
    if type(results) != 'array'
      results = [results]
    l = []
    user_id = req.user._id.toString()
    async.eachSeries(results, (r, callback) ->
      addExtraFields(user_id, r, model, (ok) ->
        if ok
          l.push(processJSON(r))
        callback()
      )
    , (err) ->
      if !err
        __send(res, l, err, asArray)
        cb(l) if cb
      else
        cb(err) if cb
    )
  else
    __send(res, results, err)
    cb(results) if cb
exports.send = send

populatedPaths = (r, model) ->
  l = []
  paths = _app.modelPaths(model)
  for f in paths
    if f.type == 'ObjectId' and f.ref and r[f] and r[f]._id?
      l.push(f.path)
  return l

virtualPaths = (model) ->
  l = []
  paths = _app.modelPaths(model)
  for f in paths
    if f.type == 'virtual'
      l.push(f.path)
  return l

selectPaths = (model) ->
  l = []
  paths = _app.modelPaths(model)
  for f in paths
    if f.select
      l.push(f.path)
  return l

requiredPaths = (model) ->
  l = []
  paths = _app.modelPaths(model)
  for f in paths
    if f.required
      l.push(f.path)
  return l

populatePaths = (model) ->
  l = []
  paths = _app.modelPaths(model)
  for f in paths
    if f.populate
      l.push(f.path)
  return l

readOnlyPaths = (model) ->
  l = []
  paths = _app.modelPaths(model)
  for f in paths
    if f.readOnly
      l.push(f.path)
  return l

privatePaths = (model) ->
  l = []
  paths = _app.modelPaths(model)
  for f in paths
    if f.private
      l.push(f.path)
  return l

addExtraFields = (user_id, results, model, cb) ->
  if !results
    l = []
  else if type(results) != 'array'
    l = [results]
  else
    l = results
  async.eachSeries(l, (r, rowCallback) ->
    pp = populatedPaths(r, model)
    async.eachSeries(pp, (f, fieldCallback) ->
      addExtraFields(user_id, pp[f], model, ->
        fieldCallback()
      )
    , (err) ->
      if r.extraFields?
        r.extraFields(user_id, ->
          rowCallback()
        )
      else
        rowCallback()
    )
  , (err) ->
    cb(!err) if cb
  )
exports.addExtraFields = addExtraFields

selectFields = (select, model) ->
  l = []
  paths = _app.modelPaths(model)
  for s in select
    if s.length and !s.startsWith('+')
      ok = true
      for k of paths
        if k == s
          ok = false
          break
      if ok
        l.push(s)
  for k of paths
    if paths[k].private
      l.push('-' + k)
  return l

populateFields = (populate, model, req) ->
  l = []
  paths = _app.modelPaths(model)
  for k of paths
    f = paths[k]
    if !f.private and f.type == 'ObjectId' and f.ref and (f.populate or k in populate)
      m = _app.modelSync(f.ref, req)
      if m
        c = { path: k }
        ss = selectFields([], m)
        if ss.length
          c.select = ss.join(' ')
        pp = populateFields([], m, req)
        if pp.length
          c.populate = pp
#        c.options = {}
        l.push(c)
  return l

hasPagination = (data) ->
  if type(data) is 'array' and data.length
    return data[0].__p
  else
    return false

paginate = (model, req, results, cb) ->
  model.count((err, count) ->
    if !results
      results = []

    if type(results) != 'array'
      results = [results]

    if !err
      limit = Math.min(MAX_LIMIT, req.query.l)
      skip = Math.min(MAX_LIMIT, req.query.sk)
      pages = Math.max(Math.ceil(count / limit), 1)
      c = Math.ceil(skip / limit)
      if c == Math.floor(skip / limit)
        c++
      page = Math.min(pages, Math.max(c, 1))
    else
      limit = 1
      skip = 1
      page = 1
      pages = 1

    results.splice(0, 0,
      __p: true
      total: count
      displayCount: results.length
      limit: limit
      skip: skip
      page: page
      pages: pages
      firstPage: 1
      prevPage: Math.max(1, page - 1)
      nextPage: Math.min(pages, page + 1)
      lastPage: Math.max(1, pages)

      first: 0
      prev: Math.max(0, skip - limit)
      next: Math.max(0, Math.min(count - limit, limit + skip))
      last: Math.max(0, count - limit)
    )

    cb(results) if cb
  )


register = () ->
  process_query = (req) ->
    console.log "process_query()", jsonToString(req.query.q)
    if req.query.q
      try
        qo = query.compile(query.parse(req.query.q))
      catch e
        console.log e
      if !qo
        qo = {}
      return qo
    else
      return {}

  process_select = (req, q) ->
    select = selectFields((if req.query.s then req.query.s.split(' ') else []), req.m)
    console.log "process_select()", jsonToString(req.query.s), jsonToString(select)
    req.query.s = select.join(' ')
    if q
      if select.length
        q.select(select.join(' '))
      return q
    else
      return select

  process_populate = (req, q) ->
    populate = populateFields((if req.query.p then req.query.p.split(' ') else []), req.m, req)
    console.log "process_populate()", jsonToString(req.query.p), jsonToString(populate)
    req.query.p = populate
    if q
      if populate.length
        q.populate(populate)
      return q
    else
      return populate

  process_limit = (req, q) ->
    i = 10

    if req.query.l
      try
        i = parseInt(req.query.l, 10)
      catch e
        i = 0
        console.log e

    i = Math.abs(Math.min(MAX_LIMIT, i))

    console.log "process_limit()", i

    req.query.l = i

    if q
      q.limit(i)
      return q
    else
      return i

  process_skip = (req, q) ->
    i = 0

    if req.query.sk
      try
        i = parseInt(req.query.sk, 10)
      catch e
        i = 0
        console.log e

    else if req.query.page
      try
        i = parseInt((req.query.page - 1) * req.query.l, 10)
      catch e
        i = 0
        console.log e

    i = Math.abs(Math.min(MAX_LIMIT, i))

    console.log "process_skip()", i

    req.query.sk = i
    if q
      q.skip(i)
      return q
    else
      return i

  process_sort = (req, q) ->
    console.log "process_sort()", jsonToString(req.query.sort)
    if q
      if req.query.sort
        q.sort(req.query.sort)
      return q
    else
      return req.query.sort

  process_results = (req, res, results, err, cb) ->
    console.log "process_results()"
    send(req, res, {results:results, model:req.m, err:err}, ->
      cb(!err, err) if cb
    )

  app.all('/api/*', (req, res, next) ->
    console.log "app.all()", req.query, req.params
    if !_app.validUser(req)
      send(req, res, 403, ->
        next()
      )
    else
      next()
  )

  checkmodel = (req, res, next) ->
    console.log "checkmodel()", req.query, req.params

    if !req.params.model
      send(req, res, new Error(404, 'model not found'))
      return

    _app.model(req.params.model.toProperCase().singularize(), req, (m, plan, c, prefix) ->
      req.m = m
      req.plan = plan
      req.c = c
      req.prefix = prefix
      if m
        next()
      else
        send(req, res, new Error(404, 'model not found'))
    )

  app.all('/api/:model/call/:method/:id', checkmodel)
  app.all('/api/:model/schema', checkmodel)
  app.all('/api/:model/defaults', checkmodel)
  app.all('/api/:model/:id', checkmodel)
  app.all('/api/:model', checkmodel)

  app.get('/api/:model/call/:method/:id', (req, res, next) ->
    console.log "app.call()", req.query, req.params

    if req.params.method?
      req.user.can(req.params.method, req.m.modelName, null, (can) ->
        if can
          req.m.findById(req.params.id, (err, r) ->
            if r
              args = []
              args.push(req)
              args.push(res)
              if req.query.args?
                args = args.concat(req.query.args)
              args.push((err, data) ->
                if !err
                  process_results(req, res, data, null, (ok) ->
                  if ok
                    next()
                  )
                else
                  send(req, res, err)
              )

              if req.m.schema.methods['$' + req.params.method]?
                req.m.schema.methods['$' + req.params.method].apply(r, args)

              else if req.m.schema.statics['$' + req.params.method]?
                req.m.schema.statics['$' + req.params.method].apply(req.m.schema, args)

              else
                send(req, res, new Error(404, "method '" + req.params.method + "' not found"))

            else
              send(req, res, new Error(404, "record '" + req.params.id + "' not found"))
          )

        else
          send(req, res, 403)
      )

    else
      send(req, res, new Error(404, "method name missing"))
  )

  app.get('/api/:model/schema', (req, res, next) ->
    console.log "app.schema()", req.query, req.params

    req.user.can('schema', req.m.modelName, null, (can) ->
      if can
        l = {}
        s = _app.modelPaths(req.m)
#        console.log s
        for k of s
          if !s[k].private
            l[k] = s[k]
        process_results(req, res, l, null, (ok) ->
          if ok
            next()
        )

      else
        send(req, res, 403)
    )
  )

  app.get('/api/:model/defaults', (req, res, next) ->
    console.log "app.defaults()", req.query, req.params

    req.user.can('defaults', req.m.modelName, null, (can) ->
      if can
        fields = {}
        o = new req.m()
        paths = _app.modelPaths(req.m)
        for k of paths
          f = paths[k]
          if !f.private
            _.deepSet(fields, k, o.get(k))
        fields = req.m.filter(fields, {keep: [], remove: ['id', '_id'], mustExists: true})
        process_results(req, res, fields, null, (ok) ->
          if ok
            next()
        )

      else
        send(req, res, 403)
    )
  )

  app.get('/api/:model/:id', (req, res, next) ->
    console.log "app.get()", req.query, req.params
    if !req.params.id
      send(req, res, new Error(404, "record '" + req.params.id + "' not found"))
      return

    req.user.can('read', req.m.modelName, null, (can) ->
      if can
        q = req.m.findById(req.params.id)
        process_select(req, q)
        process_populate(req, q)
        q.exec((err, results) ->
          process_results(req, res, results, err, (ok) ->
            if ok
              next()
          )
        )

      else
        send(req, res, 403)
    )
  )

  app.get('/api/:model', (req, res, next) ->
    console.log "app.get()", req.query, req.params

    req.user.can('read', req.m.modelName, null, (can) ->
      if can
        qo = process_query(req)
        q = req.m.find(qo)
        process_select(req, q)
        process_populate(req, q)
        process_sort(req, q)
        process_limit(req, q)
        process_skip(req, q)
        q.exec((err, results) ->
          paginate(req.m, req, results, (results) ->
            process_results(req, res, results, err, (ok) ->
              if ok
                next()
            )
          )
        )

      else
        send(req, res, 403)
    )
  )

  app.put('/api/:model/:id', (req, res, next) ->
    console.log "app.put()", req.query, req.body, req.params

    if !req.params.id
      send(req, res, new Error(404, "record '" + req.params.id + "' not found"))
      return

    req.user.can('write', req.m.modelName, null, (can) ->
      if can
        doc = req.body
        if type(doc) is 'array' and doc.length
          doc = doc[0]
        else
          doc = {}

        doc = req.m.filter(doc, {keep: ['_id'], remove: ['created_at', 'updated_at', '__v', 'owner_id'], mustExists: true})

        _conditions = { _id: req.params.id }
        if _app.hasOwner(req.m)
          _conditions.owner_id = req.user.id

        req.m.update(_conditions, doc, (err, rowCount, status) ->
          console.log ">>> app.put", rowCount, status, err
          q = req.m.findById(req.params.id)
          process_select(req, q)
          process_populate(req, q)
          q.exec((err, results) ->
            process_results(req, res, results, err, (ok) ->
              if ok
                next()
            )
          )
        )

      else
        send(req, res, 403)
    )
  )

  app.post('/api/:model', (req, res, next) ->
    console.log "app.post()", req.query, req.params

    doc = req.body
    if type(doc) is 'array' and doc.length
      doc = doc[0]
    else
      doc = {}

    req.user.can('create', req.m.modelName, [doc], (can) ->
      if can
        doc = req.m.filter(doc, {keep: [], remove: ['id', '_id', 'created_at', 'updated_at', '__v', 'owner_id'], mustExists: true})

        if _app.hasOwner(req.m)
          doc.owner_id = req.user.id

        req.m.create(doc, (err, doc) ->
          q = req.m.findById(doc._id)
          process_select(req, q)
          process_populate(req, q)
          q.exec((err, results) ->
            process_results(req, res, results, err, (ok) ->
              if ok
                next()
            )
          )
        )

      else
        send(req, res, 403)
    )
  )

  app.delete('/api/:model/:id', (req, res, next) ->
    console.log "app.delete()", req.query, req.params

    if !req.params.id
      send(req, res, new Error(404, "record '" + req.params.id + "' not found"))
      return

    req.user.can('delete', req.m.modelName, null, (can) ->
      if can
        qo =
          _id: req.params.id
          owner_id: req.user.id if _app.hasOwner(req.m)
        q = req.m.where(qo)
        q.remove((err, results) ->
          process_results(req, res, results, err, (ok) ->
            if ok
              next()
          )
        )

      else
        send(req, res, 403)
    )
  )

  return


exports.register = register
