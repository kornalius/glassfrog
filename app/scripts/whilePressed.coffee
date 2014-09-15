'use strict';

TICK_LENGTH = 15

angular.module('whilePressed', [])

.directive('whilePressed', [
  '$parse'
  '$interval'

  ($parse, $interval) ->
    restrict: "A"

    link: (scope, elem, attrs) ->
      action = $parse(attrs.whilePressed)
      intervalPromise = null

      bindWhilePressed = ->
        elem.on('mousedown', beginAction)

      bindEndAction = ->
        elem.on('mouseup', endAction)
        elem.on('mouseleave', endAction)

      unbindEndAction = ->
        elem.off('mouseup', endAction)
        elem.off('mouseleave', endAction)

      beginAction = (e) ->
        e.preventDefault()
        tickAction()
        intervalPromise = $interval(tickAction, TICK_LENGTH)
        bindEndAction()

      endAction = ->
        $interval.cancel(intervalPromise)
        unbindEndAction()

      tickAction = ->
        action(scope)

      bindWhilePressed()

])
