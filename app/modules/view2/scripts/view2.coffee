angular.module('view2', ['app'])

.controller('View2Ctrl', [
  '$scope'
  'Globals'

($scope, globals) ->
  $scope.twoPlusTwo = 4
])

.config([
  '$stateProvider'

  ($stateProvider) ->
    $stateProvider

    .state('view2',
      url:'/view2'
      templateUrl: '/partials/view2.html'
    )
])
