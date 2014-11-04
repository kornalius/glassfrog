iconsAttrs = {icons: {time: "cic cic-clock5", date: "cic cic-calendar-empty", up: "cic cic-arrow-up", down: "cic cic-arrow-down"}}

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
          input.parent().addClass("input-group")
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<span class=\"cic cic-calendar-empty\">")
          $(input).datetimepicker(angular.extend({pickTime: false, format: "YYYY/MM/DD"}, iconsAttrs))

    time:
      type: 'validator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
  #        input.attr('filter', "time")
  #        input.attr('filter-apply', 'true')
          input.parent().addClass("input-group")
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<span class=\"cic cic-clock5\"/>")
          $(input).datetimepicker(angular.extend({pickDate: false, useSeconds: false, format: "hh:mm A"}, iconsAttrs))

    datetime:
      type: 'validator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
#          input.attr('filter', "datetime")
#          input.attr('filter-apply', 'true')
          input.parent().addClass("input-group")
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<span class=\"cic cic-calendar-empty\"/>")
          $(input).datetimepicker(angular.extend({sideBySide: true, useSeconds: false, format: "YYYY/MM/DD hh:mm A"}, iconsAttrs))
 ])
