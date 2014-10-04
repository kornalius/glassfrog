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

      if attrs.field?
        field = $parse(attrs.field)(scope)
      else
        field =
          config: {}

      field.config = angular.extend({}, defaults.config, field.config)

#      ctrl.$render = ->
#        newValue = (if ctrl.$viewValue then ctrl.$viewValue else [])
#        console.trace "$render twolist", newValue, ctrl.$modelValue

#      element.on('change', ->
#        v = element.val()
#        if v and !angular.equals(v, ctrl.$viewValue)
#          console.log "change", v, ctrl.$viewValue
#          $timeout(->
#            scope.$apply(->
#              ctrl.$setViewValue(v)
#            )
#          )
#      )

#      scope.$watch('options', (newValue, oldValue) ->
#        console.trace "options.$watch()", newValue, oldValue
##        if !angular.equals(newValue, oldValue)
##          element.trigger('change')
#      , true)

      scope.$watch(attrs.ngModel, (newValue, oldValue) ->
#        console.log "model.$watch()", newValue, oldValue
        if !angular.equals(newValue, oldValue)
          $timeout(->
            if !newValue
              newValue = []
#            element.multiSelect('deselect_all')
            for v in newValue
              element.multiSelect('select', v)
            element.multiSelect('refresh')
          )
      , true)

      $timeout( ->
        element.multiSelect(field.config)
        for v in ctrl.$modelValue
          element.multiSelect('select', v)
#        element.multiSelect('select', [], 'init')
        element.multiSelect('refresh')
      )
])
