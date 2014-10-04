angular.module('autosize.services', ['app'])

.directive("autoSize", [
  '$window'

  ($window) ->

    (scope, element, attr) ->

      updateWidth = ->
        tester = angular.element('<span>')
        elemStyle = $window.document.defaultView.getComputedStyle(element[0], '')
        tester.css(
          'font-family': elemStyle.fontFamily
          'line-height': elemStyle.lineHeight
          'font-size': elemStyle.fontSize
          'font-weight': elemStyle.fontWeight
          'white-space': 'nowrap'
        )

        s = element.val()

        tester.text(s)
        element.parent().append(tester)

        r = tester[0].getBoundingClientRect()
        w = r.width + 10

        element.css('width', w + 'px')

        tester.remove()

      $window.setTimeout(updateWidth, 0)

      element.bind("keydown", ->
        updateWidth()
#        $window.setTimeout(updateWidth, 0)
      )
])
