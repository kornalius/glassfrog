app = require("../app").app
_app = require("../app")
mongoose = require("../app").mongoose

#app.post("/api/sharenode", (req, res) ->
#  if _app.validUser(req)
#    req.user.can('share', 'Share', null, (ok) ->
#      if ok
#        host = req.query.host
#        node = req.query.node
#        usernames = req.query.users.split(',')
#
#        mongoose.model('User').find({'username': {$in: usernames}}, (err, users) ->
#          userIds = []
#          if users
#            for u in users
#              if req.user.isAdmin() or u.id.toString() != req.user._id.toString()
#                userIds.push(u.id)
#              else
#                res.send(500, 'Cannot share to yourself')
#
#            if userIds.length
#              mongoose.model('Share').share(req.user._id, host, node, userIds, (err, share) ->
#                if err
#                  res.send(500, err.message)
#                else if share
#                  res.send([share._id])
#              )
#            else
#              res.send(500, 'No user(s) found!')
#          else
#            res.send(500, 'Must specify at least one valid user to share with')
#        )
#      else
#        res.send(403)
#    )
#  else
#    res.send(403)
#)
