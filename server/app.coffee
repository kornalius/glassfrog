if !process.env.NODE_ENV?
  process.env.NODE_ENV = 'development'

server = null
toobusy = require('toobusy')
console.log("Maximum allowed event loop lag: " + toobusy.maxLag(5000) + "ms")

process.on('SIGINT', ->
#  if server
#    server.close()
#  toobusy.shutdown()
  process.exit()
)

process.on('exit', (code) ->
  console.log 'About to exit with code:', code
  if server
    server.close()
  toobusy.shutdown()
  console.log 'Done exit cleanups!'
)

if process.env.NODE_ENV != 'development'
  process.on('uncaughtException', (err) ->
    console.log 'Uncaught exception:', err
    process.exit()
  )

global.CircularJSON = require('circular-json')

exts = require("./exts")

#if process.env.NODE_ENV == 'development'
#  require("node-codein")

console.log "{red}Loading Server's required modules..."

exports.modulesPath = modulesPath = 'client_modules'

http = require('http')
flash = require('express-flash')
express = require('express')
favicon = require('serve-favicon')
serveStatic = require('serve-static')
session = require('express-session')
bodyParser = require('body-parser')
cookieParser = require('cookie-parser')
methodOverride = require('method-override')
errorhandler = require('errorhandler')
morgan = require('morgan')
passport = require('passport')
LocalStrategy = require('passport-local').Strategy
helmet = require('helmet')
csrf = require('csurf')
#util = require('util')

global.sanitizer = require('sanitizer')

#require('debug-trace')({ colors: true, always: true})
i18n = require('i18next')
fs = require("fs")
path = require("path")
autoIncrement = require('mongoose-auto-increment')
mongoose = require('mongoose')
secure = require("node-secure")

global.mongooseCurrency = require('mongoose-currency').loadType(mongoose)
global.mongooseSetter = require('mongoose-setter')(mongoose)
global.mongoosePercent = require('./mongoose_plugins/mongoose-percent')(mongoose)
global.mongooseMoment = require('mongoose-moment')(mongoose)
global.mongooseEncrypted = require("mongoose-encrypted").loadTypes(mongoose)
global.mongooseVersion = require('./mongoose_plugins/mongoose-version')()

require('sugar')

global.moment = require('moment')

global._ = require('lodash')
_.mixin(require('lodash-deep'))
require('underscore-query')(_)
_.str = require("underscore.string")

global.acorn = require('acorn')

global.js_beautify = require('js-beautify')

global.traverse = require('traverse')

global.tinycolor = require('tinycolor2')


exports.validUser = validUser = (req) ->
#  console.log req.constructor.name, req instanceof http.IncomingMessage
  if req instanceof http.IncomingMessage
    user = req.user
  else
    user = req
    req = null
  user? and user._id? and user.isVerified and (!req? or req.isAuthenticated())

exports.userInfo = userInfo = (req, cb) ->
  require('./endpoints').toPublicJSON(req.user, req.user, mongoose.model('User').schema, {}, (i) ->
    cb(i) if cb
  )

exports.model = model = (name, user, cb) ->
  console.log "app.model()", name
  if user instanceof http.IncomingMessage
    req = user
    user = req.user
  else
    req = null
  m = null
  if mongoose.modelNames().indexOf(name) != -1
    m = mongoose.model(name)
  if !m and validUser((if req then req else user))
    user.model(name, (m, plan, c, prefix) ->
      cb(m, plan, c, prefix) if cb
    )
  else
    cb(m, null, mongoose.db, '') if cb

exports.modelSync = modelSync = (name, user, connection, prefix) ->
  console.log "app.modelSync()", name
  m = null
  if mongoose.modelNames().indexOf(name) != -1
    m = mongoose.model(name)
  if !m and validUser(user)
    m = user.modelSync(name, user, connection, prefix)
  return m

