order = ((schema, options) ->
  schema.add(
    _order:
      type: Number
      default: 1
  )

  if options && options.index
    schema.path('_order').index(options.index)

  schema.method(
    at: (index, cb) ->
      i = []
      if typeof index is 'number'
        i = [index]
      else if typeof index is 'array'
        i = index

      if i.length
        @model.find({ _order: {$in: i} }).exec((err, indexes) ->
          cb(indexes) if cb
        )
      else
        cb(null) if cb

    insert: (index, count, cb) ->
      @model.update({ _order: {$gte: index} }, {$inc: { _order: count }}, {multi:true}).exec((err) ->
        cb() if cb
      )

    delete: (index, count, cb) ->
      @model.update({ _order: {$gte: index} }, {$dec: { _order: count }}, {multi:true}).exec((err) ->
        cb() if cb
      )

    move: (from, to) ->
      that = @
      at([from, to], (err, ids) ->
        if !err and ids.length == 2
          that.model.update(ids[0].id, {$set: {_order: to}})
          that.model.update(ids[1].id, {$set: {_order: from}})
        cb() if cb
      )

    getFirst: (cb) ->
      @model.find({}, (err, records) ->
        p = null
        po = 1000000
        if records
          for r in records
            if r._order < po
              po = r._order
              p = r
        cb(p) if cb
      )

    getPrev: (cb) ->
      @model.find({}, (err, records) ->
        p = null
        po = 0
        if records
          for r in records
            if r._order < @node._order and r._order > po
              po = r._order
              p = r
        cb(p) if cb
      )

    getNext: (cb) ->
      @model.find({}, (err, records) ->
        p = null
        po = 1000000
        if records
          for r in records
            if r._order > @node._order and r._order < po
              po = r._order
              p = r
        cb(p) if cb
      )

    getLast: (cb) ->
      @model.find({}, (err, records) ->
        p = null
        po = 0
        if records
          for r in records
            if r._order > po
              po = r._order
              p = r
        cb(p) if cb
      )
  )
)

module.exports = order
