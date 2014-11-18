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

__send = (res, data, err) ->
  s = {'$s': (if !err then 'ok' else 'error')}
  if err
    if type(err) is 'number'
      err = new Error(err)
    s['$e'] = {code: err.code, msg: err.message}

  if data instanceof Array
    if hasPagination(data)
      data[0] = _.extend({}, data[0], s)
    else if data.length == 1
      data = _.extend({}, data[0], s)
    else
      data.splice(0, 0, s)
  else
    data = _.extend({}, data, s)

  res.json(data)

exports.send = send = (options, req, res, next) ->
#  console.log "send()", options
  results = null
  model = null
  err = null
  plain = false

  if options
    if type(options) is 'number'
      err = new Error(options)
    else if options instanceof Error
      err = options
    else
      results = options.results
      model = options.model
      err = options.err
      plain = options.plain

  if !results
    results = {}

  if model and !plain
    toPublicJSON(req.user, results, model.schema, {}, (json) ->
      __send(res, json, null)
      if next
        next(err)
    )
  else
    __send(res, results, err)
    if next
      next(err)

exports.populatedPaths = populatedPaths = (r, model) ->
  l = []
  paths = _app.modelPaths(model)
  for k of paths
    f = paths[k]
    if f.type == 'objectid' and f.ref and r[f] and r[f]._id?
      l.push(k)
#  console.log "populatedPaths()", l
  return l

exports.virtualPaths = virtualPaths = (model) ->
  l = []
  paths = _app.modelPaths(model)
  for k of paths
    f = paths[k]
    if f.type == 'virtual'
      l.push(k)
#  console.log "virtualPaths()", l
  return l

exports.selectPaths = selectPaths = (model) ->
  l = []
  paths = _app.modelPaths(model)
  for k of paths
    f = paths[k]
    if f.select
      l.push(k)
#  console.log "selectPaths()", l
  return l

exports.requiredPaths = requiredPaths = (model) ->
  l = []
  paths = _app.modelPaths(model)
  for k of paths
    f = paths[k]
    if f.required
      l.push(k)
#  console.log "requiredPaths()", l
  return l

exports.populatePaths = populatePaths = (model) ->
  l = []
  paths = _app.modelPaths(model)
  for k of paths
    f = paths[k]
    if f.populate
      l.push(k)
#  console.log "populatePaths()", l
  return l

exports.readOnlyPaths = readOnlyPaths = (model) ->
  l = []
  paths = _app.modelPaths(model)
  for k of paths
    f = paths[k]
    if f.readOnly
      l.push(k)
#  console.log "readOnlyPaths()", l
  return l

exports.privatePaths = privatePaths = (model) ->
  l = []
  paths = _app.modelPaths(model)
  for k of paths
    f = paths[k]
    if f['private']
      l.push(k)
#  console.log "privatePaths()", l
  return l

exports.readablePaths = readablePaths = (model) ->
  l = _.without(selectPaths(model), privatePaths(model))
#  console.log "readablePaths()", l
  return l

exports.lockedPaths = lockedPaths = (model) ->
  l = _.union(readOnlyPaths(model), privatePaths(model))
#  console.log "lockedPaths()", l
  return l

exports.toPublicJSON = toPublicJSON = (user, doc, schema, _options, action, cb) ->
#  console.log "toPublicJSON()", user, doc, schema, _options, action

  if type(_options) is 'string'
    cb = action
    action = _options
    _options = {}

  if type(action) is 'function'
    cb = action
    action = 'read'

  _options = _.extend({}, DEFAULT_OPTIONS, _options, (if action is 'write' then {mustExists: true} else {}))
  _options.keep = _.union(DEFAULT_OPTIONS.keep, (if _options.keep then _options.keep else []))
  _options.remove = _.union(DEFAULT_OPTIONS.remove, (if _options.remove then _options.remove else []))

  _.extend(_options, {keep: _.union(_options.keep, readablePaths(schema))}, {remove: privatePaths(schema)})
  if action is 'write'
    _options.remove = _.union(_options.remove, lockedPaths(schema))

  makePath = (path, k) ->
    return (if path then path + '.' + k else k)

  isPathIn = (path, arr) ->
    last = _.last(path.split('.'))
    for a in arr
      if path == a
        return true
      else if a.startsWith('#') and last == a.substr(1)
        return true
    return false

  isValidPath = (path) ->
    return path and (!(isPathIn(path, _options.remove)) or (isPathIn(path, _options.keep)))

