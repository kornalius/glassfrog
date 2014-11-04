'use strict'

angular.module('switch.services', ['app', 'app.globals'])

.controller('switchCtrl', [
  '$scope'
  'Globals'

  ($scope, globals) ->

])

.directive('switch', [
  '$document'
  '$window'
  '$timeout'
  '$parse'

  ($document, $window, $timeout, $parse) ->
    restrict: 'A'
    require: '?ngModel'
    controller: 'switchCtrl'

    compile: (element, attrs) ->

      (scope, element, attrs, ctrl) ->

        if attrs.field?
          field = $parse(attrs.field)(scope)
        else
          field =
            config: {}

#      ctrl.$render = ->
#        newValue = (if ctrl.$viewValue then ctrl.$viewValue else [])
#        element.multiSelect('select', newValue)

        element.on('change', ->
          newValue = element.prop('checked')
          if newValue != ctrl.$viewValue
            $timeout(->
              scope.$apply(->
                ctrl.$setViewValue(newValue)
              )
            )
        )

        scope.$watch(attrs.ngModel, (newValue) ->
          newValue = (if newValue then newValue else false)
          $timeout(->
            element.switchButton('option', 'checked', newValue)
          )
        )

        o = angular.extend({ show_labels: false, width: 40, height: 16, button_width: 20 }, field.config)

        $timeout( ->
          element.switchButton(o)
        )
])
