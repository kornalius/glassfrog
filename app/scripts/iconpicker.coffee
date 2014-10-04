'use strict'

angular.module('iconpicker.services', ['app', 'app.globals'])

.controller('iconpickerCtrl', [
  '$scope'
  'Globals'

  ($scope, globals) ->

])

.directive('iconpicker', [
  '$document'
  '$window'
  '$timeout'
  '$parse'
  '$http'

  ($document, $window, $timeout, $parse, $http) ->
    restrict: 'A'
    require: '?ngModel'
    controller: 'iconpickerCtrl'

    compile: (element, attrs) ->

      (scope, element, attrs, ctrl) ->

#        input = $(element.find('#node-arg-input-icon'))
        input = $(element)

        if attrs.options?
          options = $parse(attrs.options)(scope)
        else
          options = {}

        $http({ method: 'GET', url: '/css/cicons.txt' }).
        success((icons) ->
          angular.extend(options,
            container: 'body'
            icons: icons.split(',')
            fullClassFormatter: (val) -> 'cic ' + (if val? and val.length then val else 'cic-null')
          )

          input.iconpicker(options)

          scope.$watch(attrs.ngModel, (newValue) ->
            $timeout(->
              $(element).data('iconpicker').setValue(newValue)
            )
          )
        )

#      ctrl.$render = ->
#        newValue = (if ctrl.$viewValue then ctrl.$viewValue else [])
#        element.multiSelect('select', newValue)

        element.on('iconpickerSelected', (e) ->
#          console.log 'iconpickerSelected', e
          newValue = e.iconpickerValue
          if newValue != ctrl.$viewValue
            $timeout(->
              scope.$apply(->
                ctrl.$setViewValue(newValue)
              )
            )
        )

])