#  toObj = (doc) ->
#    if doc instanceof Array
#      r = []
#      for d in doc
#        r.push(toObj(d))
#      return r
#    else if doc.toJSON
#      return doc.toJSON(_options)
#    else if doc.toObject
#      return doc.toObject(_options)
#    else if doc._doc
#      return doc._doc
#    else
#      return doc

  processFields = (doc, path, cb) ->
    if !doc
      cb(null) if cb
      return

    if doc._doc and doc.schema
      s = doc.schema
      paths = _.keys(_.extend({}, s.paths, s.virtuals))
    else
      s = null
      if !(doc instanceof mongoose.Types.ObjectId)
        paths = _.keys(doc)
        if paths.length == 0
          paths = null
      else
        paths = null

    if doc instanceof Array
      newObj = []
#      i = 0
      async.eachSeries(doc, (d, callback) ->
        processFields(d, path, (r) ->
          if r
            newObj.push(r)
#          i++
          callback()
        )
      , (err) ->
        cb(newObj) if cb
      )

    else if paths
      newObj = {}
      async.eachSeries(paths, (k, callback) ->
        cp = makePath(path, k)
        if isValidPath(cp)
          processFields(doc[k], cp, (n) ->
            if n
              newObj[k] = n
            callback()
          )
        else
#          console.log "skipping field", cp
          callback()

      , (err) ->
        if s and s.extraFields
          user_id = user._id.toString()
#          console.log "applying extraFields to", path
          async.eachSeries(s.extraFields, (fct, callback) ->
            fct.apply(doc, [user_id, newObj, callback])
          , (err) ->
            if _.keys(newObj).length == 0
              newObj = null
            cb(newObj) if cb
          )
        else
          if _.keys(newObj).length == 0
            newObj = null
          cb(newObj) if cb
      )

    else
      cb(doc) if cb


  processFields(doc, null, (newObj) ->
#    console.log ""
#    console.log ">>>> newObj:", jsonToString(newObj)
#    console.log ""
    cb(newObj) if cb
  )

DEFAULT_OPTIONS =
  prefix: '_'
  keep: ['#_id', '#__v']
  remove: ['#id']
  mustExists: false
  getters: true
#  virtuals: true

exports.queryFromString = queryFromString = (str, model, user, connection, prefix) ->
  querystring = require('querystring')
  qs = querystring.parse(str)

  if !model and qs.m
    model = app.modelSync(qs.m, user, connection, prefix)

  if !model
    return null

  q = model.find(process_query(qs.q))
  process_select(qs.s, model, q)
  process_populate(qs.p, model, user, connection, prefix, q)
  l = process_limit(qs.l, q)
  process_skip(qs.sk, qs.page, l, q)
  process_sort(qs.sort, q)

  return q

exports.selectFields = selectFields = (select, model) ->
  l = []
  paths = _app.modelPaths(model)
  if select
    for s in select
      if s.length and !s.startsWith('+')
        ok = true
        if paths
          for k of paths
            if k == s
              ok = false
              break
        if ok
          l.push(s)
  if paths
    for k of paths
      if paths[k].private
        l.push('-' + k)
  return l

exports.populateFields = populateFields = (populate, model, user, connection, prefix) ->
  l = []
  paths = _app.modelPaths(model)
  if paths
    for k of paths
      f = paths[k]
      if !f.private and f.type == 'objectid' and f.ref and (f.populate or k in populate)
        m = _app.modelSync(f.ref, user, connection, prefix)
        if m
          c = { path: k }
          ss = selectFields([], m)
          if ss.length
            c.select = ss.join(' ')
          pp = populateFields([], m, user, connection, prefix)
          if pp.length
            c.populate = pp
  #        c.options = {}
          l.push(c)
  return l

hasPagination = (data) ->
  if data instanceof Array and data.length
    return data[0]['$p']
  else
    return false

hasStatus = (data) ->
  if data instanceof Array and data.length
    return data[0]['$s']
  else
    return data['$s']

process_query = (str) ->
  console.log "process_query()", jsonToString(str)
  if str
    try
      qo = query.compile(query.parse(str))
    catch e
      console.log e
    if !qo
      qo = {}
    return qo
  else
    return {}

