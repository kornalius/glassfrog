app = require("../app").app
_app = require("../app")
mongoose = require("../app").mongoose
async = require('async')

app.get("/api/node/objectid", (req, res) ->
  if _app.validUser(req)
    req.user.can('read', 'Node', null, (ok) ->
      if ok
        N = mongoose.model('Node')
        o = new N()
        res.send([o._id])
      else
        res.send(403)
    )
  else
    res.send(403)
)

app.get("/api/nodes", (req, res) ->
  if _app.validUser(req)
    req.user.can('read', 'Node', null, (ok) ->
      if ok
        mongoose.model('Node').nodes(req.user._id, (nodes) ->
          res.send(nodes)
        )
      else
        res.send(403)
    )
  else
    res.send(403)
)

#app.get("/api/node/getowner/:id", (req, res) ->
#  if req.params.id?
#    mongoose.model('Node').findById(req.params.id, (err, node) ->
#      if node
#        node.getOwner((owner) ->
#          if owner
#            res.send([owner.id])
#          else
#            res.send([0])
#        )
#      else
#        res.send([0])
#    )
#  else
#    res.send([0])
#)
