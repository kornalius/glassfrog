app = require("../app").app
_app = require("../app")
mongoose = require("mongoose")
async = require('async')
endpoints = require('../endpoints')

app.get("/api/modules", endpoints.checkUser, (req, res) ->
  console.log "modules()", req.query, req.params

  endpoints = require('../endpoints')
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
              endpoints.send(req, res, {results:modules, model:mongoose.model('Module'), asArray:true})
            )

          else
            endpoints.send(req, res, new Error(404, 'no modules found'))
        )

      else
        endpoints.send(req, res, 403)
    )

  else
    endpoints.send(req, res, 403)
)

build = (req, req, next) ->
  console.log "build()", req.query, req.params

  mongoose.model('Module').findOne({ owner_id: req.user._id.toString(), _id: req.params.id }, (err, m) ->
    if m and m.toObject
      mm = m.toObject()
      require('../vc_module').make(mm)
      syntax = mm.generateCode(false, req.user)
      m.build(syntax, req.user)
      next()
    else
      endpoints.send(404)
  )

app.put("/api/module/:id", endpoints.checkUser, endpoints.checkModel, build, (req, res, next) ->
)

app.post("/api/module/:id", endpoints.checkUser, endpoints.checkModel, build, (req, res, next) ->
)
