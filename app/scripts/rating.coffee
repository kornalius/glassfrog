'use strict';

angular.module('ui.bootstrap.rating.controller', [])

.controller('UIBootstrapRatingCtrl', [
  '$scope'

  ($scope) ->
    $scope.overStar = null

    $scope.hoveringOver = (value) ->
      $scope.overStar = value
      $scope.percent = 100 * (value / $scope.form.max)

])