process_select = (str, model, q) ->
  select = selectFields((if str then str.split(' ') else []), model).join(' ')
  console.log "process_select()", str, select
  if q
    if select.length
      q.select(select.join(' '))
    return q
  else
    return select

process_populate = (str, model, user, connection, prefix, q) ->
  populate = populateFields((if str then str.split(' ') else []), model, user, connection, prefix)
  console.log "process_populate()", str, jsonToString(populate)
  if q
    if populate.length
      q.populate(populate)
  return populate

process_limit = (str, q) ->
  i = 10
  if str
    try
      i = parseInt(str, 10)
    catch e
      i = 0
      console.log e
  i = Math.abs(Math.min(MAX_LIMIT, i))
  console.log "process_limit()", i
  if q
    q.limit(i)
  return i

process_skip = (str, pagestr, limit, q) ->
  i = 0
  if str
    try
      i = parseInt(str, 10)
    catch e
      i = 0
      console.log e
  else if pagestr
    try
      i = parseInt(pagestr, 10)
      i = (i - 1) * limit
    catch e
      i = 0
      console.log e
  i = Math.abs(Math.min(MAX_LIMIT, i))
  console.log "process_skip()", i
  if q
    q.skip(i)
  return i

process_sort = (str, q) ->
  console.log "process_sort()", str
  if q
    if str
      q.sort(str)
  return str

process_results = (results, plain, req, res, next) ->
  console.log "process_results()", results.length
  if type(plain) != 'boolean'
    next = res
    res = req
    req = plain
    plain = null
  send({results:results, model:req.m, plain: (if plain then true else false)}, req, res, next)

