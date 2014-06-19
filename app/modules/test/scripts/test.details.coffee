angular.module('test.details', [])

.controller('TestDetailsCtrl', [
  '$scope'

  ($scope) ->
    $scope.localVariable = "DETAILS!"
])
