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
              if c.extra
                e = JSON.parse(c.extra)
                if e.code and e.code.server
                  delete e.code.server
                  c.extra = JSON.stringify(e)
            res.send(components)
          else
            res.send(403)
        )
      else
        res.send(403)
    )
  else
    res.send(403)
)

app.put("/api/components", (req, res) ->
  res.send(403)
)

app.post("/api/components", (req, res) ->
  res.send(403)
)

app.delete("/api/components", (req, res) ->
  res.send(403)
)
