app = require("../app").app
_app = require("../app")
mongoose = require("mongoose")
async = require('async')

app.get("/api/components", (req, res) ->
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
            res.send(components).end()
          else
            res.status(403).end()
        )
      else
        res.status(403).end()
    )
  else
    res.status(403).end()
)

app.put("/api/components", (req, res) ->
  res.status(403).end()
)

app.post("/api/components", (req, res) ->
  res.status(403).end()
)

app.delete("/api/components", (req, res) ->
  res.status(403).end()
)
