angular.module('iconspickerAttributes', [])

.factory('iconspickerAttributes', [
  'dynForm'
  '$http'
  '$timeout'

  (dynForm, $http, $timeout) ->

    iconspicker:
      type: 'validator'
      code: (scope, element, field) ->
        $http({ method: 'GET', url: '/css/cicons.txt' }).
        success((icons) ->
          input = dynForm.getFieldDOM(element)
          if input and input.length and input[0].nodeName == 'INPUT'
            input.parent().addClass("input-group")
            element.find('span').addClass("input-group-addon").css("width", "39px")
            element.find('span').append("<i class=\"cic cic-uniF545\"></i>")
            $(input).iconpicker(
              hideOnSelect: true
              inputSearch: true
              container: 'body'
              icons: icons.split(',')
              fullClassFormatter: (val) -> 'cic ' + (if val? and val.length then val else 'cic-null')
#              showFooter: true
#              searchInFooter: true
              mustAccept: false
            ).on('iconpickerShown', (e) ->
              p = e.iconpickerInstance.popover.find('.iconpicker-items')
              p.scrollTop(0)
              p.scrollTop(p.find('.iconpicker-item.iconpicker-selected').position().top - (p.height() / 2))
            )
        )

])
