'use strict'

angular.module('editor.dragdrop', [])

.factory('dragdrop', [

  () ->
    dragData: null

])

.directive('draggable', [
  'dragdrop'

  (dragdrop) ->
    restrict: 'A'

    link: (scope, element, attrs, ctrl) ->
      el = element[0]
      el.sortable()

])

.directive('droppable', [
  'dragdrop'

  (dragdrop) ->
    restrict: 'A'

    link: (scope, element, attrs, ctrl) ->
      el = element[0]

])
