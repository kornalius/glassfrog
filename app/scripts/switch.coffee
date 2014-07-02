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

    controller: 'switchCtrl'

    compile: (element, attrs) ->

      (scope, element, attrs, ctrl) ->

        if attrs.field?
          field = $parse(attrs.field)(scope)
        else
          field =
            options: {}

        o = angular.extend({ show_labels: false, width: 40, height: 16, button_width: 20 }, field.options)

        $timeout( ->
          element.switchButton(o)
        )
])
