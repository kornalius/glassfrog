'use strict'

mod = angular.module('rest.services', ['app.globals', 'restangular'])

.config([
  'RestangularProvider'

  (RestangularProvider) ->
    RestangularProvider.setBaseUrl('/api')

    RestangularProvider.setRestangularFields(
      id: "_id"
      selfLink: 'self.link'
    )

])

.factory('Rest', [
  'Globals'
  '$timeout'
  '$resource'
  '$http'
  'Restangular'

  (globals, $timeout, $resource, $http, Restangular) ->

    # Initialization
    Rest = (modelName, url) ->
      @modelName = modelName.toLowerCase().singularize()
      @url = url
      @perPage = 1000
      @page = 1
      @filter = null
      @sort = ['_id']
      @select = null
      @populate = null
      @rows = null
      @total = 0
      @display = 0
      @pages = 1
      @first = 1
      @last = 1
      @prev = 1
      @next = 1
      @firstPage = 1
      @lastPage = 1
      @prevPage = 1
      @nextPage = 1
      @rest = null

      return @

    Rest.prototype =
      fetch: (query, cb) ->
        that = @
        id = null

        if query and typeof query == 'function'
          cb = query
          query = null

        if query and typeof query == "string"
          id = query
          query = null

        if !query
          query = {}

        if @fetchTimeout
          $timeout.cancel(that.fetchTimeout)

        if query.perPage
          that.perPage = query.perPage
        if query.page
          that.page = query.page
        if query.filter
          that.filter = query.filter
        if query.sort
          that.sort = query.sort
        if query.select
          that.select = query.select
        if query.populate
          that.populate = query.populate

        console.log "Rest fetch start...", that

        that.fetchTimeout = $timeout( ->

          if id?

            if that.url?
              that.rest = Restangular.oneUrl(that.modelName, that.url)
              q = {}
            else
              that.rest = Restangular.one(that.modelName, id)
              q = {select: that.select, populate: that.populate}

            p = that.rest.get(q).then((result) ->
              that.total = 1
              that.display = 1
              that.pages = 1
              that.firstPage = 1
              that.lastPage = 1
              that.prevPage = 1
              that.nextPage = 1
              that.first = 1
              that.last = 1
              that.prev = 1
              that.next = 1
              that.rows = [result]

              console.log "Rest fetch end...", that

              cb(result, null) if cb

            , (err) ->
              console.log "Rest fetch end with error...", that, err
              cb(null, err) if cb
            )

          else

            if that.url?
              that.rest = Restangular.allUrl(that.modelName, that.url)
              q = {}
            else
              that.rest = Restangular.all(that.modelName)
              q = {sortField:that.sort, perPage:that.perPage, page:that.page, filter:that.filter, select: that.select, populate: that.populate}

            p = that.rest.getList(q).then((result) ->
              info = result[0]
              if info.total? and info.displayCount? and info.pages?
                that.total = info.total
                that.display = info.displayCount
                that.pages = info.pages
                that.firstPage = info.firstPage
                that.lastPage = info.lastPage
                that.prevPage = info.prevPage
                that.nextPage = info.nextPage
                that.first = info.first
                that.last = info.last
                that.prev = info.prev
                that.next = info.next
                result.shift()
              else
                that.total = result.length
                that.display = result.length
                that.pages = 1
                that.firstPage = 1
                that.lastPage = 1
                that.prevPage = 1
                that.nextPage = 1
                that.first = 1
                that.last = 1
                that.prev = 1
                that.next = 1

              that.rows = result

              console.log "Rest fetch end...", that

              cb(result, null) if cb

            , (err) ->
              console.log "Rest fetch end with error...", that, err
              cb(null, err) if cb
            )

          if that.perPage? and that.perPage > 1
            globals.loadingTracker.addPromise(p)

        , (if that.perPage? and that.perPage > 1 then 250 else 1))

      update: (row, cb) ->
        that = @

        console.log "Rest update start...", that, row._id

        if row.save? and row._id?
          p = row.save().then((result) ->
            x = that.getFromRows(result._id)
            if x != -1
              that.rows[x] = result

            console.log "Rest update end...", that, result._id, result

            cb(result, null) if cb
          , (err) ->
            console.log "Rest update end with error...", that, row._id, err
            cb(null, err) if cb
          )
        else
          console.log "Rest delete end with error...", that, row._id, "no save() method"
          cb(null, null) if cb

#        globals.loadingTracker.addPromise(p)

      delete: (row, cb) ->
        that = @

        console.log "Rest delete start...", that, row._id

        if row.remove? and row._id?
          p = row.remove().then((result) ->
            x = that.getFromRows(row._id)
            if x != -1
              that.rows.splice(x)

            console.log "Rest delete end...", that, result

            cb(result, null) if cb

          , (err) ->
            x = that.getFromRows(row._id)
            if x != -1
              that.rows.splice(x)

            console.log "Rest delete end with error...", that, row._id, err

            cb(null, null) if cb
          )
        else
          console.log "Rest delete end with error...", that, row._id, "no remove() method"
          cb(null, err) if cb

#        globals.loadingTracker.addPromise(p)

      create: (data, onlyOneRow, cb) ->
        that = @

        console.log "Rest create start...", that, data

        if !that.rest
          if onlyOneRow
            that.rest = Restangular.one(that.modelName)
          else
            that.rest = Restangular.all(that.modelName)
        if !that.rows
          that.rows = []

        if that.rest.post?
          p = that.rest.post(data).then((result) ->
            console.log "Rest create end...", that, result._id, result
            cb(result, null) if cb
          , (err) ->
            console.log "Rest create end with error...", that, err
            cb(null, err) if cb
          )
        else
          console.log "Rest create end with error...", that, "no post() method"
          cb(null, null) if cb

#        globals.loadingTracker.addPromise(p)


      createTemp: (data, onlyOneRow, cb) ->
        that = @

        console.log "Rest createTemp start...", that

        p = $http.get('/api/{0}?action=defaults'.format(that.modelName))
        p.success((defaults, status) ->
          data = angular.extend(data, defaults)
          delete data._id

          if !that.rest
            if onlyOneRow
              that.rest = Restangular.one(that.modelName)
            else
              that.rest = Restangular.all(that.modelName)
          if !that.rows
            that.rows = []

          d = Restangular.one(that.modelName, data._id)
          d = angular.extend(d, data)
          console.log "restangularized", d
          that.rows.push(d)
          console.log "Rest createTemp end...", that, d._id, d
          cb(d, null) if cb
        )

        p.error((err) ->
          console.log "Rest createTemp end with error...", that, err
          cb(null, ) if cb
        )

#        globals.loadingTracker.addPromise(p)


      getFromRows: (id) ->
        id = id.toString()
        for i in [0..@rows.length - 1]
          r = @rows[i]
          if r._id? and r._id.toString() == id
            return i
        return -1

    return Rest
])
