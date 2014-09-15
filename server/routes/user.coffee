_app = require("../app")
app = require("../app").app
mongoose = require("mongoose")
passport = require("../app").passport
nodemailer = require("nodemailer")
secure = require('node-secure')

ensureAuthenticated = (req, res, next) ->
  return next() if require("../app").validUser(req)
  req.flash("error", "This area is restricted to registered users!")
  res.redirect("/")
exports.ensureAuthenticated = ensureAuthenticated

spamMid = (req, res, next) ->
  token = req.query["token"]
  if token is 'undefined'
    res.render("signup",
      title: "Sign up"
      errors: req.flash('error')
      warnings: req.flash('info')
    )
  else
    next()

app.get("/activate", (req, res) ->
  token = req.query.token
  mongoose.model('Activate').findOne({ hashedEmail: token }, (err, activation) ->
    if activation
      if activation.verifyStatus
        activation.verifyStatus = false
        activation.save((err) ->
          if !err
            mongoose.model('User').findOne({ email: activation.email }, (err, user) ->
              if user
                user.status = "active"
                user.save((err) ->
                  if !err
                    req.flash("info", "Your account has been activated. Please login now to enter our wonderful world... ")
                    res.redirect("/login")
                  else
                    res.redirect("/")
                )
            )
        )
      else
        req.flash("error", "Your account has already been activated. Please use the login page instead.")
        res.redirect("/login")
    else
      req.flash("error", "Invalid activation link!")
      res.redirect("/")
  )
)

app.get("/signup", (req, res) ->
  res.render("signup",
    title: "Sign up"
    token: req.token
    errors: req.flash("error")
    warnings: req.flash("info")
  )
)

app.post("/signup", (req, res, next) ->
  mongoose.model('User').findOne({ username: req.body.username }, (err, usr) ->
    if usr?
      req.flash("info", "Oops, this username has been taken. Please user another one.")
      res.redirect("/signup")
    else
      mongoose.model('Role').findOne({ name: 'user' }, (err, role) ->
        mongoose.model('User').create(
          username: req.body.username
          password: req.body.password
          name:
            first: req.body.firstname
            last: req.body.lastname
          email: req.body.email
          roles: if role then [role.id] else []
        ,(err, usr) ->
          if err
            req.flash("info", "Oops, something went wrong, please try again later. " + err)
            res.redirect("/signup")
          else
            usr.cryptEmail( ->
              mongoose.model('Activate').create(
                email: usr.email
                hashedEmail: usr.hashedEmail
                verifyStatus: true
              ,(err, a) ->
                if err
                  req.flash("info", "Oops, something went wrong, please try again later. " + err)
                  res.redirect("/signup")
                else
                  auth_email = "arianesoftinc@gmail.com"
                  auth_pass = "fhdddxviefluhrut"
                  siteUrl = "http://localhost:3000"
                  mailOptions =
                    from: "ArianeSoft Inc. <" + auth_email + ">"
                    to: usr.email
                    subject: "Signup Confirmation"
                    text: "Signup Confirmation.\nPlease paste this link your browser to activate your account." + siteUrl + "/activate?token=" + a.hashedEmail
                    html: "<b>Signup Confirmation</b><br />" + "<p>Please click this link to activate your account.</p><br />" + "<a href=\"" + siteUrl + "/activate?token=" + a.hashedEmail + "\">Click here to activate your account.</a>"

                  smtpTransport = nodemailer.createTransport("SMTP",
                    service: "Gmail"
                    auth:
                      user: auth_email
                      pass: auth_pass
                  )

                  smtpTransport.sendMail(mailOptions, (error, response) ->
                    if error?
                      console.log "Error: ", error
                      req.flash("info", "Oops, something went wrong, please try again later.")
                      res.redirect("/signup")
                    else
                      req.flash("info", "An email has been sent to you. Please open it up and click the activation link.")
                      res.redirect("/")
                  )
              )
            )
        )
      )
  )
)

app.get("/login", (req, res) ->
  res.render("login",
    title: "Login"
    token: req.token
    errors: req.flash("error")
    warnings: req.flash("info")
  )
)

app.post("/login", (req, res, next) ->
  console.log "/login", req.body
  if req.body.rememberme
    hour = 3600000
    req.session.cookie.maxAge = 14 * 24 * hour # 2 weeks
  else
    req.session.cookie.expires = false
  next()
, passport.authenticate("local", {successRedirect: '/', failureRedirect: '/login', failureFlash: true}))

#app.get("/profile", ensureAuthenticated, (req, res) ->
#  res.render("profile",
#    title: "Profile"
#    user:
#      id: req.user.id
#      first: req.user.first
#      last: req.user.last
#      username: req.user.username
#      email: req.user.email
#      verified: req.user.isVerified()
#      authenticated: req.user.isAuthenticated()
#    token: req.token
#    errors: req.flash("error")
#    warnings: req.flash("info")
#  )
#)

app.get("/logout", (req, res) ->
#  l = mongoose.model('Log')
#  if l?
#    l.log(l.LOG_LOGOUT, null, req.method, req)
  req.logout()
  res.redirect("/")
  req.flash("info", "You have successfully logged out!")
)

app.get("/forgot", (req, res) ->
  res.render("forgot",
    title: "Forgot password"
    token: req.token
    errors: req.flash("error")
    warnings: req.flash("info")
  )
)

app.get("/loggedin", (req, res) ->
  res.send(if _app.validUser(req) then [1] else [0])
)

app.get('/api/user/can', (req, res) ->
  if _app.validUser(req) and req.params.action? and req.params.subject?
    req.user.can(req.params.action, req.params.subject, null, (ok) ->
      res.send(if ok then [1] else [0])
    )
  else
    res.send(new Error(403))
)

app.get('/api/user/isadmin', (req, res) ->
  if _app.validUser(req)
    req.user.isAdmin((ok) ->
      res.send(if ok then [1] else [0])
    )
  else
    res.send(new Error(403))
)

app.get('/api/user/isactive', (req, res) ->
  if _app.validUser(req)
    req.user.isActive((ok) ->
      res.send(if ok then [1] else [0])
    )
  else
    res.send(new Error(403))
)

app.get('/api/user/isDisabled', (req, res) ->
  if _app.validUser(req)
    req.user.isDisabled((ok) ->
      res.send(if ok then [1] else [0])
    )
  else
    res.send(new Error(403))
)

app.get('/api/user/islockedout', (req, res) ->
  if _app.validUser(req)
    req.user.isLockedOut((ok) ->
      res.send(if ok then [1] else [0])
    )
  else
    res.send(new Error(403))
)

app.get('/api/user/ispaidplan', (req, res) ->
  if _app.validUser(req)
    req.user.isPaidPlan((ok) ->
      res.send(if ok then [1] else [0])
    )
  else
    res.send(new Error(403))
)

app.get('/api/user/getdata', (req, res) ->
  if _app.validUser(req) and req.params.key?
    req.user.can('read', 'User', null, (ok) ->
      if !ok
        res.send(403)
      else
        res.send([req.user.getData(req.params.key)])
    )
  else
    res.send(new Error(403))
)

app.get('/api/user/setdata', (req, res) ->
  if _app.validUser(req) and req.params.key? and req.params.value?
    req.user.can('write', 'User', null, (ok) ->
      if !ok
        res.send(403)
      else
        req.user.setData(req.params.key, req.params.value)
        res.send([1])
    )
  else
    res.send(new Error(403))
)

secure.secureMethods(exports, {configurable: false})
