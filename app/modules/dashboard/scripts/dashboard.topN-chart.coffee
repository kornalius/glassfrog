'use strict'

angular.module('dashboard.topNChart', ['app'])

.directive('dashboardTopNChart', [
  '$filter'

  ($filter) ->
    restrict: 'A'
    replace: true
    templateUrl: '/partials/dashboard.topN-chart.html'
    scope:
      data: '=data'

    controller: ($scope) ->
      filter = $filter('date')

      $scope.xAxisTickFormatFunction = -> (d) -> d
      $scope.yAxisTickFormatFunction = -> (d) -> d3.round(d, 2)
      $scope.xFunction = -> (d) -> d.x
      $scope.yFunction = -> (d) -> d.y
])
