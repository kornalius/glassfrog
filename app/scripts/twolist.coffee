'use strict'

angular.module('twolist.services', ['app', 'app.globals'])

.controller('twolistCtrl', [
  '$scope'
  'Globals'

  ($scope, globals) ->

    $scope.options = []

    $scope.processOptions = (options) ->
      l = []
      for i in [0..options.length - 1]
        if !options[i].label and !options[i].value
          l.push({value: options[i], label: options[i]})
        else
          l.push(options[i])
      return l

])

.directive('twolist', [
  '$document'
  '$window'
  '$timeout'
  '$parse'

  ($document, $window, $timeout, $parse) ->
    restrict: 'A'
    require: '?ngModel'
#    ngModel: '='
    controller: 'twolistCtrl'
    priority: 1

    link: (scope, element, attrs, ctrl) ->

      scope.options = scope.processOptions($parse(attrs.options)(scope))

      defaults =
        config: {}
#          afterInit: (container) ->
#            ctrl.$setViewValue([])
        selected: []

      if attrs.field?
        field = $parse(attrs.field)(scope)
      else
        field =
          config: {}
          selected: []

      field.config = angular.extend({}, field.config, defaults.config)

#      ctrl.$render = ->
#        newValue = (if ctrl.$viewValue then ctrl.$viewValue else [])
#        console.log "$render twolist", ctrl.$viewValue, ctrl.$modelValue
#        element.multiSelect('select', newValue)
#        element.multiSelect('refresh')

      element.on('change', ->
        if !angular.equals(element.val(), ctrl.$viewValue)
          $timeout(->
            scope.$apply(->
              ctrl.$setViewValue(element.val())
            )
          )
      )

      scope.$watch('options', (newValue, oldValue) ->
        if !angular.equals(newValue, oldValue)
          element.trigger('change')
      , true)

      scope.$watch(attrs.ngModel, (newValue, oldValue) ->
        if !angular.equals(newValue, oldValue)
          $timeout(->
            if !newValue
              newValue = []
            element.multiSelect('select', newValue)
            element.multiSelect('refresh')
          )
      )

      $timeout( ->
        element.multiSelect(field.config)
        element.multiSelect('select', if field.selected? then field.selected else [])
        element.multiSelect('refresh')
      )
])
