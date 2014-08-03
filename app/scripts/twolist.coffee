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
#    ngModel: '='
    controller: 'twolistCtrl'
    priority: 1

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
#          $timeout(->
#            console.log "afterSelect", ctrl.$viewValue, values
#            ctrl.$setViewValue(ctrl.$viewValue.concat(values))
#          )
#
#        afterDeselect: (values) ->
#          $timeout(->
#            console.log "afterDeselect", ctrl.$viewValue, values
#            v = ctrl.$viewValue
#            for i in values
#              x = v.indexOf(i)
#              v.splice(x) if x != -1
#            ctrl.$setViewValue(v)
#          )

      , field.config)

#      ctrl.$render = ->
#        newValue = (if ctrl.$viewValue then ctrl.$viewValue else [])
#        element.multiSelect('select', newValue)

#      element.on('change', ->
#        console.log "change", element.val()
#        if !angular.equals(ctrl.$viewValue, element.val())
#          $timeout(->
#            scope.$apply(->
#              ctrl.$setViewValue(element.val())
#            )
#          )
#      )

      scope.$watch(attrs.ngModel, (newValue) ->
        newValue = (if newValue then newValue else [])
#        console.log "$watch", ctrl.$viewValue, newValue
        if !angular.equals(ctrl.$viewValue, newValue)
          $timeout(->
            element.multiSelect('select', newValue)
            element.multiSelect('refresh')
          )
      )

      $timeout( ->
        element.multiSelect(o)
        element.multiSelect('select', if field.selected? then field.selected else [])
      )
])
