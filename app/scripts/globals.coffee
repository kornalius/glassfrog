'use strict'

angular.module('app.globals', ['ui.router.state'])

.factory('Globals', [
  '$timeout'

  ($timeout) ->
    stack = {"dir1": "down", "dir2": "left", "push": "bottom", "spacing1": 0, "spacing2": 0, "context": $("body")}

    user: null
    modules: []

    showMessage: (text, type, title, icon, hide, width) ->
      if type == 'warning' or type == 'notice'
        type = 'notice'
      if !icon
        icon = 'exclamation2'
        if type == 'error'
          icon = 'spam3'
        else if type == 'warning' or type == 'notice'
          icon = 'warning3'
        else if type == 'info'
          icon = 'info6'

      $timeout(->
        options =
          type: type
          text: text
          mouse_reset: false
          stack: stack
          hide: (if hide == false then false else true)
          width: (if width? then width else '300px')
          buttons:
            sticker: false

        if title
          options.title = title
        if icon and title
          options.icon = 'large cic cic-' + icon

        notice = new PNotify(options)
        if !hide? or hide == true
          notice.get().click(-> notice.remove())
      , 100)

    isBreakpoint: (size) ->
      return $('.visible-' + size).is(':visible')

])

.config ($provide, $httpProvider) ->

  $httpProvider.interceptors.push(($q, Globals) ->
    'responseError': (rejection) ->

#      if canRecover(rejection)
#        return responseOrNewPromise

      return $q.reject(rejection)

#        console.log "ERROR", errorResponse.status, errorResponse.data

#        switch errorResponse.status
#          when 401
#            Globals.showMessage("Invalid usename or password", 'error')
#
#          when 403
#            Globals.showMessage("You do not have the necessary permissions", 'error')
#
#          when 404
#            Globals.showMessage("Not found error " + errorResponse.data, 'error')
#
#          when 500
#            Globals.showMessage("Internal server error: " + errorResponse.data, 'error')
#
#          else
#            if errorResponse.status
#              if errorResponse.data
#                Globals.showMessage("Error " + errorResponse.status + ": " + errorResponse.data, 'error')
#              else
#                Globals.showMessage("Error " + errorResponse.status, 'error')
#
#        $q.reject(rejection)
#      )
  )
