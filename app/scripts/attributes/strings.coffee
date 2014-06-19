angular.module('stringAttributes', [])

.factory('stringAttributes', [
  '$parse'
  '$compile'
  'dynForm'

  ($parse, $compile, dynForm) ->

    prefix:
      type: 'layout'
      code: (scope, element, field) ->
        element.removeAttr('prefix')
        t = element.text()
        if t.startsWith('{{') and t.endsWith('}}')
          t = $parse(t.substring(2, t.length - 2))(scope)
        if t? and t.length
          element.prepend("<span>{0}</span>".format(field.prefix))

    suffix:
      type: 'layout'
      code: (scope, element, field) ->
        element.removeAttr('suffix')
        t = element.text()
        if t.startsWith('{{') and t.endsWith('}}')
          t = $parse(t.substring(2, t.length - 2))(scope)
        if t? and t.length
          element.append("<span>{0}</span>".format(field.suffix))

    password:
      type: 'decorator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          input.attr('type', 'password')
          input.removeAttr('password')
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<i class=\"cic cic-lock32\"></i>")
        else
          element.removeAttr('password')
          element.prepend("<i class=\"cic cic-lock32\"/>&nbsp;")

    email:
      type: 'decorator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          input.attr('type', 'input')
          input.removeAttr('email')
          input.attr('filter', "email")
          input.attr('filter-format', "")
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<i class=\"cic cic-envelope-alt\"></i>")
        else
          element.removeAttr('email')
          a = element.text()
          element.prepend("<i class=\"cic cic-envelope-alt\"/>&nbsp;")
          element.contents().wrap("<a href=\"mailto:" + a + "\"></a>")

    phone:
      type: 'decorator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          input.attr('type', 'input')
          input.removeAttr('phone')
          input.attr('filter', "phone")
          input.attr('filter-format', "")
          input.attr('filter-apply', "true")
          $(input).mask("(999) 999-9999? x99999")
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<i class=\"cic cic-phone\"></i>")
        else
          element.removeAttr('phone')
          element.prepend("<i class=\"cic cic-phone\"/>&nbsp;")

    url:
      type: 'decorator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          input.attr('type', 'input')
          input.removeAttr('url')
          input.attr('filter', "url")
          input.attr('filter-format', "")
          element.find('span').addClass("input-group-btn").css("width", "39px")
          element.find('span').append("<button class='btn btn-default'><i class=\"cic cic-globe6\"></i></button>")
        else
          element.removeAttr('url')
          a = element.text()
          element.prepend("<i class=\"cic cic-globe6\"/>&nbsp;")
          element.contents().wrap("<a href=\"" + a + "\"></a>")

    username:
      type: 'decorator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          input.attr('type', 'input')
          input.removeAttr('username')
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<i class=\"cic cic-user32\"></i>")
        else
          element.removeAttr('username')
          a = element.text()
          element.prepend("<i class=\"cic cic-user32\"/>&nbsp;")
    city:
      type: 'decorator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          input.attr('type', 'input')
          input.removeAttr('city')
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<i class=\"cic cic-uniF576\"></i>")
        else
          element.removeAttr('city')
          a = element.text()
          element.prepend("<i class=\"cic cic-uniF576\"/>&nbsp;")

    zipcode:
      type: 'decorator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          input.attr('type', 'input')
          input.removeAttr('zipcode')
          input.attr('filter', "zip")
          input.attr('filter-format', "")
          input.attr('filter-apply', "true")
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<i class=\"cic cic-location\"></i>")
        else
          element.removeAttr('zipcode')
          a = element.text()
          element.prepend("<i class=\"cic cic-location\"/>&nbsp;")

    mask:
      type: 'decorator'
      code: (scope, element, field) ->
        m = field.mask
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          $(input).on("focus", (e) ->
            $(input).mask(m, window.maskOptions)
          )
          $(input).on("blur", (e) ->
#            console.log element.$viewValue
            $(input).unmask()
          )
        else
          $(input).mask(m)

])