exports.paginate = paginate = (model, limit, skip, results, cb) ->
  console.log "paginate()", results.length
  model.count((err, count) ->
    if !results
      results = []

    if !(results instanceof Array)
      results = [results]

    if !err
      limit = Math.min(MAX_LIMIT, limit)
      skip = Math.min(MAX_LIMIT, skip)
      pages = Math.max(Math.ceil(count / limit), 1)
      c = Math.ceil(skip / limit)
      if c == Math.floor(skip / limit)
        c++
      page = Math.min(pages, Math.max(c, 1))
    else
      limit = 1
      skip = 0
      page = 1
      pages = 1

    results.splice(0, 0,
      '$p': true
      total: count
      displayCount: results.length
      l: limit
      sk: skip
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

exports.checkUser = checkUser = (req, res, next) ->
  console.log "checkUser()", req.query, req.params
  if !_app.validUser(req)
    next(new Error(403))
  else
    next()

exports.checkModel = checkModel = (req, res, next) ->
  console.log "checkModel()", req.query, req.params

  if !req.params.model
    return next(new Error(404, 'model not found'))

  _app.model(req.params.model.singularize().toProperCase(), req, (m, plan, c, prefix) ->
    req.m = m
    req.plan = plan
    req.c = c
    req.prefix = prefix
    if m
      next()

    else
      next(new Error(404, 'model not found'))
  )

exports.method = method = (req, res, next) ->
  console.log "method()", req.query, req.params

  if req.params.method?
    req.user.can(req.params.method, req.m.modelName, null, (can) ->
      if can
        req.m.findById(req.params.id, (err, r) ->
          if r
            args = []
            args.push(req)
            args.push(res)
            args.push((err, data) ->
              if !data
                data = {}
              if !err
                send({results:[data], model:req.m, plain: true}, req, res, next)
              else
                next(err)
            )
            if req.query.args?
              args = args.concat(req.query.args)

            if req.m.schema.methods['$' + req.params.method]?
              req.m.schema.methods['$' + req.params.method].apply(r, args)

            else if req.m.schema.statics['$' + req.params.method]?
              req.m.schema.statics['$' + req.params.method].apply(req.m.schema, args)

            else
              next(new Error(404, "method '" + req.params.method + "' not found"))

          else
            next(new Error(404, "record '" + req.params.id + "' not found"))
        )

      else
        next(new Error(403))
    )

  else
    next(new Error(404, "method name missing"))

exports.schema = schema = (req, res, next) ->
  console.log "schema()", req.query, req.params

  makeField = (j, f) ->
    _.extend(j, f)
    delete j['formtype']
    delete j['path']
    delete j['fieldname']
    delete j['label']
    j.type = (if f.formtype? then f.formtype else schemaType(f.type))
    j.title = (if f.label? then f.label else undefined)
    if f.fieldname == '_id'
      j.required = true
      j.readonly = true
      j.title = 'ID'

  schemaType = (t) ->
    if t == 'objectid'
      return 'string'
    else if t == 'integer'
      return 'number'
    else
      return t

  toJsonSchema = (js, f) ->
    if !f.private and f.fieldname != 'id'
      if f.fields?

        if f.fieldname
          j = js[f.fieldname] = {}
        else
          j = js
        r = null

        if f.fieldname
          makeField(j, f)

        if f.type == 'array' or f.type == 'nestedarray' or f.type == 'documentarray'
          _.extend(j,
            type: 'array'
            items:
              type: 'object'
              properties: {}
          )
          r = j.items.properties
        else
          if f.fieldname
            _.extend(j,
              type: 'object'
              properties: {}
            )
            r = j.properties
          else
            _.extend(j,
              type: 'object'
              properties: {}
            )
            r = j.properties

        if r
          for k of f.fields
            toJsonSchema(r, f.fields[k])

      else
        if f.fieldname
          j = js[f.fieldname] = {}
        else
          j = js

        makeField(j, f)

#          notitle: !f.label?
#          feedback: "{ 'cic': true, 'cic-asterisk': form.required && !hasSuccess() && !hasError(), 'cic-ok': hasSuccess(), 'cic-remove': hasError() }"
#          readonly: f.readOnly if f.readOnly?
#          description: f.description if f.description?
#          placeholder: f.placeholder if f.placeholder?
#          validationMessage: f.validationMessage if f.validationMessage?
#          ngModelOptions: f.ngModelOptions if f.ngModelOptions?
#          onChange: f.onChange if f.onChange?


  req.user.can('schema', req.m.modelName, null, (can) ->
    if can
      if req.params.type? and req.params.type == 'json'
        s = _app.modelTree(req.m)
        if s
          js = {}
          toJsonSchema(js, s)
          s = [js]
          console.log s
      else
        s = _app.modelPaths(req.m)
        if s
          for k of s
            if s[k].private or s[k].fieldname == 'id'
              delete s[k]
      process_results(s, req, res, next)
    else
      next(new Error(403))
  )

exports.defaults = defaults = (req, res, next) ->
  console.log "defaults()", req.query, req.params

  req.user.can('defaults', req.m.modelName, null, (can) ->
    if can
      fields = {}
      o = new req.m()
      paths = _app.modelPaths(req.m)
      if paths
        for k of paths
          if !paths[k].private
            _.deepSet(fields, k, o[k])
      toPublicJSON(req.user, fields, req.m.schema, {remove: _.union(['id', '_id'], privatePaths(req.m)), mustExists: true}, (fields) ->
        process_results(fields, true, req, res, next)
      )
    else
      next(new Error(403))
  )

exports.one = one = (req, res, next) ->
  console.log "one()", req.query, req.params

  if !req.params.id
    return next(new Error(404, "record '" + req.params.id + "' not found"))

  req.user.can('read', req.m.modelName, null, (can) ->
    if can
      q = req.m.findById(req.params.id)
      process_select(req.query.s, q)
      process_populate(req.query.p, q)
      q.exec((err, results) ->
        if !err
          process_results(results, req, res, next)
        else
          next(err)
      )
    else
      next(new Error(403))
  )

exports.list = list = (req, res, next) ->
  console.log "list()", req.query, req.params

  req.user.can('read', req.m.modelName, null, (can) ->
    if can
      qo = process_query(req.query.q)
      q = req.m.find(qo)
      process_select(req.query.s, q)
      process_populate(req.query.p, q)
      process_sort(req.query.sort, q)
      l = process_limit(req.query.l, q)
      sk = process_skip(req.query.sk, req.query.page, l, q)
      q.exec((err, results) ->
        if !err
          paginate(req.m, l, sk, results, (results) ->
            process_results(results, req, res, next)
          )
        else
          next(err)
      )
    else
      next(new Error(403))
  )

exports.update = update = (req, res, next) ->
  console.log "update()", req.query, req.body, req.params

  if !req.params.id
    return next(new Error(404, "record '" + req.params.id + "' not found"))

  req.user.can('write', req.m.modelName, null, (can) ->
    if can
      doc = req.body
      if doc instanceof Array and doc.length
        doc = doc[0]

      toPublicJSON(req.user, doc, req.m.schema, {keep: ['_id'], remove: ['#id', '#_id', '#created_at', '#updated_at', '#__v', '#owner_id']}, 'write', (doc) ->
        req.m.findById(req.params.id, (err, r) ->
          if r
            if _app.hasOwner(req.m) and r.owner_id != req.user._id.toString()
              next(new Error(403))
            else
              r.set(doc)
              r.save((err, s, rowCount) ->
                console.log "done save()", err, rowCount
                if !err
                  q = req.m.findById(req.params.id)
                  process_select(req.query.s, q)
                  process_populate(req.query.p, q)
                  q.exec((err, results) ->
                    if !err
                      process_results(results, req, res, next)
                    else
                      next(err)
                  )
                else
                  next(err)
              )
          else
            next(err)
        )
      )

    else
      next(new Error(403))
  )

exports.create = create = (req, res, next) ->
  console.log "create()", req.query, req.params

  doc = req.body
  if doc instanceof Array and doc.length
    doc = doc[0]
  else
    doc = {}

  req.user.can('create', req.m.modelName, [doc], (can) ->
    if can
      toPublicJSON(req.user, doc, req.m.schema, {keep: ['#_id'], remove: ['#id', '#_id', '#created_at', '#updated_at', '#__v', '#owner_id']}, 'write', (doc) ->
        if _app.hasOwner(req.m)
          doc.owner_id = req.user.id

        req.m.create(doc, (err, doc) ->
          if !err
            q = req.m.findById(doc._id)
            process_select(req.query.s, q)
            process_populate(req.query.p, q)
            q.exec((err, results) ->
              if !err
                process_results(results, req, res, next)
              else
                next(err)
            )
          else
            next(err)
        )
      )

    else
      next(new Error(403))
  )

exports.remove = remove = (req, res, next) ->
  console.log "app.remove()", req.query, req.params

  if !req.params.id
    return next(new Error(404, "record '" + req.params.id + "' not found"))

  req.user.can('delete', req.m.modelName, null, (can) ->
    if can
      qo =
        _id: req.params.id
        owner_id: req.user.id if _app.hasOwner(req.m)
      q = req.m.where(qo)
      q.remove((err, results) ->
        if !err
          process_results(results, req, res, next)
        else
          next(err)
      )
    else
      next(new Error(403))
  )


exports.register = register = () ->

  app.get('/api/:model/call/:method/:id', checkUser, checkModel, method, (req, res, next) -> )

  app.get('/api/:model/schema/:type', checkUser, checkModel, schema, (req, res, next) -> )

  app.get('/api/:model/schema', checkUser, checkModel, schema, (req, res, next) -> )

  app.get('/api/:model/defaults', checkUser, checkModel, defaults, (req, res, next) -> )

  app.get('/api/:model/:id', checkUser, checkModel, one, (req, res, next) -> )

  app.get('/api/:model', checkUser, checkModel, list, (req, res, next) -> )

  app.put('/api/:model/:id', checkUser, checkModel, update, (req, res, next) -> )

  app.post('/api/:model', checkUser, checkModel, create, (req, res, next) -> )

  app.delete('/api/:model/:id', checkUser, checkModel, remove, (req, res, next) -> )

  return


app.use('/api', (err, req, res, next) ->
  console.log "api error", err
  send({err: err}, req, res, next)
)

app.param('id', (req, res, next, id) ->
  console.log "app.param(id)", id, req.params

  VCGlobal = require('./vc_global')
  if VCGlobal.isValidId(id)
    next()
  else
    next(new Error(404, 'Invalid id format'))
)

app.param('model', (req, res, next, model) ->
  console.log "app.param(model)", model

  _app.model(model.singularize().toProperCase(), req, (m, plan, c, prefix) ->
    if m
      req.m = m
      req.plan = plan
      req.c = c
      req.prefix = prefix
      next()
    else
      next(new Error(404, 'model not found'))
  )
)

app.param('method', (req, res, next, method) ->
  console.log "app.param(method)", method, req.params

  next()
)

app.use('/api', (req, res, next) ->
  console.log "sanitize api", req.query, req.params

  sanitizeQuery = (o) ->
    if type(o) is 'object'
      for k of o
        if /^\$/.test(k)
          delete o[k]

  if req.params?
    sanitizeQuery(req.params)

  if req.query?
    sanitizeQuery(req.query)

#  if req.body?
#    s = jsonToString(req.body)
#    req.body = stringToJson(sanitizer.sanitize(s))

  next()
)
