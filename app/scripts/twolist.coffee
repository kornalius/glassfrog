'use strict'

angular.module('twolist.services', ['app', 'app.globals'])

.controller('twolistCtrl', [
  '$scope'
  'Globals'

  ($scope, globals) ->

])

.directive('twolist', [
  '$document'
  '$window'
  '$timeout'
  '$parse'

  ($document, $window, $timeout, $parse) ->
    restrict: 'A'
    require: '?ngModel'
    controller: 'twolistCtrl'

    link: (scope, element, attrs, ctrl) ->

      if attrs.field?
        field = $parse(attrs.field)(scope)
      else
        field =
          config: {}
          selected: []

      o = angular.extend(
        afterInit: (container) ->
          ctrl.$setViewValue([])

#        afterSelect: (values) ->
#          scope.$apply(() ->
#            console.log "afterSelect", ctrl.$viewValue, values
#            ctrl.$setViewValue(ctrl.$viewValue.concat(values))
#          )

#        afterDeselect: (values) ->
#          scope.$apply(() ->
#            console.log "afterDeselect", ctrl.$viewValue, values
#            v = ctrl.$viewValue
#            for i in values
#              x = v.indexOf(i)
#              v.splice(x) if x != -1
#            ctrl.$setViewValue(v)
#          )

      , field.config)

      $timeout( ->
        element.multiSelect(o)
        element.multiSelect('select', if field.selected? then field.selected else [])
      )
])
