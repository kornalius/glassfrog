angular.module('numberAttributes', [])

.factory('numberAttributes', [
  'dynForm'

  (dynForm) ->

    number:
      type: 'validator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          input.attr('type', 'text')
  #        input.attr('integer', 'true')
          input.attr('placeholder', "0")
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').text("#")

    money:
      type: 'validator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          input.attr('type', 'text')
  #        input.attr('float', 'true')
          input.attr('placeholder', "0.00")
  #        input.addClass('number')
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').text(".00")

#    min:
#      type: 'validator'
#      code: (scope, element, field) ->
#        element.find('input').attr('min', field.min)
#
#    max:
#      type: 'validator'
#      code: (scope, element, field) ->
#        element.find('input').attr('max', field.max)
#
#    range:
#      type: 'validator'
#      code: (scope, element, field) ->
#        element.find('input').attr('min', field.range.min)
#        element.find('input').attr('max', field.range.max)
])
