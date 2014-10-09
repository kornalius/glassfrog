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

#    RestangularProvider.addResponseInterceptor((data, operation, what) ->
#      console.log data, operation, what
#      if operation == 'getList'
#        return data.results
#      return data
#    )

#    RestangularProvider.setErrorInterceptor((response, deferred, responseHandler) ->
#      return true
#    )

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
      @rows = null
      @l = 10 #limit
      @sk = 0 #skip
      @q = null #query
      @sort = ['_id']
      @s = null #select
      @p = null #populate
      @total = 0 #total rows in table
      @display = 0 #count of rows received
      @pages = 1 #number of pages
      @first = 1
      @last = 1
      @prev = 1
      @next = 1
      @firstPage = 1
      @lastPage = 1
      @prevPage = 1
      @nextPage = 1
      @rest = null
      @schema = {}
      @status = null
      @err = null
      return @

    Rest.prototype =

      setDefaults: (options) ->
        if options.q
          @q = options.q

        if options.l
          @l = options.l

        if options.sk
          @sk = options.sk
        else if options.page
          @sk = (options.page - 1) * @l

        if options.sort
          @sort = options.sort

        if options.s
          @s = options.s

        if options.p
          @p = options.p


      findRowIndexById: (_id) ->
        _id = _id.toString()
        for i in [0..@rows.length - 1]
          r = @rows[i]
          if r._id? and r._id.toString() == _id
            return i
        return -1


      findRowById: (_id) ->
        i = @findRowIndexById(_id)
        if i != -1
          return @rows[i]
        else
          return null


      find: (options, cb) ->
        that = @

        if @fetchTimeout
          $timeout.cancel(that.fetchTimeout)

        console.log "Rest find start...", that

        q = (if options.query then options.q else that.q)
        l = (if options.l then options.l else that.l)
        if options.page
          sk = (options.page - 1) * l
        else
          sk = (if options.sk then options.sk else that.sk)
        s = (if options.s then options.s else that.s)
        p = (if options.p then options.p else that.p)
        sort = (if options.sort then options.sort else that.sort)

        that.q = q
        that.l = l
        that.sk = sk
        that.s = s
        that.p = p
        that.sort = sort

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

        if that.url?
          that.rest = Restangular.allUrl(that.modelName, that.url)
          query = {}
        else
          that.rest = Restangular.all(that.modelName)
          query = {q:q, sort:sort, l:l, sk:sk, s:s, p:p}

        that.fetchTimeout = $timeout( ->
          p = that.rest.getList(query).then((result) ->
            if result and result.length
              info = result[0]
              that.status = info.status
              that.err = info.err

              if info.status == 'ok'
                if info.__p
                  that.total = info.total
                  that.display = info.displayCount
                  that.page = info.page
                  that.pages = info.pages
                  that.page = info.page
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
                console.log "Rest find end...", that
                cb(result, null) if cb

              else
                if info.err
                  err = new Error(info.err.code, info.err.message)
                else
                  err = new Error(500)
                console.log "Rest find end with error...", that, err
                cb(null, err) if cb

            else
              console.log "Rest find end with error...", that, "no result provided from server"
              cb(null, new Error('no result provided from server')) if cb

          , (err) ->
            console.log "Rest find end with error...", that, err
            cb(null, err) if cb
          )

        , 250)


      findById: (_id, cb) ->
        that = @

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

        console.log "Rest findById start...", that

        if that.url?
          that.rest = Restangular.oneUrl(that.modelName, that.url)
          query = {}
        else
          that.rest = Restangular.one(that.modelName, _id)
          query = {s: that.s, p: that.p}

        p = that.rest.get(query).then((result) ->
          if result
            that.status = result.status
            that.err = result.err
            delete result.status
            delete result.err
            if that.status == 'ok'
              that.rows = [result]
              console.log "Rest findById end...", that
              cb(result, null) if cb

            else
              if that.err
                err = new Error(that.err.code, that.err.message)
              else
                err = new Error(500)
              console.log "Rest findById end with error...", that, err
              cb(null, err) if cb

          else
            console.log "Rest update end with error...", that, "no result provided from server"
            cb(null, new Error('no result provided from server')) if cb

        , (err) ->
          console.log "Rest findById end with error...", that, err
          cb(null, err) if cb
        )


      create: (row, cb) ->
        that = @

        if !cb and type(row) is 'function'
          cb = row
          row = null

        temp = !row or _.keys(row).length == 0

        console.log "Rest create start...", that, row

        if !that.rest
          if that.url?
            that.rest = Restangular.oneUrl(that.modelName, that.url)
          else
            that.rest = Restangular.one(that.modelName)
        if !that.rows
          that.rows = []

        if temp
          p = $http.get('/api/{0}/defaults'.format(that.modelName)).success((result) ->
            if result
              that.status = result.status
              that.err = result.err
              delete result.status
              delete result.err
              if that.status == 'ok'
                defaults = result
                Restangular.restangularizeElement('', defaults, that.modelName, false)
                that.rows.push(defaults)
                console.log "Rest create temp end...", that, defaults
                cb(defaults, null) if cb

              else
                if that.err
                  err = new Error(that.err.code, that.err.message)
                else
                  err = new Error(500)
                console.log "Rest create end with error...", that, err
                cb(null, err) if cb

            else
              console.log "Rest create end with error...", that, "no result provided from server"
              cb(null, new Error('no result provided from server')) if cb

          ).error((err) ->
            console.log "Rest create temp end with error...", that, err
            cb(null, null) if cb
          )

        else

          if that.rest.post?
            p = that.rest.post(row).then((result) ->
              if result
                that.status = result.status
                that.err = result.err
                delete result.status
                delete result.err
                if that.status == 'ok'
                  that.rows.push(result)
                  console.log "Rest create end...", that, result
                  cb(result, null) if cb

                else
                  if that.err
                    err = new Error(that.err.code, that.err.message)
                  else
                    err = new Error(500)
                  console.log "Rest create end with error...", that, err
                  cb(null, err) if cb

              else
                console.log "Rest create end with error...", that, "no result provided from server"
                cb(null, new Error('no result provided from server')) if cb

            , (err) ->
              console.log "Rest create end with error...", that, err
              cb(null, err) if cb
            )

          else
            console.log "Rest create end with error...", that, "no post method found"
            cb(null, new Error('no post method found')) if cb


      update: (row, cb) ->
        that = @

        if !row
          console.log "Rest update error, missing row", that
          return

        console.log "Rest update start...", that, row

        if row.save?
          p = row.save().then((result) ->
            if result
              that.status = result.status
              that.err = result.err
              delete result.status
              delete result.err
              if that.status == 'ok'
                x = that.findRowIndexById(result._id.toString())
                if x != -1
                  if that.rows[x].plain?
                    r = that.rows[x].plain()
                  else
                    r = that.rows[x]
                  for k of r
                    that.rows[x][k] = result[k]
                console.log "Rest update end...", that, result
                cb(that.rows[x], null) if cb

              else
                if that.err
                  err = new Error(that.err.code, that.err.message)
                else
                  err = new Error(500)
                console.log "Rest update end with error...", that, err
                cb(null, err) if cb

            else
              console.log "Rest update end with error...", that, row, "no result provided from server"
              cb(null, new Error('no result provided from server')) if cb

          , (err) ->
            console.log "Rest update end with error...", that, row, err
            cb(null, err) if cb
          )

        else
          console.log "Rest update end with error...", that, row, "no save method found"
          cb(null, new Error('no save method found')) if cb


      remove: (row, cb) ->
        that = @

        if !row
          console.log "Rest remove error, missing row", that
          return

        console.log "Rest remove start...", that, row

        if row.remove?
          _id = row._id
          p = row.remove().then((result) ->
            if result
              that.status = result.status
              that.err = result.err
              delete result.status
              delete result.err
              if that.status == 'ok'
                x = that.findRowIndexById(_id.toString())
                if x != -1
                  that.rows.splice(x)
                console.log "Rest remove end...", that, r.results
                cb(_id.toString(), null) if cb

              else
                if that.err
                  err = new Error(that.err.code, that.err.message)
                else
                  err = new Error(500)
                console.log "Rest remove end with error...", that, err
                cb(null, err) if cb

            else
              console.log "Rest remove end with error...", that, row, "no result provided from server"
              cb(null, new Error('no result provided from server')) if cb

          , (err) ->
            console.log "Rest remove end with error...", that, _id, err
            cb(null, err) if cb
          )

        else
          console.log "Rest remove end with error...", that, _id, "no remove method found"
          cb(null, new Error('no remove method found')) if cb


      getSchema: (cb) ->
        that = @

        console.log "Rest schema start...", that

        if !that.rest
          if that.url?
            that.rest = Restangular.oneUrl(that.modelName, that.url)
          else
            that.rest = Restangular.one(that.modelName)

        p = $http.get('/api/{0}/schema'.format(that.modelName)).success((result) ->
          if result
            that.status = result.status
            that.err = result.err
            delete result.status
            delete result.err
            if that.status == 'ok'
              schema = result
              p = []
              for k of schema
                if k != 'id'
                  p.push(k)
              schema.paths = p
              that.schema = schema
              console.log "Rest schema end...", that, schema
              cb(schema, null) if cb

            else
              if that.err
                err = new Error(that.err.code, that.err.message)
              else
                err = new Error(500)
              console.log "Rest schema end with error...", that, err
              cb(null, err) if cb

          else
            console.log "Rest schema end with error...", that, row, "no result provided from server"
            cb(null, new Error('no result provided from server')) if cb

        ).error((err) ->
          console.log "Rest schema end with error...", that, err
          cb(null, err) if cb
        )


    return Rest
])
