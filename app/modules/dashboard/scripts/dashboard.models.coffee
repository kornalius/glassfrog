angular.module('dashboard.models', ['app'])

.factory('DashboardRestModel', [
  'WidgetDataModel'
  '$interval'
  'Rest'

  (WidgetDataModel, $interval, Rest) ->

    DashboardRestModel = (options) ->
      @limit = (if options and options.limit? then options.limit else 100)
      @interval = (if options and options.interval? then options.interval else 10 * 1000)
      @model = (if options and options.model? then options.model else null)
      @query = (if options and options.query? then options.query else {})
      @keyField = (if options and options.keyField? then options.keyField else null)
      @valueField = (if options and options.valueField? then options.valueField else null)
      @type = (if options and options.type? then options.type else 'count')
      @data = []
      @rest = null

      if @type == 'count'
        @keyField = null
        @valueField = '@total'
        angular.extend(@query, {perPage: 1, select: '_id'})

      else if @type == 'top'
        angular.extend(@query, {perPage: @limit, sort: '-' + @valueField, select: [@keyField, @valueField]})

      else if @type == 'list'
        angular.extend(@query, {perPage: @limit, select: [@keyField, @valueField]})

      return @

    DashboardRestModel.prototype = Object.create(WidgetDataModel.prototype)
    DashboardRestModel.prototype.constructor = WidgetDataModel

    angular.extend(DashboardRestModel.prototype,
      init: ->
        WidgetDataModel.prototype.init.call(@)

        that = @
        @intervalPromise = $interval(->
          if that.model?

            if !that.rest?
              that.rest = new Rest(that.model)

            that.rest.fetch(that.query, (results) ->
              if that.valueField == '@total'
                that.data.push(
                  x: Date.now()
                  y: that.rest.total
                )
                that.updateScope(that.data)

              else if results
                i = 0
                while i < results.length
                  row = results[i]
                  if that.data.length >= that.limit
                    that.data.shift()
                  that.data.push(
                    x: (if that.keyField? and row[that.keyField]? then row[that.keyField] else Date.now())
                    y: (if that.valueField? and row[that.valueField]? then row[that.valueField] else 0)
                  )
                  i++
                that.updateScope(that.data)
            )
        , @interval)

      updateScope: (data) ->
        chart = [
          key: 'Data'
          values: data
        ]
        WidgetDataModel.prototype.updateScope.call(@, chart)

      destroy: ->
        WidgetDataModel.prototype.destroy.call(@)
        $interval.cancel(@intervalPromise)
    )

    return DashboardRestModel
])

.factory('DashboardUrlModel', [
  'WidgetDataModel'
  '$interval'
  '$http'

  (WidgetDataModel, $interval, $http) ->

    DashboardUrlModel = (options) ->
      @limit = (if options and options.limit? then options.limit else 100)
      @interval = (if options and options.interval? then options.interval else 60 * 1000)
      @url = (if options and options.url? then options.url else null)
      @query = (if options and options.query? then options.query else {})
      @keyField = (if options and options.keyField? then options.keyField else null)
      @valueField = (if options and options.valueField? then options.valueField else null)
      @type = (if options and options.type? then options.type else 'count')
      @data = []

      if @type == 'count'
        @keyField = null
        @valueField = '@total'

      return @

    DashboardUrlModel.prototype = Object.create(WidgetDataModel.prototype)
    DashboardUrlModel.prototype.constructor = WidgetDataModel

    angular.extend(DashboardUrlModel.prototype,
      init: ->
        WidgetDataModel.prototype.init.call(@)

        that = @
        @intervalPromise = $interval(->
          if that.url?
            $http(
              method: 'GET'
              url: that.url
            ).success((data, status, headers, config) ->
              if data
                if !(data instanceof Array)
                  data = [data]

                if that.valueField == '@total'
                  that.data.push(
                    x: Date.now()
                    y: that.rest.total
                  )
                  that.updateScope(that.data)
                else
                  for row in data
                    if that.data.length >= that.limit
                      that.data.shift()
                    that.data.push(
                      x: (if that.keyField? and row[that.keyField]? then row[that.keyField] else Date.now())
                      y: (if that.valueField? and row[that.valueField]? then row[that.valueField] else 0)
                    )
                  that.updateScope(that.data)
            )
        , @interval)

      updateScope: (data) ->
        chart = [
          key: 'Data'
          values: data
        ]
        WidgetDataModel.prototype.updateScope.call(@, chart)

      destroy: ->
        WidgetDataModel.prototype.destroy.call(@)
        $interval.cancel(@intervalPromise)
    )

    return DashboardUrlModel
])
