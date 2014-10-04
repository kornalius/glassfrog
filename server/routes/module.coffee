app = require("../app").app
_app = require("../app")
mongoose = require("mongoose")
async = require('async')

app.get("/api/modules", (req, res) ->
  if _app.validUser(req)
    req.user.can('read', 'Module', null, (ok) ->
      if ok
        req.user.modules(true, (modules) ->
          if modules
            async.eachSeries(modules, (m, callback) ->
              m.setExtraFields(req.user._id.toString(), ->
                callback()
              )
            , (err) ->
              res.send(modules).end()
            )
          else
            res.send(modules).end()
        )
      else
        res.status(403).end()
    )
  else
    res.status(403).end()
)

build = (req, cb) ->
  mongoose.model('Module').find({ owner_id: req.user._id.toString(), _id: req.params.id }, (err, m) ->
    if m
      mm = m.toObject()
      require('../vc_module').make(mm)
      syntax = mm.generateCode(false, req.user)
      m.build(syntax, req.user)
      cb() if cb
    else
      cb() if cb
  )

app.put("/api/module/:id", (req, res, next) ->
  console.log "app.put /api/modules"
  next()
  build(req, ->
  )
)

app.post("/api/module/:id", (req, res, next) ->
  console.log "app.post /api/modules"
  next()
  build(req, ->
  )
)
