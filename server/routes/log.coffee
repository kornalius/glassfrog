app = require("../app").app
_app = require("../app")
mongoose = require("mongoose")
endpoints = require('../endpoints')

app.post("/api/log", endpoints.checkUser, (req, res, next) ->
  console.log "log()", req.query, req.params

  req.user.can('write', 'Log', null, (ok) ->
    if ok
      console.log req.body
      if mongoose.model('Log')?
        if req.user
          id = req.user._id.toString()
        else
          id = 'N/A'
        mongoose.model('Log').log(id, mongoose.model('Log').LOG_REQUEST, req.body, req.method, req.ip, req.url)
    else
      next(new Error(403))
  )
)

app.get("/api/log", endpoints.checkUser, (req, res, next) ->
  next(new Error(403))
)

app.get("/api/log/:id", endpoints.checkUser, (req, res, next) ->
  next(new Error(403))
)

app.put("/api/log/:id", endpoints.checkUser, (req, res, next) ->
  next(new Error(403))
)

app.delete("/api/log/:id", endpoints.checkUser, (req, res, next) ->
  next(new Error(403))
)
