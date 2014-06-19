'use strict'

mod = angular.module('rest.services', ['app.globals'])

.factory('Rest', [
  'Globals'
  '$timeout'
  '$resource'
  '$http'

  (globals, $timeout, $resource, $http) ->

    # Initialization
    Rest = (modelName) ->
      @modelName = modelName
      @perPage = 1000
      @page = 1
      @filter = null
      @sort = ['_id']
      @select = null
      @populate = null
      @rows = []
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

      @fetchTimeout = null
      @resource = $resource('/api/{0}/:id'.format(modelName), { id: '@_id' }, { 'update': { method:'PUT' } })
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
            p = that.resource.get({id: id}, {select: that.select, populate: that.populate}, (result) ->
              result.$data = {}
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
            )

          else

            p = that.resource.query({sort:that.sort, perPage:that.perPage, page:that.page, filter:that.filter, select: that.select, populate: that.populate}, (result) ->
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
            )

          globals.loadingTracker.addPromise(p.$promise)
        , 250)

      update: (row, cb) ->
        that = @

        c = that.resource.update

        console.log "Rest update start...", that

        oData = row.$data
        delete row.$data

        p = c(row, (result) ->
          console.log "Rest update end...", that
          cb(result) if cb
        )

        row.$data = oData

        globals.loadingTracker.addPromise(p.$promise)

      delete: (row, cb) ->
        that = @

        console.log "Rest delete start...", that

        if that.$remove?
          c = that.$remove
        else
          c = that.resource.remove

        oData = row.$data
        delete row.$data

        p = c(row, (result) ->
          x = that.getFromRows(id)
          if x != -1
            that.rows.splice(x, 1)
          console.log "Rest delete end...", that
          cb(result) if cb
        )

        row.$data = oData

        globals.loadingTracker.addPromise(p.$promise)

      push: (row, cb) ->
        that = @

        console.log "Rest push start...", that

        r = $resource('/api/{0}'.format(@modelName), {}, {})

        oData = row.$data
        delete row.$data

        p = r.save(row, (results) ->
          console.log "Rest push end...", that
          cb(results) if cb
#          that.fetchAll()
        )

        row.$data = oData

        globals.loadingTracker.addPromise(p.$promise)

      new: (cb) ->
        that = @

        p = $http.get('/api/{0}/defaults'.format(@modelName))

        p.success((data, status) ->
          that.rows = [data]
          cb(data) if cb
        )

        p.error((data, status) ->
          cb(null) if cb
        )

        globals.loadingTracker.addPromise(p)

      getFromRows: (id) ->
        id = id.toString()
        for r in @rows
          if r.id.toString() == id
            return r
        return null

    return Rest
])
