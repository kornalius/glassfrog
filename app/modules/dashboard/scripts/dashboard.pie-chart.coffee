'use strict'

angular.module('dashboard.pieChart', ['app'])

.directive('dashboardPieChart', [
  '$filter'

  ($filter) ->
    restrict: 'A'
    replace: true
    templateUrl: '/partials/dashboard.pie-chart.html'
    scope:
      data: '=data'

    controller: ($scope) ->
      filter = $filter('date')

      $scope.xAxisTickFormatFunction = -> (d) -> filter(d, 'HH:mm')
      $scope.yAxisTickFormatFunction = -> (d) -> d3.round(d, 2)
      $scope.xFunction = -> (d) -> d.x
      $scope.yFunction = -> (d) -> d.y
      $scope.descriptionFunction = (d) -> d.x + ' ' + d.y
])
