'use strict';

angular.module('Datetimepicker', [])

.directive('dateTimePicker', [
  '$timeout'
  '$parse'

  ($timeout, $parse) ->
    restrict: 'A'

    require: "?ngModel"

    link: (scope, element, attrs, ngModel) ->
      $timeout(() ->
        element.datetimepicker(if attrs.dateTimePickerOptions? then $parse(attrs.dateTimePickerOptions)(scope) else {})
      )

      ngModel.$setViewValue(element.context.value)
])
