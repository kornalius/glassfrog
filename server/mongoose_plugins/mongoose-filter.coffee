module.exports = ((schema, options) ->

  toJSON = schema.methods.toJSON

  filter = schema.statics.filter = (doc, options, type) ->
#    args = Array.prototype.slice.call(arguments, 1)

    types = type.split(',')

    if !options
      options = {}

    options = _.extend({}, DEFAULT_OPTIONS, options)

    if !options.ignore
      options.ignore = []
    if !options.remove
      options.remove = []

    if 'readOnly' in types
      options.remove = _.union(['_id', 'created_at', 'update_at'], DEFAULT_OPTIONS.remove, options.remove)

    if 'private' in types
      options.ignore = _.union(['id'], DEFAULT_OPTIONS.ignore, options.ignore)

    if type?
      paths = getPaths(type, schema, options)
    else
      paths = []

    if !doc and toJSON
      obj = toJSON.apply(doc, options)
    else if doc and doc.toObject
      obj = doc.toObject.apply(doc, options)
    else
      obj = doc

    keep = options.keep
    remove = options.remove

    if keep
      return nestedOmit(obj, _.omit(paths, keep), options)

    else if remove
      return nestedOmit(obj, toPaths(_.isArray(remove) ? remove : [remove]), options)

    return nestedOmit(obj, paths, options)

  schema.methods.toJSON = () ->
    args = Array.prototype.concat.apply(this, arguments)
    args.push('private')
    return filter.apply(this.constructor, args)
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

toPaths = (arr) ->
  return _.reduce(arr, (memo, v) ->
    memo[v] = true
    return memo
  , {})

getPaths = (type, schema, options) ->
  return _.reduce(schema.tree, (memo, node, path) ->
    memo[path] = isPath(type, options, node, path)
    return memo
  , {})

isPath = (type, options, node, path) ->
  if !node
    return false

  if node instanceof Array
    f = _.first(node)
    if f and f.tree
      return getPaths(type, f, {})
    else
      return isPath(type, options, f, path)

  else if _.isObject(node) and !node.type and !node.getters and global.type(node) != 'function'
    o = getPaths(type, { tree: node }, {})
    return (if _.isEmpty(o) then false else o)

  else if _.contains(options.ignore, path)
    return false

  else
    for t in type.split(' ')
      if node[t] == true
        return true
    return path[0] == options.prefix

DEFAULT_OPTIONS =
  prefix: '_'
  ignore: []
  remove: ['id']
  virtuals: true
