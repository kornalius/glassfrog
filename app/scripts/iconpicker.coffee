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

        config =
          hideOnSelect: true
          inputSearch: true
          container: 'body'
          fullClassFormatter: (val) -> 'cic ' + (if val? and val.length then val else 'cic-null')
          mustAccept: false

        if attrs.options?
          o = $parse(attrs.options)(scope)
          if type(o) is 'array'
            for e in o
              if e
                _.extend(config, e)
          else
            _.extend(config, o)

        $http({ method: 'GET', url: '/css/cicons.txt' }).
        success((icons) ->
          config.icons = icons.split(',')

          input.iconpicker(config).on('iconpickerShown', (e) ->
            p = e.iconpickerInstance.popover.find('.iconpicker-items')
            if p.length
              p.scrollTop(0)
              i = p.find('.iconpicker-item.iconpicker-selected')
              if i.length
                p.scrollTop(i.position().top - (p.height() / 2))
          )

          scope.$watch(attrs.ngModel, (newValue) ->
            $timeout(->
              $(element).data('iconpicker').setOptionsValue(newValue)
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
