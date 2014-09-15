winston = require('winston')
global.winston = winston
logger = new winston.Logger()
logger.add(winston.transports.Console, { colorize: true })
#logger.extend(console)

console.log "Loading Server's required modules..."

modulesPath = 'client_modules'
exports.modulesPath = modulesPath

exts = require("./exts")

http = require('http')
path = require('path')

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

#require('debug-trace')({ colors: true, always: true})
i18n = require('i18next')
fs = require("fs")
path = require("path")
endpoints = require("./endpoints")
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

global.Handlebars = require('handlebars')
require('swag').registerHelpers(Handlebars)

global.js_beautify = require('js-beautify')

global.traverse = require('traverse')

global.tinycolor = require('tinycolor2')


validUser = (req) ->
  req? and req.user? and req.user._id? and req.user.isVerified and req.isAuthenticated()
exports.validUser = validUser

model = (name, req, cb) ->
  m = null
  if mongoose.modelNames()[name]?
    m = mongoose.model(name)
  if !m and validUser(req)
    req.user.model(name, null, req, (m) ->
      cb(m) if cb
    )
  else
    cb(m) if cb
exports.model = model

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
      try
        multiPathSet(u, name, eval('req.user.' + name))
      catch error
        console.log error
  )
  for k of s.virtuals
    v = s.virtuals[k]
    try
      multiPathSet(u, v.path, eval('req.user.' + v.path))
    catch error
      console.log error
  return u
exports.userInfo = userInfo


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

app.use(csrf())
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
  token = req.csrfToken()
  res.cookie('XSRF-TOKEN', token)
  res.locals.csrftoken = token

  if mongoose.model('Log')?
    mongoose.model('Log').log(mongoose.model('Log').LOG_REQUEST, null, req.method, req.ip, req.url)

  next()
)

app.use((err, req, res, next) ->
  if req.xhr
    res.send(500, { error: 'Something blew up!' })
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

db = mongoose.connection
exports.db = db

autoIncrement.initialize(mongoose.connection)

models_paths = __dirname + '/models'
fs.readdirSync(models_paths).forEach((file) ->
  console.log "Loading model {0}...".format(file)
  require(models_paths + '/' + file)
)
exports.models_paths = models_paths

routes_paths = __dirname + '/routes'
fs.readdirSync(routes_paths).forEach((file) ->
  console.log "Loading route {0}...".format(file)
  require(routes_paths + '/' + file)
)
exports.routes_paths = routes_paths

console.log "Registering API endpoints..."

endpoints.register()

app.all('/api/*', (req, res, next) ->
  next()
)

app.param('model', (req, res, next, model) ->
  req.params['model'] = model.toProperCase()
  next()
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

console.log "Connecting to MongoDB server..."

db.on('error', console.error.bind(console, 'connection error:'))

db.once('open', () ->
  app.listen(app.get('port'), () ->
    console.log 'Express server listening on port ' + app.get('port')
  )
)

console.log "All done!"
