angular.module('layoutAttributes', [])

.factory('layoutAttributes', [
  '$parse'
  'dynForm'

  ($parse, dynForm) ->

    hidden:
      type: 'layout'
      code: (scope, element, field) ->
        element.attr('ng-hide', field.hidden)
#        input = element.find('input')
#        input.attr('ng-hide', params)

    disabled:
      type: 'layout'
      code: (scope, element, field) ->
        element.attr('ng-disabled', field.disabled)
#        input = element.find('input')
#        input.attr('ng-disabled', params)

    required:
      type: 'layout'
      code: (scope, element, field) ->
        label = angular.element("#" + field.domId('label', scope.$index))
        if label.find('i').length == 0
          label.prepend('<i class="cic cic-exclamation" style="color:darkgray;" title="This field is required"></i>&nbsp;')
#        input = element.find('input')
#        input.attr('required', "true")
#        input.attr('ng-required', params.required)

    readonly:
      type: 'layout'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          input.attr('ng-readonly', field.readonly)

    placeholder:
      type: 'decorator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
#        input.removeAttr('placeholder')
          if $parse("isEditing()")(scope)
            input.attr('placeholder', field.placeholder)

    icon:
      type: 'decorator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          input.removeAttr('icon')
          element.find('span').addClass("input-group-btn")
          element.find('span').append("<button class='btn btn-default'><i class=\"cic cic-" + field.icon + "\"></i></button>")
        else
          element.removeAttr('icon')
          element.prepend("<i class=\"cic cic-" + field.icon + "\"/>&nbsp;")
    break:
      type: 'layout'
      code: (scope, element, field) ->
        element.removeAttr('break')
        element.append('<br/>')

    line:
      type: 'layout'
      code: (scope, element, field) ->
        element.removeAttr('line')
        element.append("<hr/>")

    font:
      type: 'layout'
      code: (scope, element, field) ->
        element.removeAttr('font')
        input = dynForm.getFieldDOM(element)
        if input.tagName != 'input'
          input.css({'font-family': field.font})

    fontsize:
      type: 'layout'
      code: (scope, element, field) ->
        element.removeAttr('fontsize')
        input = dynForm.getFieldDOM(element)
        if input.tagName != 'input'
          input.css({'font-size': field.fontsize + 'px'})

    bold:
      type: 'layout'
      code: (scope, element, field) ->
        element.removeAttr('bold')
        input = dynForm.getFieldDOM(element)
        if input.tagName != 'input'
          input.css({'font-weight': 'bold'})

    italic:
      type: 'layout'
      code: (scope, element, field) ->
        element.removeAttr('italic')
        input = dynForm.getFieldDOM(element)
        if input.tagName != 'input'
          input.css({'font-style': 'italic'})

    underline:
      type: 'layout'
      code: (scope, element, field) ->
        element.removeAttr('underline')
        input = dynForm.getFieldDOM(element)
        if input.tagName != 'input'
          input.css({'text-decoration': 'underline'})

    strikethrough:
      type: 'layout'
      code: (scope, element, field) ->
        element.removeAttr('strikethrough')
        input = dynForm.getFieldDOM(element)
        if input.tagName != 'input'
          input.css({'text-decoration': 'line-through'})

    center:
      type: 'layout'
      code: (scope, element, field) ->
        element.removeAttr('center')
        input = dynForm.getFieldDOM(element)
        if input.tagName != 'input'
          input.css({'text-center': true})

    vcenter:
      type: 'layout'
      code: (scope, element, field) ->
        element.removeAttr('vcenter')
        input = dynForm.getFieldDOM(element)
        if input.tagName != 'input'
          input.css({'vertical-align': 'middle'})

    shadow:
      type: 'layout'
      code: (scope, element, field) ->
        element.removeAttr('shadow')
        input = dynForm.getFieldDOM(element)
        if input.tagName != 'input'
          if typeof field.shadow is 'number'
            i = field.shadow
          else
            i = 1
          input.css({'text-shadow': '{0}px {0}px silver'.format(i)})
])

.directive('container', [
  '$parse'

  ($parse) ->
    link:(scope, element, attrs) ->
      ok = $parse(attrs.container)(scope)
      if ok
        element.parent().contents().wrap("<div class='container'></div>")
      element.removeAttr('container')
])
