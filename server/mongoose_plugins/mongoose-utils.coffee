module.exports.populate_deep = (model, instance, path, opts, cb) ->
  model.populate(instance, opts, (err, o) ->
    if o[path]?
      populate_deep(model, o, path, opts, (err, o) -> cb(err, o) if cb)
    else
      cb(err, o) if cb
  )
