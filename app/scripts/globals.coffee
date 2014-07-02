'use strict'

angular.module('app.globals', ['ui.router.state', 'ajoslin.promise-tracker'])

.factory('Globals', [
  'promiseTracker'

  (promiseTracker) ->
    user: null
    modules: []
    loadingTracker: promiseTracker()
    messagesDOM: $()

    showMessage: (content, cl, time) ->
      $('<div class="alert ' + cl + ' alert-dismissable"> <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>' + content + '</div>').hide().fadeIn("fast").delay(time).fadeOut("fast", ->
        $(@).remove()
      ).appendTo(@messagesDOM)

#    registerTabs: ($stateProvider, tabs) ->
#      t = []
#
#      for m in tabs
#        sf = m.replace('.', '_')
#        t.push(
#          name: sf
#          expandedName: 'glassfrog.' + m
#          href: '#/' + sf
#          url: '/' + sf
#          templateUrl: '/partials/' + sf + '.html'
#          label: 'tab.' + m
#        )
#
##      for m in t
##        sp.state(m.name,
##          url: m.url
##          views:
##            "main-content":
##              templateUrl: m.templateUrl
##        )
#
#      console.log "registerTabs", @, t
#
#      return t
])

.config ($provide, $httpProvider) ->

  $httpProvider.responseInterceptors.push(($q, Globals) ->
    (promise) ->
      promise.then((successResponse) ->
#        showMessage("successMessage", "alert-success", 5000)  unless successResponse.config.method.toUpperCase() is "GET"
        successResponse
      , (errorResponse) ->
#        console.log "ERROR", errorResponse.status, errorResponse.data
        switch errorResponse.status
          when 401
            Globals.showMessage("Wrong usename or password", "alert-danger", 10000)
          when 403
            Globals.showMessage("Unauthorized! You don't have the necessary permissions", "alert-danger", 10000)
          when 500
            Globals.showMessage("Server internal error: " + errorResponse.data, "alert-danger", 10000)
          else
            if errorResponse.status
              if errorResponse.data
                Globals.showMessage("Error " + errorResponse.status + ": " + errorResponse.data, "alert-danger", 10000)
              else
                Globals.showMessage("Error " + errorResponse.status, "alert-danger", 10000)
        $q.reject(errorResponse)
      )
  )

.directive("appMessages", [
  'Globals'

  (Globals) ->
    link: (scope, element, attrs) ->
      Globals.messagesDOM.push($(element))

])

#.config([
#  '$stateProvider'
#
#  ($stateProvider) ->
#    $stateProvider.state('n', {})
#])

#.controller('globalsCtrl', [
#
#  (globals) ->
#    globals.sayHello()
#])
