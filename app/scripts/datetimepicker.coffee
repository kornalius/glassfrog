'use strict';

angular.module('Datetimepicker', [])

.directive('dateTimePicker', [
  '$timeout'
  '$parse'

  ($timeout, $parse) ->
    restrict: 'A'
    require: "?ngModel"

    compile: (element, attrs) ->

      (scope, element, attrs, ctrl) ->
        $timeout( ->
          config =
            icons:
              time: "cic cic-clock5"
              date: "cic cic-calendar-empty"
              up: "cic cic-arrow-up"
              down: "cic cic-arrow-down"

          o = attrs.dateTimePickerOptions
          if !o
            o = {}
          o = $parse(o)(scope)
          if type(o) is 'array'
            for e in o
              if e
                _.extend(config, e)
          else
            _.extend(config, o)
          element.datetimepicker(config)
          ctrl.$setViewValue(element.context.value)
        )

#        scope.$watch(attrs.ngModel, (newValue, oldValue) ->
#          console.log "$watch", "old", oldValue, "new", newValue
#          if !angular.equals(oldValue, newValue)
#            console.log "changed"
#            ctrl.$setViewValue(newValue)
##            $timeout(->
##              element.val(newValue)
##              ctrl.$setViewValue(newValue)
##            )
#        )
#
#        element.on("dp.change", (e) ->
#          console.log "dp.change", e.date.format("YYYY/MM/DD")
##          $timeout( ->
#  #          element.val(e.date.format("YYYY/MM/DD"))
#  #          ctrl.$setViewValue(e.date.format("YYYY/MM/DD"))
#  #          scope.$apply( ->
#  #            ctrl.$setViewValue(e.date.format("YYYY/MM/DD"))
#  #          )
#  #          element.data("DateTimePicker").hide()
##          )
#        )
])
