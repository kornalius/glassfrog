app = require("../app").app
_app = require("../app")
mongoose = require("mongoose")
async = require('async')
endpoints = require('../endpoints')

app.get("/api/components", endpoints.checkUser, (req, res, next) ->
  if _app.validUser(req)
    req.user.can('read', 'Component', null, (ok) ->
      if ok
        mongoose.model('Component').find({}, (err, components) ->
          if components
            # Remove all server/client codes
            for c in components
              if c.extra and type(c.extra) is 'string'
                e = stringToJson(c.extra)
                if e.code
                  ok = false
                  for k of e.code
                    if _.contains(['client', 'server', 'client_server'], k)
                      ok = true
                      delete e.code[k]
                  if ok
                    c.extra = jsonToString(e)
            endpoints.send({results: components, model: mongoose.model('Component'), asArray: true}, req, res)
          else
            next(new Error(404, 'no components found'))
        )
      else
        next(new Error(403))
    )
  else
    next(new Error(403))
)

app.put("/api/component/:id", endpoints.checkUser, (req, res, next) ->
  next(new Error(403))
)

app.post("/api/component", endpoints.checkUser, (req, res, next) ->
  next(new Error(403))
)

app.delete("/api/component/:id", endpoints.checkUser, (req, res, next) ->
  next(new Error(403))
)
