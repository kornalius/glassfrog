angular.module('stringAttributes', [])

.factory('stringAttributes', [
  '$parse'
  '$interpolate'
  '$compile'
  'dynForm'

  ($parse, $interpolate, $compile, dynForm) ->

    prefix:
      type: 'layout'
      code: (scope, element, field) ->
        element.removeAttr('prefix')
        t = _.str.trim(element.text())
        if t.startsWith('{{') and t.endsWith('}}')
          t = $parse(t.substr(2, t.length - 4))(scope)
        if t? and t.length
          element.prepend("<span>{0}</span>".format(field.prefix))

    suffix:
      type: 'layout'
      code: (scope, element, field) ->
        element.removeAttr('suffix')
        t = _.str.trim(element.text())
        if t.startsWith('{{') and t.endsWith('}}')
          t = $parse(t.substr(2, t.length - 4))(scope)
        if t? and t.length
          element.append("<span>{0}</span>".format(field.suffix))

    password:
      type: 'decorator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          input.attr('type', 'password')
          input.removeAttr('password')
          input.parent().addClass("input-group")
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<i class=\"cic cic-lock32\"/>")
        else
          l = element.find('label')
          if l.length
            l.prepend("<i class=\"display-icon cic cic-lock32\"/>")

    email:
      type: 'decorator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          input.attr('type', 'input')
          input.removeAttr('email')
          input.attr('filter', "email")
          input.attr('filter-format', "")
          input.parent().addClass("input-group")
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<i class=\"cic cic-envelope-alt\"/>")
        else
          element.removeAttr('email')
          l = element.find('label')
          if l.length
            s = _.str.trim(element.text())
            s = l.text()
            if s.startsWith('{{') and s.endsWith('}}')
              s = s.substr(2, s.length - 4)
            email = $parse(s)(scope)
            if email? and email.length
              l.wrap("<a href=\"mailto:" + _.str.escapeHTML(email) + "\"></a>")
            l.prepend("<i class=\"display-icon cic cic-envelope-alt\"/>")

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
          input.parent().addClass("input-group")
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<i class=\"cic cic-phone\"/>")
        else
          element.removeAttr('phone')
          l = element.find('label')
          if l.length
            s = l.text()
            if s.startsWith('{{') and s.endsWith('}}')
              s = s.substr(2, s.length - 4)
            phone = $parse(s)(scope)
            if phone? and phone.length
              l.wrap("<a href=\"tel:" + _.str.escapeHTML(phone.replace(/[\(\)\-\s]/gi, '')) + "\"></a>")
            l.prepend("<i class=\"display-icon cic cic-phone\"/>")

    fax:
      type: 'decorator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          input.attr('type', 'input')
          input.removeAttr('fax')
          input.attr('filter', "phone")
          input.attr('filter-format', "")
          input.attr('filter-apply', "true")
          $(input).mask("(999) 999-9999? x99999")
          input.parent().addClass("input-group")
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<i class=\"cic cic-printer\"/>")
        else
          element.removeAttr('phone')
          l = element.find('label')
          if l.length
            s = l.text()
            if s.startsWith('{{') and s.endsWith('}}')
              s = s.substr(2, s.length - 4)
            fax = $parse(s)(scope)
            if fax? and fax.length
              l.wrap("<a href=\"tel:" + _.str.escapeHTML(fax.replace(/[\(\)\-\s]/gi, '')) + "\"></a>")
            l.prepend("<i class=\"display-icon cic cic-printer\"/>")

    url:
      type: 'decorator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          input.attr('type', 'input')
          input.removeAttr('url')
          input.attr('filter', "url")
          input.attr('filter-format', "")
          input.parent().addClass("input-group")
          element.find('span').addClass("input-group-btn").css("width", "39px")
          element.find('span').append("<button class='btn btn-default'><i class=\"cic cic-external-link-sign\"/></button>")
        else
          element.removeAttr('url')
          l = element.find('label')
          if l.length
            s = l.text()
            if s.startsWith('{{') and s.endsWith('}}')
              s = s.substr(2, s.length - 4)
            url = $parse(s)(scope)
            if url? and url.length
              l.wrap("<a href=\"" + url + "\" target=\"_blank\"></a>")
            l.prepend("<i class=\"display-icon cic cic-external-link-sign\"/>")

    username:
      type: 'decorator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          input.attr('type', 'input')
          input.removeAttr('username')
          input.parent().addClass("input-group")
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<i class=\"cic cic-user32\"/>")
        else
          element.removeAttr('username')
          l = element.find('label')
          if l.length
            l.prepend("<i class=\"display-icon cic cic-user32\"/>")

    address:
      type: 'decorator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          input.attr('type', 'input')
          input.removeAttr('city')
          input.parent().addClass("input-group")
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<i class=\"cic cic-home3\"/>")
        else
          element.removeAttr('address')
          l = element.find('label')
          if l.length
            s = l.text()
            if s.startsWith('{{') and s.endsWith('}}')
              s = s.substr(2, s.length - 4)
            address = _.str.trim($parse(s)(scope))
            if address? and address.length
              l.wrap("<a href=\"http://maps.google.com/?q=" + _.str.escapeHTML(address) + "\" target=\"_blank\"></a>")
            l.prepend("<i class=\"display-icon cic cic-home3\"/>")

    city:
      type: 'decorator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          input.attr('type', 'input')
          input.removeAttr('city')
          input.parent().addClass("input-group")
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<i class=\"cic cic-uniF576\"/>")
        else
          element.removeAttr('city')
          l = element.find('label')
          if l.length
            s = l.text()
            if s.startsWith('{{') and s.endsWith('}}')
              s = s.substr(2, s.length - 4)
            city = _.str.trim($parse(s)(scope))
            if city? and city.length
              l.wrap("<a href=\"http://maps.google.com/?q=" + _.str.escapeHTML(city) + "\" target=\"_blank\"></a>")
            l.prepend("<i class=\"display-icon cic cic-uniF576\"/>")

    state:
      type: 'decorator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          input.attr('type', 'input')
          input.removeAttr('city')
          input.parent().addClass("input-group")
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<i class=\"cic cic-map\"/>")
        else
          element.removeAttr('state')
          l = element.find('label')
          if l.length
            s = l.text()
            if s.startsWith('{{') and s.endsWith('}}')
              s = s.substr(2, s.length - 4)
            state = _.str.trim($parse(s)(scope))
            if state? and state.length
              l.wrap("<a href=\"http://maps.google.com/?q=" + _.str.escapeHTML(state) + "\" target=\"_blank\"></a>")
            l.prepend("<i class=\"display-icon cic cic-map\"/>")

    country:
      type: 'decorator'
      code: (scope, element, field) ->
        input = dynForm.getFieldDOM(element)
        if input and input.length and input[0].nodeName == 'INPUT'
          input.attr('type', 'input')
          input.removeAttr('city')
          input.parent().addClass("input-group")
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<i class=\"cic cic-globe6\"/>")
        else
          element.removeAttr('country')
          l = element.find('label')
          if l.length
            s = l.text()
            if s.startsWith('{{') and s.endsWith('}}')
              s = s.substr(2, s.length - 4)
            country = _.str.trim($parse(s)(scope))
            if country? and country.length
              l.wrap("<a href=\"http://maps.google.com/?q=" + _.str.escapeHTML(country) + "\" target=\"_blank\"></a>")
            l.prepend("<i class=\"display-icon cic cic-globe6\"/>")

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
          input.parent().addClass("input-group")
          element.find('span').addClass("input-group-addon").css("width", "39px")
          element.find('span').append("<i class=\"cic cic-stamp\"/>")
        else
          element.removeAttr('zipcode')
          l = element.find('label')
          if l.length
            s = l.text()
            if s.startsWith('{{') and s.endsWith('}}')
              s = s.substr(2, s.length - 4)
            zip = _.str.trim($parse(s)(scope))
            if zip? and zip.length
              l.wrap("<a href=\"http://maps.google.com/?q=" + _.str.escapeHTML(zip) + "\" target=\"_blank\"></a>")
            l.prepend("<i class=\"display-icon cic cic-stamp\"/>")

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
