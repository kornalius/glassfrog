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

send = (user_id, results, res, model, cb) ->
  if !results
    res.send('')
    cb(null) if cb
  else if _.isPlainObject(results)
    res.send(results)
    cb(results) if cb
  else if type(results) != 'array'
    addExtraFields(user_id, results, model, (ok) ->
      if ok
        j = processJSON(results)
        res.json(j)
        cb(j) if cb
      else
        cb(null) if cb
    )
  else
    l = []
    async.eachSeries(results, (r, callback) ->
      addExtraFields(user_id, r, model, (ok) ->
        if ok
          l.push(processJSON(r))
        callback()
      )
    , (err) ->
      if !err
        res.json(l)
        cb(l) if cb
      else
        cb(err) if cb
    )
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

paginate = (model, req, results, cb) ->
#  console.log "paginate()", req.baucis.controller.query.options, req.baucis.documents
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

  process_results = (req, res, err, results, cb) ->
    console.log "process_results()"
    if !err
      send(req.user._id.toString(), results, res, req.m, ->
        cb(true) if cb
      )
    else if err
      res.status(403).send(err.message).end()
      cb(false) if cb
    else
      res.status(500).end()
      cb(false) if cb


  app.all('/api/*', (req, res, next) ->
    console.log "app.all()", req.query, req.params
    if !_app.validUser(req)
      res.status(403).end()
    else
      next()
  )

  checkmodel = (req, res, next) ->
    console.log "checkmodel()", req.query, req.params

    if !req.params.model
      res.status(404).end()
      return

    _app.model(req.params.model.toProperCase().singularize(), req, (m, plan, c, prefix) ->
      req.m = m
      req.plan = plan
      req.c = c
      req.prefix = prefix
      if m
        next()
      else
        res.status(404).end()
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
                if err?
                  if type(err.message) is 'number'
                    res.status(err.message).end()
                    return
                  else if type(err.message) is 'string'
                    try
                      i = parseInt(err.message, 10)
                      if i < 200 or i > 500
                        res.status(i).end()
                      else
                        res.status(500).send(err.message).end()
                        return
                    catch e
                      res.status(500).send(err.message).end()
                      return
                process_results(req, res, null, data, (ok) ->
#                  if ok
#                    next()
                )
              )

              if req.m.schema.methods['$' + req.params.method]?
                req.m.schema.methods['$' + req.params.method].apply(r, args)

              else if req.m.schema.statics['$' + req.params.method]?
                req.m.schema.statics['$' + req.params.method].apply(req.m.schema, args)

              else
                res.status(404).end()

            else
              res.status(404).end()
          )
        else
          res.status(403).end()
      )
    else
      res.status(404).end()
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
        process_results(req, res, null, l, (ok) ->
#          if ok
#            next()
        )
      else
        res.status(403).end()
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
        delete fields.id
        delete fields._id
        delete fields.created_at
        delete fields.updated_at
        process_results(req, res, null, [fields], (ok) ->
#          if ok
#            next()
        )
      else
        res.status(403).end()
    )
  )

  app.get('/api/:model/:id', (req, res, next) ->
    console.log "app.get()", req.query, req.params
    if !req.params.id
      res.status(404).end()
      return

    req.user.can('read', req.m.modelName, null, (can) ->
      if can
        q = req.m.findById(req.params.id)
        process_select(req, q)
        process_populate(req, q)
        q.exec((err, results) ->
          process_results(req, res, err, results, (ok) ->
            if ok
              next()
          )
        )
      else
        res.status(403).end()
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
            process_results(req, res, err, results, (ok) ->
              if ok
                next()
            )
          )
        )
      else
        res.status(403).end()
    )
  )

  app.put('/api/:model/:id', (req, res, next) ->
    console.log "app.put()", req.query, req.body, req.params

    if !req.params.id
      res.status(404).end()
      return

    req.user.can('write', req.m.modelName, null, (can) ->
      if can
        doc = req.body
        if type(doc) is 'array'
          if doc.length
            doc = doc[0]
          else
            doc = {}

#        # remove extra fields and/or invalid fields
#        s = req.m.schema
#        for k in _.keys(doc)
#          if !s.path(k)
#            delete doc[k]

        doc = req.m.filter(doc, {remove: ['_id'], mustExists: true}, 'readOnly,private')

        if _app.hasOwner(req.m)
          doc.owner_id = req.user._id

        console.log "after filter", doc

        q = req.m.findOne(
          _id: req.params.id
          owner_id: req.user.id if _app.hasOwner(req.m)
        )
        process_select(req, q)
        process_populate(req, q)

        console.log "update", q

        q.update(doc, (err, rowCount, results) ->
          console.log ">>> app.put", err, rowCount, results
          if !err
            req.m.findById(req.params.id, (err, results) ->
              process_results(req, res, err, results, (ok) ->
                if ok
                  next()
              )
            )
          else if err
            res.status(403).send(err.message).end()
          else
            res.status(500).end()
        )
      else
        res.status(403).end()
    )
  )

  app.post('/api/:model', (req, res, next) ->
    console.log "app.post()", req.query, req.params

    doc = req.body
    if type(doc) is 'array'
      if doc.length
        doc = doc[0]
      else
        doc = {}

    req.user.can('create', req.m.modelName, [doc], (can) ->
      if can
        console.log "before", doc

        doc = req.m.filter(doc, {mustExists: true}, 'readOnly private')

        delete doc.id
        delete doc._id
        delete doc.created_at
        delete doc.updated_at

        console.log "after", doc

        req.m.create(doc, (err, results) ->
          process_results(req, res, err, results, (ok) ->
            if ok
              next()
          )
        )
      else
        res.status(403).end()
    )
  )

  app.delete('/api/:model/:id', (req, res, next) ->
    console.log "app.delete()", req.query, req.params

    if !req.params.id
      res.status(404).end()
      return

    req.user.can('delete', req.m.modelName, null, (can) ->
      if can
        qo =
          _id: req.params.id
          owner_id: req.user.id if _app.hasOwner(req.m)
        q = req.m.where(qo)
        q.remove((err, results) ->
          process_results(req, res, err, results, (ok) ->
            if ok
              next()
          )
        )
      else
        res.status(403).end()
    )
  )

  return


exports.register = register
