app = require("../app").app
_app = require("../app")
mongoose = require("mongoose")
async = require('async')

app.get("/api/components", (req, res) ->
  endpoints = require('../endpoints')
  if _app.validUser(req)
    req.user.can('read', 'Component', null, (ok) ->
      if ok
        mongoose.model('Component').find({}, (err, components) ->
          if components
            # Remove all server codes
            for c in components
              if c.extra and type(c.extra) is 'string'
                e = stringToJson(c.extra)
                if e.code and e.code.server
                  delete e.code.server
                  c.extra = jsonToString(e)
            endpoints.send(req, res, {results:components, model:mongoose.model('Component'), asArray:true})

          else
            endpoints.send(req, res, new Error(404, 'no components found'))
        )

      else
        endpoints.send(req, res, 403)
    )

  else
    endpoints.send(req, res, 403)
)

app.put("/api/component", (req, res) ->
  endpoints = require('../endpoints')
  endpoints.send(req, res, 403)
)

app.post("/api/component", (req, res) ->
  endpoints = require('../endpoints')
  endpoints.send(req, res, 403)
)

app.delete("/api/component", (req, res) ->
  endpoints = require('../endpoints')
  endpoints.send(req, res, 403)
)
