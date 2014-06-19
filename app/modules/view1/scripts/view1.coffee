'use strict'

angular.module('view1', ['app'])

.controller('View1Ctrl', [
  '$scope'
  'Globals'

($scope, globals) ->
  $scope.onePlusOne = 2
])

.config([
  '$stateProvider'

  ($stateProvider) ->
    $stateProvider

    .state('view1',
      url:'/view1'
      templateUrl: '/partials/view1.html'
    )
])
