module.exports = ((schema, options) ->

  if options and options.path?
    path = options.path + '.'
  else
    path = ''

  order = path + '_order'

  schema.add(
    _order:
      type: Number
      default: 1
  , path)

  if options && options.index
    schema.path(order).index(options.index)

  schema.method(
    at: (index, cb) ->
      i = []
      if type(index) is 'number'
        i = [index]
      else if type(index) is 'array'
        i = index

      if i.length
        f = {}
        f[order] = {$in: i}
        @model.find(f).exec((err, indexes) ->
          cb(indexes) if cb
        )
      else
        cb(null) if cb

    insert: (index, count, cb) ->
      c = {}
      c[order] = {$gte: index}
      a = {$inc: {}}
      a['$inc'][order] = count
      @model.update(c, a, {multi:true}).exec((err) ->
        cb() if cb
      )

    delete: (index, count, cb) ->
      c = {}
      c[order] = {$gte: index}
      a = {$dec: {}}
      a['$dec'][order] = count
      @model.update(c, a, {multi:true}).exec((err) ->
        cb() if cb
      )

    move: (from, to) ->
      that = @
      at([from, to], (err, ids) ->
        if !err and ids.length == 2
          t = {$set: {}}
          t['$set'][order] = to
          f = {$set: {}}
          f['$set'][order] = from
          that.model.update(ids[0].id, t)
          that.model.update(ids[1].id, f)
        cb() if cb
      )

    getFirst: (cb) ->
      @model.find({}, (err, records) ->
        p = null
        po = 1000000
        if records
          for r in records
            if r[order] < po
              po = r[order]
              p = r
        cb(p) if cb
      )

    getPrev: (cb) ->
      @model.find({}, (err, records) ->
        p = null
        po = 0
        if records
          for r in records
            if r[order] < @[order] and r[order] > po
              po = r[order]
              p = r
        cb(p) if cb
      )

    getNext: (cb) ->
      @model.find({}, (err, records) ->
        p = null
        po = 1000000
        if records
          for r in records
            if r[order] > @[order] and r[order] < po
              po = r[order]
              p = r
        cb(p) if cb
      )

    getLast: (cb) ->
      @model.find({}, (err, records) ->
        p = null
        po = 0
        if records
          for r in records
            if r[order] > po
              po = r[order]
              p = r
        cb(p) if cb
      )
  )
)
