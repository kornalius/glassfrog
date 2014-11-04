app = require("../app").app
_app = require("../app")
mongoose = require("mongoose")
async = require('async')
endpoints = require('../endpoints')
fs = require('fs')

app.get("/api/modules", endpoints.checkUser, (req, res, next) ->
  console.log "modules()", req.query, req.params

  req.user.can('read', 'Module', null, (ok) ->
    if ok
      req.user.modules(true, (modules) ->
        if modules
          endpoints.send({results:modules, model:mongoose.model('Module'), asArray:true}, req, res)
        else
          next(new Error(404, 'no modules found'))
      )
    else
      next(new Error(403))
  )
)

#build = (req, res, next) ->
#  console.log "build()", req.query, req.params
#
#  mongoose.model('Module').findOne({ owner_id: req.user._id.toString(), _id: req.params.id }, (err, m) ->
#    if m and m.toObject
#      mm = m.toObject()
#      require('../vc_module').make(mm)
#
#      m.deleteBuiltFiles(req.user, (err) ->
#        serverSyntax = mm.generateCode(false, req.user)
#        if serverSyntax.error
#          next(new Error(204, serverSyntax.error.message))
#          return
#
#        else
#          clientSyntax = mm.generateCode(true, req.user)
#          if clientSyntax.error
#            next(new Error(204, clientSyntax.error.message))
#            return
#
#        m.build(serverSyntax, req.user, false, (err) ->
#          if !err
#            m.build(clientSyntax, req.user, true, (err) ->
#              next(err)
#            )
#          else
#            next(err)
#        )
#      )
#
#  )
#
#setModel = (req, res, next) ->
#  console.log "setModel()", req.query, req.params
#
#  _app.model('Module', req, (m, plan, c, prefix) ->
#    if m
#      req.m = m
#      req.plan = plan
#      req.c = c
#      req.prefix = prefix
#      next()
#    else
#      next(new Error(404, 'model not found'))
#  )
#
#app.put("/api/module/:id", endpoints.checkUser, setModel, endpoints.update, build, (req, res, next) -> )
#
#app.post("/api/module/:id", endpoints.checkUser, setModel, endpoints.update, build, (req, res, next) -> )
