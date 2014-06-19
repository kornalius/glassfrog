angular.module('test.po', [])

.controller('TestPOCtrl', [
  '$scope'

  ($scope) ->
    $scope.localVariable = "PURCHASE ORDER!"
])