exports.schemaPaths = schemaPaths = (schema, node, path) ->
  results = {}

  if !node
    return results

  makePath = (path, k) ->
    return (if path then path + '.' + k else k)

  if node instanceof Array
    f = _.first(node)
    if f
      if f.tree
        if path
          results[path] = {type: 'DocumentArray'}
        for k of f.tree
          _.extend(results, schemaPaths(schema, f.tree[k], makePath(path, k)))
      else
        if path
          results[path] = {type: 'NestedArray'}
        for k of f
          _.extend(results, schemaPaths(schema, f[k], makePath(path, k)))
    else
      results[path] = {}
      results[path].type = 'Array'

  else if _.isObject(node) and !node.type and !node.getters and schema.pathType(path) != 'real'
    if path
      if schema.pathType(path) == 'Nested'
        results[path] = {}
        results[path].type = 'Nested'
      else
        results[path] = {}
        results[path].type = 'Subdocument'

    if type(node) != 'function'
      for k of node
        _.extend(results, schemaPaths(schema, node[k], makePath(path, k)))

  else if _.isObject(node) and !node.type and node.getters
    results[path] = {}
    results[path].type = 'Virtual'

  else
    results[path] = {}

    for k of node
      p = node[k]
      keys = _.keys(p)
      f = _.filter(_.values(p), (v) -> type(v) != 'function')
      if f.length == keys.length
        results[path][k] = p

    if type(node.type) is 'function'
      results[path].type = node.type.prototype.constructor.name
    else if type(node) is 'function'
      results[path].type = node.prototype.constructor.name
    else if node.instance? and type(node.instance) is 'string'
      results[path].type = node.instance.toProperCase()

  for k of results
    results[k].path = k
    results[k].fieldname = _.last(k.split('.'))

  return results

exports.modelPaths = modelPaths = (model) ->
  if model instanceof mongoose.Schema
    return schemaPaths(model, model.tree)
  else if type(model) is 'function'
    return schemaPaths(model.schema, model.schema.tree)
  else
    return {}

exports.hasOwner = hasOwner = (model) ->
  return model.schema.path('owner_id')

console.log "Creating Passport functions..."

passport.serializeUser((user, done) ->
  createAccessToken = () ->

    if !token
      token = user.generateRandomToken()
      if mongoose.model('User')?
        mongoose.model('User').findOne({ accessToken: token }, (err, existingUser) ->
          if existingUser?
            createAccessToken()
          else
            user.accessToken = token
            user.save((err) ->
              if !err?
                done(null, user.accessToken)
              else
                done(null)
            )
        )

  createAccessToken()
)

passport.deserializeUser((token, done) ->
  if token? and mongoose.model('User')?
    mongoose.model('User').findOne({ accessToken: token }, (err, user) ->
      if user?
        done(null, user)
      else
        done(null, false)
    )
)

passport.use(
  new LocalStrategy( (username, password, done) ->
    usr = username
    pwd = password

    errormsg = 'Incorrect information or account is not verified yet'

    if mongoose.model('User')?
      mongoose.model('User').findOne({ username: usr }, (err, user) ->
        if !user
          return done(null, false, { message: errormsg })
        user.comparePassword(pwd, (err, isMatch) ->
          if err
            return done(err)
          if isMatch
            if !user.isVerified
              done(null, false, { message: errormsg })
            else
              done(null, user)
          else
            done(null, false, { message: errormsg })
        )
      )
    )
)

console.log "Initializing Express framework..."

console.log "Initializing Redis server..."

app = express()

RedisStore = require('connect-redis')(session)
if process.env.NODE_ENV == 'development'
  store = new RedisStore(
    host: 'localhost'
    port: 6379
    prefix: 'sess'
  )

else if process.env.NODE_ENV == 'production'
  store = new RedisStore(
    host: 'localhost'
    port: 6379
    prefix: 'sess'
  )

exports.app = app
exports.passport = passport
exports.store = store
exports.i18n = i18n

app.set('port', process.env.PORT or 3000)
app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'jade')

if process.env.NODE_ENV == 'production'
  app.set('trust proxy', 1)

app.use(morgan('dev'))
app.use(methodOverride('X-HTTP-Method-Override'))
app.use(cookieParser('dc04ddbab0a4381fd1d4015db6438f172698374c'))
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())
app.use(serveStatic(path.join(__dirname, '../_public')))
app.use(favicon(path.join(__dirname, '../_public/favicon.ico')))
app.use(flash())

app.use(session(
  store: store
  name: 'sid'
  secret: '81acf724ef73d87efc8fdc447a7f54b525f5a18c'
  resave: false
  saveUninitialized: false
  cookie:
    maxAge: 60000
    path: '/'
    httpOnly: true
    secure: true if process.env.NODE_ENV == 'production'
  )
)

app.use(passport.initialize())
app.use(passport.session())

app.use(i18n.handle)

app.use(helmet())

