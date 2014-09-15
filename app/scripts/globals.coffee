'use strict'

angular.module('app.globals', ['ui.router.state', 'ajoslin.promise-tracker'])

.factory('Globals', [
  'promiseTracker'
  '$timeout'

  (promiseTracker, $timeout) ->
    stack = {"dir1": "down", "dir2": "left", "push": "bottom", "spacing1": 0, "spacing2": 0, "context": $("body")}

    user: null
    modules: []
    loadingTracker: promiseTracker()

    showMessage: (text, type) ->

      icon = 'exclamation2'
      if type == 'error'
        icon = 'spam3'
      else if type == 'warning' or type == 'notice'
        type = 'notice'
        icon = 'warning3'
      else if type == 'info'
        icon = 'info6'

      $timeout(->
        notice = new PNotify({text: text, icon: 'cic cic-' + icon, type: type, mouse_reset: false, stack: stack, buttons: {'sticker': false}})
        notice.get().click(-> notice.remove())
      , 100)

])

.config ($provide, $httpProvider) ->

  $httpProvider.responseInterceptors.push(($q, Globals) ->
    (promise) ->

      promise.then((successResponse) ->
        successResponse

      , (errorResponse) ->

#        console.log "ERROR", errorResponse.status, errorResponse.data

        switch errorResponse.status
          when 401
            Globals.showMessage("Wrong usename or password", 'error')

          when 403
            Globals.showMessage("Unauthorized! You don't have the necessary permissions", 'error')

          when 404
            Globals.showMessage("Not found error " + errorResponse.data, 'error')

          when 500
            Globals.showMessage("Server internal error: " + errorResponse.data, 'error')

          else
            if errorResponse.status
              if errorResponse.data
                Globals.showMessage("Error " + errorResponse.status + ": " + errorResponse.data, 'error')
              else
                Globals.showMessage("Error " + errorResponse.status, 'error')

        $q.reject(errorResponse)
      )
  )
