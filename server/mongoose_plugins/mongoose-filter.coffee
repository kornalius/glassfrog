module.exports = ((schema, options) ->

  toJSON = schema.methods.toJSON

  schema.methods.toJSON = () ->
    args = Array.prototype.concat.apply(this, arguments)
    return filter.apply(this.constructor, args)


  filter = schema.statics.filter = (doc, options) ->

    options = _.extend({}, DEFAULT_OPTIONS, (if options then options else {}))
    options.keep = _.union({}, DEFAULT_OPTIONS.keep, (if options.keep then options.keep else []))
    options.remove = _.union({}, DEFAULT_OPTIONS.remove, (if options.remove then options.remove else []))

    if !doc and toJSON
      obj = toJSON.apply(doc, options)
    else if doc and doc.toObject
      obj = doc.toObject.apply(doc, options)
    else
      obj = doc

#    console.log doc, getPathsToRemove(schema, options)
    return nestedOmit(obj, getPathsToRemove(schema, options), options)
)

nestedOmit = (obj, paths, options) ->
  return _.reduce(obj, (memo, value, key) ->
    p = paths[key]

    if _.isObject(p)
      if _.isArray(value)
        memo[key] = _.map(value, (v) ->
          return nestedOmit(v, p, options)
        )
      else if _.isObject(value)
        t = nestedOmit(value, p, options)
        !_.isEmpty(t) && (memo[key] = t);

    else if p == false or (!options.mustExists and !p)
      memo[key] = value

    return memo

  , {})

#toPaths = (arr) ->
#  return _.reduce(arr, (memo, v) ->
#    memo[v] = true
#    return memo
#  , {})

getPathsToRemove = (schema, options) ->
  return _.reduce(schema.tree, (memo, node, path) ->
    memo[path] = shouldRemovePath(node, path, options)
    return memo
  , {})

shouldRemovePath = (node, path, options) ->
  if !node
    return false

  if node instanceof Array
    f = _.first(node)
    if f and f.tree
      return getPathsToRemove(f, options)
    else
      return shouldRemovePath(f, path, options)

  else if _.isObject(node) and !node.type and !node.getters and global.type(node) != 'function'
    o = getPathsToRemove({ tree: node }, options)
    return (if _.isEmpty(o) then false else o)

  else
    if path and _.contains(options.remove, path)
      return true
    else if path and _.contains(options.keep, path)
      return false
    else if path and path.startsWith(options.prefix)
      return true
    else
      return false

DEFAULT_OPTIONS =
  prefix: '_'
  keep: ['_id', '__v']
  remove: ['id']
  mustExists: false
