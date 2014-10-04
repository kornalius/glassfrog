'use strict';

angular.module('pagination.services', ['app'])

.controller('paginationCtrl', [
  '$scope'
  '$compile'

  ($scope, $compile) ->
    $scope.rest = null
    $scope.maxButtons = 5
    $scope.currentPage = 1
    $scope.oldPage = 1

    $scope.Math = window.Math

    $scope.init = (rest) ->
      $scope.rest = rest

    $scope.range = () ->
      ret = []
      m = $scope.Math.floor($scope.maxButtons / 2)
      start = $scope.Math.max(1, $scope.currentPage - m)
      end = $scope.Math.min($scope.pageCount(), $scope.currentPage + m)
      if end - start < $scope.maxButtons and $scope.rest.l >= $scope.maxButtons
        if start == 1
          end = $scope.Math.min($scope.pageCount(), start + $scope.maxButtons - 1)
        else if end == $scope.pageCount()
          start = $scope.Math.max(1 ,end - $scope.maxButtons + 1)
      if end < start
        end = start
      for i in [start..end]
        ret.push(i)
      return ret

    $scope.pageCount = () ->
      if $scope.rest then $scope.rest.pages else 1

    $scope.firstPage = () ->
      if $scope.rest then $scope.currentPage = $scope.rest.firstPage else $scope.currentPage = 1
      $scope.updateRest()

    $scope.prevPage = () ->
      if $scope.rest then $scope.currentPage = $scope.rest.prevPage else $scope.currentPage = 1
      $scope.updateRest()

    $scope.nextPage = () ->
      if $scope.rest then $scope.currentPage = $scope.rest.nextPage else $scope.currentPage = 1
      $scope.updateRest()

    $scope.lastPage = () ->
      if $scope.rest then $scope.currentPage = $scope.rest.lastPage else $scope.currentPage = 1
      $scope.updateRest()

    $scope.setPage = () ->
      $scope.currentPage = $scope.Math.min($scope.Math.max(1, @n), $scope.pageCount())
      $scope.updateRest()

    $scope.checkPage = () ->
      if $scope.currentPage < 1
        $scope.currentPage = 1
      else if $scope.currentPage > $scope.pageCount()
        $scope.currentPage = $scope.pageCount()

    $scope.updateRest = () ->
      $scope.checkPage()

      console.log $scope.oldPage, $scope.currentPage, $scope.pageCount(), $scope.rest

      if $scope.oldPage != $scope.currentPage
        if $scope.rest?
          $scope.oldPage = $scope.currentPage

          $scope.cancel()
          $scope.removeErrors()

          sc = $scope
          while sc and !sc.hasOwnProperty('rows')
            sc = sc.$parent

          $scope.rest.find({page: $scope.currentPage}, (results) ->
            sc.rows = results
          )

])

.directive('uiPagination', [
  '$parse'
  '$compile'
  '$http'
  '$templateCache'

  ($parse, $compile, $http, $templateCache) ->
    restrict: 'A'
    controller: 'paginationCtrl'
    template: '<div></div>'
#    templateUrl: '/partials/pagination.html'

    link: (scope, element) ->
      e = element
      r = $parse(element.attr('ui-pagination'))(scope)
      scope.init(r)

      scope.$watch('rest', ->
        $http.get('/partials/pagination.html', {cache: $templateCache}).success( (data) ->
          scope.checkPage()
          if scope.oldPage != scope.currentPage
            scope.updateRest()
          e.html(data)
          $compile(e.contents())(scope)
        )
      , yes)
])
