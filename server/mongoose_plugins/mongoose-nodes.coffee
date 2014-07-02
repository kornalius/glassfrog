nodes = ((schema, options) ->
  schema.add(
    nodes:
      type: String
      label: 'Nodes'
  )

  if options && options.index
    schema.path('nodes').index(options.index)

#  schema.virtual('nodes').get( ->
#    nodes = JSON.parse(@_nodes)
#    newNodes = []
#    for n in nodes
#      newNodes.push(new Node(n))
#    return newNodes
#  )
#
#  schema.virtual('nodes').set((nodes) ->
#    if typeof nodes is 'string'
#      @_nodes = nodes
#    else
#      @_nodes = JSON.stringify(nodes)
#  )
)

module.exports = nodes
