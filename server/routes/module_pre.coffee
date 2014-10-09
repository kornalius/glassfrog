app = require("../app").app
_app = require("../app")
mongoose = require("mongoose")
async = require('async')

app.get("/api/modules", (req, res) ->
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
