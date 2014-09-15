'use strict'

angular.module('checklistbox.services', ['app', 'app.globals'])

.controller('checklistboxCtrl', [
  '$scope'
  'Globals'

  ($scope, globals) ->

    $scope.options = []

    $scope.modelValue = () ->
      l = []
      for o in $scope.options
        if o.checked
          l.push(o)

      if $scope.format == 'string-label'
        return l.map((o) -> o.label).join($scope.delimiter)
      else if $scope.format == 'string-value'
        return l.map((o) -> o.value).join($scope.delimiter)
      else if $scope.format == 'array'
        return l.map((o) -> {label: o.label, value: o.value})
      else if $scope.format == 'array-label'
        return l.map((o) -> o.label)
      else if $scope.format == 'array-value'
        return l.map((o) -> o.value)
      else
        return []


    $scope.processOptions = (options) ->
      l = []
      for i in [0..options.length - 1]
        if !options[i].label and !options[i].value
          l.push({value: options[i], label: options[i], checked: false})
        else
          if !options[i].checked?
            l.push({value: options[i].value, label: options[i].label, checked: false})
          else
            l.push(options[i])
      return l

])

.directive('checklistbox', [
  '$document'
  '$window'
  '$timeout'
  '$parse'

  ($document, $window, $timeout, $parse) ->
    restrict: 'A'
    require: '?ngModel'
#    ngModel: '='
    controller: 'checklistboxCtrl'
    priority: 1

    link: (scope, element, attrs, ctrl) ->

      defaults =
        config:
          format: 'string-label'
          delimiter: ','
        selected: []

      if attrs.field?
        field = $parse(attrs.field)(scope)
      else
        field =
          config: {}
          selected: []

      field.config = angular.extend({}, field.config, defaults.config)
      scope.format = field.config.format
      scope.delimiter = field.config.delimiter

      scope.options = scope.processOptions($parse(attrs.options)(scope))

#      ctrl.$render = ->
#        newValue = (if ctrl.$viewValue then ctrl.$viewValue else [])
#        console.log "$render()", newValue

      element.on('change', ->
        r = scope.modelValue()
        if !angular.equals(ctrl.$viewValue, r)
          $timeout(->
            scope.$apply(->
              ctrl.$setViewValue(r)
            )
          )
      )

      scope.$watch('options', (newValue, oldValue) ->
        if !angular.equals(newValue, oldValue)
          element.trigger('change')
      , true)

      scope.$watch(attrs.ngModel, (newValue, oldValue) ->
        if !angular.equals(newValue, oldValue)
          ls = []

          if newValue?
            if scope.format.startsWith('string') and type(newValue) is 'string'
              ls = newValue.split(scope.delimiter)
            else if scope.format.startsWith('array') and type(newValue) is 'array'
              ls = newValue

          for o in scope.options
            o.checked = false

          for l in ls
            for o in scope.options
              if (scope.format == 'string-label' and o.label == l) or (scope.format == 'string-value' and o.value == l) or (scope.format == 'array-label' and o.label == l) or (scope.format == 'array-value' and o.value == l) or (scope.format == 'array' and o.value == l.value)
                o.checked = true
                break
      , true)

      $timeout( ->
        if field.selected?
          for f in scope.processOptions(field.selected)
            for o in scope.options
              if o.value == f.value
                o.checked = true
                break
      )

])