#app.use(csrf())
#  value: (req) ->
#    if req.body?
#      token = req.body._csrf
#      console.log "body", token
#    if !token? and req.query?
#      token = req.query._csrf
#      console.log "query", token
#    if !token? and req.session?
#      token = req.session._csrf
#      console.log "session", token
#    if !token?
#      token = req.headers['x-csrf-token']
#      console.log "headers x-csrf", token
#    if !token?
#      token = req.headers['x-xsrf-token']
#      console.log "headers x-xsrf", token
#    return token
#))

app.use((req, res, next) ->
  if toobusy()
    res.send(new Error(503, "Server is too busy right now, sorry."))
    return res.end()

#  token = req.csrfToken()
  token = ''
  res.cookie('XSRF-TOKEN', token)
  res.locals.csrftoken = token

  if mongoose.model('Log')?
    if req.user
      id = req.user._id.toString()
    else
      id = 'N/A'
    mongoose.model('Log').log(id, mongoose.model('Log').LOG_REQUEST, null, req.method, req.ip, req.url)

  if req.user and !req.user.cache
    req.user.createRequestVars(req, ->
      next()
    )
  else
    next()
)

app.use((err, req, res, next) ->
  if req.xhr
    res.status(500, { error: 'Something blew up!' })
  else
    next(err)
)

if process.env.NODE_ENV == 'development'
  app.use(errorhandler())
  mongoUri = 'mongodb://localhost/'
else if process.env.NODE_ENV == 'production'
  mongoUri = 'mongodb://www.arianesoft.ca/glassfrog:12500/'
exports.mongoUri = mongoUri

console.log "Initializing Mongoose framework..."

mongoose.connect(mongoUri + 'glassfrog')
exports.mongoose = mongoose

exports.db = db = mongoose.connection

autoIncrement.initialize(mongoose.connection)

console.log "Registering models..."

exports.models_paths = models_paths = __dirname + '/models'
fs.readdirSync(models_paths).forEach((file) ->
  if path.extname(file) == '.js'
    console.log "Loading model {0}...".format(file)
    m = require(models_paths + '/' + file)
)

console.log "Initializing i18 framework..."

i18n.init(
  useCookie: true
  ignoreRoutes: [
    'images/'
    'public/'
    'css/'
    'js/'
  ]
  supportedLngs: [
    'en'
    'fr'
  ]
  lng: 'en'
  fallbackLng: 'en'
  load: 'unspecific'
  # detectLngQS: 'lng'
  resGetPath: 'app/assets/locales/__ns__-__lng__.json'
  sendMissing: true
  resPostPath: 'app/assets/locales/add/__ns__-__lng__.json'
  sendMissingTo: 'all'
#  debug: true
, (t) ->

)

#  i18n.setLng('en', function(t) { logger.log(t("copyright")) });
i18n.registerAppHelper(app)

#secure.on("eval", (caller) ->
#   console.log "Eval executed in following function: " + caller
#)

console.log "Securing javascript..."

secure.on("insecure", (problems) ->
   console.log "Some of globals couldn't be protected: " + problems
)

secure.securePrivates(exports, {configurable: false})
secure.secureMethods(exports, {configurable: false})

console.log "Setting global routes..."

app.get('/', (req, res, next) ->
  if validUser(req)
    res.redirect("/app")
  else
    res.render('index',
      title: 'Home'
      errors: req.flash('error')
      warnings: req.flash('info')
    )
)

user = require('./routes/user')

app.get('/app', user.ensureAuthenticated, (req, res, next) ->
  userInfo(req, (i) ->
    res.render('app',
      title: 'App'
      user: i
      errors: req.flash('error')
      warnings: req.flash('info')
    )
  )
)

exports.routes_paths = routes_paths = __dirname + '/routes'

console.log "Registering routes..."

fs.readdirSync(routes_paths).forEach((file) ->
  ext = path.extname(file)
  if ext == '.js' # and path.basename(file, ext).endsWith('_pre')
    console.log "Loading route {0}...".format(file)
    require(routes_paths + '/' + file)
)

console.log "Registering endpoints..."

endpoints = require('./endpoints')
endpoints.register()

app.get('*', (req, res, next) ->
  next(new Error(404))
)

#console.log app._router.stack.filter((r) -> r.route).map((r) -> r.method + ' -> ' + r.route.path)

console.log "Connecting to MongoDB server..."

db.on('error', console.error.bind(console, 'connection error:'))

db.once('open', () ->
  server = app.listen(app.get('port'), () ->
    console.log 'Express server listening on port ' + app.get('port')
  )
)

console.log "All done!"
