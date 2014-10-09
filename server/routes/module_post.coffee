app = require("../app").app
_app = require("../app")
mongoose = require("mongoose")
async = require('async')

build = (req, cb) ->
  mongoose.model('Module').findOne({ owner_id: req.user._id.toString(), _id: req.params.id }, (err, m) ->
    if m and m.toObject
      mm = m.toObject()
      require('../vc_module').make(mm)
      syntax = mm.generateCode(false, req.user)
      m.build(syntax, req.user)
      cb() if cb
    else
      cb() if cb
  )

app.put("/api/module/:id", (req, res, next) ->
  console.log "app.put(post) /api/module"
  build(req, ->
    next()
  )
)

app.post("/api/module/:id", (req, res, next) ->
  console.log "app.post(post) /api/module"
  build(req, ->
    next()
  )
)
