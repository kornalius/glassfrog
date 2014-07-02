app = require("../app").app
_app = require("../app")
mongoose = require("../app").mongoose
async = require('async')

app.get("/api/components", (req, res) ->
  if _app.validUser(req)
    req.user.can('read', 'Component', null, (ok) ->
      if ok
        mongoose.model('Component').find({}, (err, components) ->
          if components
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
