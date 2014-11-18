'use strict'

angular.module('checklistbox.services', ['app', 'app.globals'])

.directive('checklistbox', [
  '$document'
  '$window'
  '$timeout'
  '$parse'

  ($document, $window, $timeout, $parse) ->
    restrict: 'A'
    replace: true
    require: '?ngModel'
#    ngModel: '='
    priority: 1
    controller: ['$scope', ($scope) ->
      $scope.config = {}
      $scope.options = []

      $scope.processOptions = (options) ->
        l = []
        for i in [0..options.length - 1]
          if !options[i].name and !options[i].value
            l.push({name: options[i], value: options[i]})
          else
            l.push(options[i])
        return l

      $scope.toggle = (index) ->
        if $scope.ngModel and $scope.ngModel.$modelValue and index in [0..$scope.options.length - 1]
          i = $scope.ngModel.$modelValue.indexOf($scope.options[index].value)
          if i == -1
            $scope.ngModel.$modelValue.push($scope.options[index].value)
          else
            $scope.ngModel.$modelValue.splice(i, 1)
          $scope.ngModel.$dirty = true
          $scope.ngModel.$pristine = false

      $scope.isChecked = (index) ->
        if $scope.ngModel and $scope.ngModel.$modelValue and index in [0..$scope.options.length - 1]
          return $scope.ngModel.$modelValue.indexOf($scope.options[index].value) != -1
        return false
    ]

    link: (scope, element, attrs, ctrl) ->

      scope.config =
        delimiter: ','

      if attrs.checklistboxOptions?
        o = $parse(attrs.checklistboxOptions)(scope)
      else
        o = {}
      _.extend(scope.config, o)

      scope.options = scope.processOptions($parse(attrs.options)(scope))

#      scope.$watch(attrs.ngModel, (newValue) ->
#        console.log "$watch attrs.ngModel", newValue, ctrl, scope.ngModel
#      )

])
