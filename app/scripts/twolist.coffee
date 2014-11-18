'use strict'

angular.module('twolist.services', ['app', 'app.globals'])

.directive('twolist', [
  '$document'
  '$window'
  '$timeout'
  '$parse'

  ($document, $window, $timeout, $parse) ->
    restrict: 'A'
    replace: true
    require: '?ngModel'
    priority: 1
    controller: ['$scope', ($scope) ->
      $scope.config = {}
      $scope.options = []
      $scope.origValue = null

      $scope.init = (element) ->
        v = $scope.ngModel.$modelValue
        $scope.origValue = _.cloneDeep(v)
        if type(v) == 'string'
          v = v.split(',')
        else if !v
          v = []
        element.multiSelect($scope.config)
        element.multiSelect('select', v)
        element.multiSelect('refresh')
        $scope.ngModel.$setPristine()

      $scope.processOptions = (options) ->
        l = []
        for i in [0..options.length - 1]
          if !options[i].name and !options[i].value
            l.push({value: options[i], name: options[i]})
          else
            l.push(options[i])
        return l
    ]

    link: (scope, element, attrs, ctrl) ->
      scope.config = {}
#          afterInit: (container) ->
#            ctrl.$setViewValue([])

      if attrs.twolistOptions?
        o = $parse(attrs.twolistOptions)(scope)
      else
        o = {}

      _.extend(scope.config, o)

      scope.options = scope.processOptions($parse(attrs.options)(scope))

      $timeout(->
        scope.init(element)
      )

      scope.$watch(attrs.ngModel, (newValue, oldValue) ->
        if !_.isEqual(newValue, oldValue)
          if type(newValue) == 'string'
            v = newValue.split(',')
          else if !v
            v = []
          element.multiSelect('select', v)
          element.multiSelect('refresh')
          if !_.isEqual(scope.origValue, newValue)
            scope.ngModel.$dirty = true
            scope.ngModel.$pristine = false
      , true)
])
