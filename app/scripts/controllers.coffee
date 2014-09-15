'use strict'

### Controllers ###

angular.module('app.controllers', ['app.globals', 'webStorageModule'])

.controller('AppCtrl', [
  '$scope'
  '$location'
  '$resource'
  '$rootScope'
  'Globals'
  'webStorage'
  'amMoment'

($scope, $location, $resource, $rootScope, Globals, webStorage, amMoment) ->

  if webStorage.isSupported
    webStorage.prefix('gf_')
#    webStorage.add('test', 'test-value', true)
#    console.log webStorage.get('test', true)
    webStorage.add('user', $scope.user, true)

  Globals.user = _.cloneDeep($scope.user)
  amMoment.changeLocale($scope.user.locale)

  # Uses the url to determine if the selected
  # menu item should have the class active.
  $scope.$location = $location
  $scope.$watch('$location.path()', (path) ->
    $scope.activeNavId = path || '/'
  )

  # getClass compares the current url with the id.
  # If the current url starts with the id it returns 'active'
  # otherwise it will return '' an empty string. E.g.
  #
  #   # current url = '/products/1'
  #   getClass('/products') # returns 'active'
  #   getClass('/orders') # returns ''
  #
  $scope.getClass = (id) ->
    if $scope.activeNavId.substring(0, id.length) == id
      return 'active'
    else
      return ''
])
