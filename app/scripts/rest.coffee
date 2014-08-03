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
    Rest = (modelName) ->
      @modelName = modelName
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
            that.rows = Restangular.one(that.modelName, id)
            p = that.rows.get({select: that.select, populate: that.populate}).then((result) ->
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

              cb(result) if cb

            , (err) ->
              console.log "Rest fetch end with error...", that, err

              cb(null) if cb
            )

          else

            that.rows = Restangular.all(that.modelName)
            p = that.rows.getList({sort:that.sort, perPage:that.perPage, page:that.page, filter:that.filter, select: that.select, populate: that.populate}).then((result) ->
              info = result[0]
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
              that.rows = result

              console.log "Rest fetch end...", that

              cb(result) if cb

            , (err) ->
              console.log "Rest fetch end with error...", that, err

              cb(null) if cb
            )

          globals.loadingTracker.addPromise(p)

        , 250)

      update: (row, cb) ->
        that = @

        console.log "Rest update start...", that

        p = row.save().then((result) ->
          x = that.getFromRows(result._id)
          if x != -1
            that.rows[x] = result

          console.log "Rest update end...", that, result

          cb(result) if cb
        )

        globals.loadingTracker.addPromise(p)

      delete: (row, cb) ->
        that = @

        console.log "Rest delete start...", that

        p = row.remove().then((result) ->
          x = that.getFromRows(row._id)
          if x != -1
            that.rows.splice(x)

          console.log "Rest delete end...", that, result

          cb(result) if cb

        , (err) ->
          x = that.getFromRows(row._id)
          if x != -1
            that.rows.splice(x)

          console.log "Rest delete end with error...", that, err

          cb(null) if cb
        )

        globals.loadingTracker.addPromise(p)

      create: (data, cb) ->
        that = @

        console.log "Rest create start...", that

        if !that.rows
          that.rows = Restangular.all(that.modelName)

        p = that.rows.post(data).then((result) ->
          console.log "Rest create end...", that
          cb(result) if cb
        , (err) ->
          console.log "Rest create end with error...", that, err
          cb(null) if cb
        )

        globals.loadingTracker.addPromise(p)


      createTemp: (data, cb) ->
        that = @

        console.log "Rest createTemp start...", that

        p = $http.get('/api/{0}/defaults'.format(that.modelName))

        p.success((defaults, status) ->

          data = angular.extend(data, defaults)
          delete data._id

          if !that.rows
            that.rows = Restangular.all(that.modelName)

          d = Restangular.one(that.modelName, data._id)
          d = angular.extend(d, data)
          console.log "restangularized", d
          that.rows.push(d)
          console.log "Rest create end...", that, d
          cb(d) if cb
        )

        p.error((err) ->
          console.log "Rest create end with error...", that, err
          cb(null) if cb
        )

        globals.loadingTracker.addPromise(p)


      getFromRows: (id) ->
        id = id.toString()
        for i in [0..@rows.length - 1]
          r = @rows[i]
          if r._id? and r._id.toString() == id
            return i
        return -1

    return Rest
])
