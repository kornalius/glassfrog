angular.module('dateAttributes', [])

.factory('dateAttributes', [
  'dynForm'

  (dynForm) ->

    date:
      type: 'validator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
  #        input.attr('filter', "date")
  #        input.attr('filter-apply', 'true')
          input.attr('date-time-picker', 'true')
          input.attr('date-time-picker-options', '{pickTime: false, format: "YYYY/MM/DD", icons: {time: "cic cic-clock5", date: "cic cic-calendar-empty", up: "cic cic-arrow-up", down: "cic cic-arrow-down"} }')
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<i class=\"cic cic-calendar-empty\"></i>")
          $(input).datetimepicker()

    time:
      type: 'validator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
  #        input.attr('filter', "time")
  #        input.attr('filter-apply', 'true')
          input.attr('date-time-picker', 'true')
          input.attr('date-time-picker-options', '{pickDate: false, useSeconds: false, format: "hh:mm A", icons: {time: "cic cic-clock5", date: "cic cic-calendar-empty", up: "cic cic-arrow-up", down: "cic cic-arrow-down"} }')
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<i class=\"cic cic-clock5\"></i>")
          $(input).datetimepicker()

    datetime:
      type: 'validator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
  #        input.attr('filter', "datetime")
  #        input.attr('filter-apply', 'true')
          input.attr('date-time-picker', 'true')
          input.attr('date-time-picker-options', '{sideBySide: true, useSeconds: false, format: "YYYY/MM/DD hh:mm A", icons: {time: "cic cic-clock5", date: "cic cic-calendar-empty", up: "cic cic-arrow-up", down: "cic cic-arrow-down"} }')
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<i class=\"cic cic-calendar-empty\"></i>")
          $(input).datetimepicker()
 ])
