express = require('express')
http = require('http')
path = require('path')
passport = require('passport')
LocalStrategy = require('passport-local').Strategy
flash = require('connect-flash')
#require('debug-trace')({ colors: true, always: true})
i18n = require('i18next')
expressValidator = require('express-validator')
helmet = require('helmet')
fs = require("fs")
path = require("path")
exts = require("./exts")
endpoints = require("./endpoints")
autoIncrement = require('mongoose-auto-increment')
secure = require("node-secure")
mongoose = require('mongoose')

global._ = require('lodash')
_.str = require("underscore.string")

logErrors = (err, req, res, next) ->
  console.error(err.stack)
  next(err)

clientErrorHandler = (err, req, res, next) ->
  if req.xhr
    res.send(500, { error: 'Something blew up!' })
  else
    next(err)

errorHandler = (err, req, res, next) ->
  res.status(500)

  e = []

  if req.flash? and req.flash('error')
    e.concat(req.flash('error'))

  if err
    e.push(err)

#  res.render('error',
#    title: 'Error'
#    user: req.user
#    errors: e
#    warnings: req.flash('info')
#  )
  next()

passport.serializeUser( (user, done) ->
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

passport.deserializeUser( (token, done) ->
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

    if mongoose.model('User')?
      mongoose.model('User').findOne({ username: usr }, (err, user) ->
        if !user
          return done(null, false, { message: 'Incorrect username ' + usr })
        user.comparePassword(pwd, (err, isMatch) ->
          if err
            return done(err)
          if isMatch
            if !user.isVerified
              done(null, false, { message: 'Account not verified yet' })
            else
              done(null, user)
          else
            done(null, false, { message: 'Incorrect password' })
        )
      )
    )
)

csrfValue = (req) ->
  if req.body?
    token = req.body._csrf
  if !token? and req.query?
    token = req.query._csrf
  if !token? and req.session?
    token = req.session._csrf
  if !token?
    token = req.headers['x-csrf-token']
  if !token?
    token = req.headers['x-xsrf-token']
  return token

app = express()
RedisStore = require('connect-redis')(express)
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
app.use(express.static(path.join(__dirname, '../_public')))
app.use(express.favicon())
app.use(express.urlencoded())
app.use(express.json())
app.use(express.logger('dev'))
app.use(express.bodyParser())
app.use(helmet.xframe())
app.use(helmet.iexss())
app.use(helmet.contentTypeOptions())
app.use(helmet.cacheControl())
app.use(express.methodOverride())
app.use(flash())
app.use(express.cookieParser('dc04ddbab0a4381fd1d4015db6438f172698374c'))
app.use(express.cookieSession())
app.use(expressValidator())
app.use(express.session(
  store: store
  key: 'sid'
  secret: '81acf724ef73d87efc8fdc447a7f54b525f5a18c'
  cookie:
    maxAge: 60000
    httpOnly: true
    secure: true
  )
)

app.use(express.csrf({ value: csrfValue }))

app.use( (req, res, next) ->
  token = req.csrfToken()
  res.cookie('XSRF-TOKEN', token)
  res.locals.csrftoken = token

  if mongoose.model('Log')?
    mongoose.model('Log').log(mongoose.model('Log').LOG_REQUEST, null, req.method, req.ip, req.url)

  if req.method is 'POST' and req.url.toLowerCase() is '/login'
    if req.body.rememberme
      req.session.cookie.maxAge = 2592000000
    else
      req.session.cookie.expires = false

  next()
)

app.use(passport.initialize())
app.use(passport.session())

app.use(i18n.handle)
app.use(app.router)
app.use(logErrors)
app.use(clientErrorHandler)
app.use(errorHandler)

if process.env.NODE_ENV == 'development'
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))
  mongoUri = 'mongodb://localhost/'
else if process.env.NODE_ENV == 'production'
  app.use(express.errorHandler())
  mongoUri = 'mongodb://www.arianesoft.ca/glassfrog:12500/'
exports.mongoUri = mongoUri

mongoose.connect(mongoUri + 'glassfrog')
exports.mongoose = mongoose

db = mongoose.connection
exports.db = db

autoIncrement.initialize(mongoose.connection)

models_paths = __dirname + '/models'
fs.readdirSync(models_paths).forEach((file) ->
  require(models_paths + '/' + file)
)
exports.models_paths = models_paths

routes_paths = __dirname + '/routes'
fs.readdirSync(routes_paths).forEach((file) ->
  require(routes_paths + '/' + file)
)
exports.routes_paths = routes_paths

validUser = (req) ->
  req? and req.user? and req.user._id? and req.user.isVerified and req.isAuthenticated()
exports.validUser = validUser

model = (name, req, cb) ->
  m = mongoose.model(name)
  if !m and req and validUser(req)
    req.user.model(name, (mm) ->
      cb(mm) if cb
    )
  else
    cb(m) if cb
exports.model = model

for k of mongoose.models
  show = []
  hide = []
  readOnly = []
  populate = []
  endpoints.register(k, null, show, hide, readOnly, populate)

multiPathSet = (object, path, value) ->
  nw = object
  paths = path.split('.')
  while paths.length > 1
    n = paths.shift()
    if !nw[n]
      nw[n] = {}
    nw = nw[n]
  nw[paths.shift()] = value

userInfo = (req) ->
  u = {}
  s = mongoose.model('User').schema
  s.eachPath((name, field) ->
    if !field.options.private
      multiPathSet(u, name, eval('req.user.' + name))
  )
  for k of s.virtuals
    v = mongoose.model('User').schema.virtuals[k]
    multiPathSet(u, v.path, eval('req.user.' + v.path))
  return u
exports.userInfo = userInfo

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
  debug: true
, (t) ->

)

#  i18n.setLng('en', function(t) { logger.log(t("copyright")) });
i18n.registerAppHelper(app)

#secure.on("eval", (caller) ->
#   console.log "Eval executed in following function: " + caller
#)

secure.on("insecure", (problems) ->
   console.log "Some of globals couldn't be protected: " + problems
)

secure.securePrivates(exports, {configurable: false})
secure.secureMethods(exports, {configurable: false})


app.all('/api/*', (req, res, next) ->
  if !validUser(req)
    res.send(403)
  else
    next()
)

app.get('/', (req, res) ->
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

app.get('/app', user.ensureAuthenticated, (req, res) ->
  res.render('app',
    title: 'App'
    user: userInfo(req)
    errors: req.flash('error')
    warnings: req.flash('info')
  )
)

db.on('error', console.error.bind(console, 'connection error:'))

db.once('open', () ->
  http.createServer(app).listen(app.get('port'), () ->
    console.log 'Express server listening on port ' + app.get('port')
  )
)
