'use strict'

angular.module('dashboard.lineChart', ['app'])

.directive('dashboardLineChart', [
  '$filter'

  ($filter) ->
    restrict: 'A'
    replace: true
    templateUrl: '/partials/dashboard.line-chart.html'
    scope:
      data: '=data'

    controller: ($scope) ->
      filter = $filter('date')

      $scope.xAxisTickFormatFunction = -> (d) -> filter(d, 'HH:mm')
      $scope.yAxisTickFormatFunction = -> (d) -> d3.round(d, 2)
      $scope.xFunction = -> (d) -> d.x
      $scope.yFunction = -> (d) -> d.y

    link: (scope) ->
      scope.$watch('data', (data) ->
        if data && data[0] and data[0].values and data[0].values.length > 1
          timeseries = _.sortBy(data[0].values, (item) -> item.x)
          start = timeseries[0].x
          end = timeseries[timeseries.length - 1].x
          scope.start = start
          scope.end = end
      )
])
