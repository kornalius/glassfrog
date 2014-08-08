app = require("../app").app
_app = require("../app")
mongoose = require("mongoose")
async = require('async')

app.get("/api/modules", (req, res) ->
  if _app.validUser(req)
    req.user.can('read', 'Module', null, (ok) ->
      if ok
        req.user.modules((modules) ->
          res.send(modules)
        )
      else
        res.send(403)
    )
  else
    res.send(403)
)
