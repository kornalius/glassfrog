angular.module('test.info', [])

.controller('TestInfoCtrl', [
  '$scope'

  ($scope) ->
    $scope.localVariable = "INFOS!"
])
