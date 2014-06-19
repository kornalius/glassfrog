app = require("../app")
mongoose = require("../app").mongoose
timestamps = require('mongoose-time')()
findOrCreate = require('mongoose-findorcreate')
materialized = require('mongoose-materialized')
version = require('../mongoose_plugins/mongoose-version')
order = require('../mongoose_plugins/mongoose-order')
utils = require('../lib/mongoose-utils')
async = require('async')
ownable = require('mongoose-ownable')
Node_Data = require("../app").Node_Data

Component = require('./component')

NodeSchema = mongoose.Schema(
  name:
    type: String
    index: true
    trim: true
    label: 'Name'

  component:
    type: mongoose.Schema.ObjectId
    ref: 'Component'
    label: 'Component'

  icon:
    type: String
    label: 'Icon'

  color:
    type: String
    label: 'Color'

  _options:
    type: String
    default: ''  # s:system, h:shared, l: node_link, *:sharing
    label: 'Options'
    readOnly: true
,
  label: 'Nodes'
)

NodeSchema.plugin(timestamps)
NodeSchema.plugin(findOrCreate)
NodeSchema.plugin(materialized)
NodeSchema.plugin(version)
NodeSchema.plugin(order)
NodeSchema.plugin(ownable)

#NodeSchema.pre('save', (next) ->
#  if Node_Data and Node_Data.rest
#    n = Node_Data.getNodeById(@id)
#    if !n
#      Node_Data.rest.rows.push(Node_Data.makeNode(@))
##      console.log "add node", @id, Node_Data.rest.rows.length, "[", Node_Data.rest.rows.map((n) -> n._id).join(','), "]"
#  next()
#)

#NodeSchema.pre('remove', (next) ->
#  if Node_Data and Node_Data.rest
#    n = Node_Data.getNodeById(@id)
#    if n
#      Node_Data.rest.rows.splice(Node_Data.rest.rows.indexOf(n))
#  next()
#)

NodeSchema.method(
  populateFields: (cb) ->
    @populate('component owner_id', (err) ->
      cb() if cb
    )

  getRoot: (cb) ->
    @getAncestors((err, ancestors) ->
      if ancestors and ancestors.length
        cb(ancestors[0]) if cb
      else
        cb(null) if cb
    )

  getConnection: (cb) ->
    @populate('owner_id', (owner) ->
      if owner
        owner.getConnection((plan, c, prefix) ->
          cb(plan, c, prefix) if cb
        )
      else
        cb(null, null, '') if cb
    )

  model: (name, cb) ->
    @getConnection((plan, c, prefix) ->
      if c
        m = c.model(prefix + name)
      else
        m = null
      cb(m) if cb
    )
)

NodeSchema.static(
  findByName: (n, cb) ->
    mongoose.model('Node').where('name').regex(new RegExp(n, "i")).populate('component').find((err, c) ->
      cb(c) if cb
    )

  findByComponent: (n, cb) ->
    N = mongoose.model('Node')
    if typeof n is 'string'
      N.populate('component').where('component.name').regex(new RegExp(n, "i")).find((err, c) ->
        cb(c) if cb
      )
    else if typeof n is 'number'
      N.where('component').equals(n).populate('component').find((err, c) ->
        cb(c) if cb
      )
    else if typeof n is 'object'
      N.where('component').equals(n.id).populate('component').find((err, c) ->
        cb(c) if cb
      )
    else
      cb(null) if cb

  nodes: (userId, cb) ->
    console.log "Loading nodes for user {0}...".format(userId)
    r = []
    mongoose.model('Node').find({owner_id: userId}, (err, nodes) ->
      if nodes
        for n in nodes
          Node_Data.makeNode(n)
          r.push(n)
      mongoose.model('Share').find({ $and: [{'users.user': userId}, {'users.state': 'active'}] }, (err, shares) ->
        if shares
          ids = []
          for s in shares
            ids.push(s.node)
          mongoose.model('Node').GetTree({id: {$in: ids}}, (err, nodes) ->
            if nodes
              for n in nodes
                Node_Data.makeNode(n)
                r.push(n)
            console.log "Loaded {0} nodes for user {1}".format(r.length, userId)
            cb(r) if cb
          )
        else
          cb(null) if cb
      )
    )

  allNodes: (cb) ->
    console.log "Loading all nodes..."
    mongoose.model('Node').find({}, (err, nodes) ->
      if !nodes
        nodes = []
      for n in nodes
        Node_Data.makeNode(n)
      console.log "Loaded {0} nodes".format(nodes.length)
      cb(nodes) if cb
    )

)

module.exports = mongoose.model('Node', NodeSchema)

setTimeout( ->
  data = [
    _order: 0
    _options: 's'
    name: 'root'
    component: 'Root'
    children: [
      _order: 0
      _options: 's'
      name: 'Projects'
      component: 'Projects'
      children: [
        _order: 0
        name: 'Module'
        component: 'Module'
        children: [
          _order: 0
          name: 'Schema'
          component: 'Schema'
          children: [
            _order: 0
            name: 'Name'
            component: 'Field'
            children: [
              _order: 0
              component: 'Text'
            ,
              _order: 1
              component: 'Required'
            ,
              _order: 2
              component: 'Bold'
            ,
              _order: 3
              component: 'Red'
            ]
          ,
            _order: 1
            name: 'Age'
            component: 'Field'
            children: [
              _order: 0
              component: 'Number'
            ,
              _order: 1
              component: 'Italic'
            ]
          ]
        ,
          _order: 1
          name: 'Page'
          component: 'Page'
          children: [
            _order: 0
            name: 'View 1'
            component: 'View'
            children: [
              _order: 0
              name: 'Button'
              component: 'Button'
            ]
          ,
            _order: 1
            name: 'View 2'
            component: 'View'
            children: [
              _order: 0
              name: 'Table'
              component: 'Table'
            ]
          ]
        ]
      ]
    ,
      _order: 2
      _options: 's'
      name: 'Shared Modules'
      component: 'SharedModules'
    ]
  ]

  N = mongoose.model('Node')

  N.remove({}, (err) ->

#    if Node_Data.rest
#      Node_Data.rest.rows = []

    root = null
    owner = null

    createRecord = (c, parentRecord, cb) ->
      N.create({_order: c._order, _options: c._options, name: c.name, icon: (if c.icon then c.icon else null), color: (if c.color then c.color else null), parentId: (if parentRecord then parentRecord.id else null), owner_id: owner}, (err, pr) ->
#        console.log err, pr
        if pr
          if c.component
            mongoose.model('Component').findByName(c.component, (err, component) ->
              if component
                pr.component = component.id
                pr.save((err, pr) ->
                  if pr and !root
                    root = pr._id
                )

              createChildren(c, pr, ->
                cb() if cb
              )
            )
          else
            cb() if cb
        else
          cb() if cb
        )

    createChildren = (parent, parentRecord, cb) ->
      if parent and parent.children
        async.eachSeries(parent.children, (c, callback) ->
          createRecord(c, parentRecord, ->
            callback()
          )
        , (err) ->
          cb() if cb
        )
      else
        cb() if cb

    mongoose.model('User').find({}, (err, users) ->
      if users
        owner = users[0].id
        users[0].root = root
        users[0].save()
        async.eachSeries(data, (c, callback) ->
          createRecord(c, null, ->
            callback()
          )
        , (err) ->
          mongoose.model('Component').components(() ->
            mongoose.model('Node').nodes()
          )
        )
    )
  )

, 1000)
