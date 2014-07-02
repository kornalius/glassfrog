angular.module('editor.component', ['app.globals', 'dragdrop.service', 'editor.node'])

.controller('EditorComponentCtrl', [
  '$scope'
  'Rest'
  'Editor'
  'EditorNode'
  '$parse'
  '$document'
  'Globals'
  '$timeout'

  ($scope, Rest, Editor, EditorNode, $parse, $document, globals, $timeout) ->

    $($document).ready(() ->
      $('[data-toggle=toolbar-offcanvas]').click(() ->
        $(this).toggleClass('visible-xs text-center')
        $(this).find('span').toggleClass('cic-chevron-right2 cic-chevron-left2')
        $('.row-toolbar-offcanvas').toggleClass('active')
        $('#lg-toolbar-menu').toggleClass('hidden-xs').toggleClass('visible-xs')
        $('#xs-toolbar-menu').toggleClass('visible-xs').toggleClass('hidden-xs')
        $('#btnShow').toggle()
      )
    )

    require(['vc_global', 'vc_component'], (VCGlobal, Component) ->
#      $scope.setOver = Editor.setOver
#      $scope.isOver = Editor.isOver
      $scope.search = Editor.search
      $scope.findComponent = VCGlobal.findComponent

      $scope.list = () ->
        if EditorNode.selection()
          selected = EditorNode.selection()
        else
          selected = null
        return Component.list(selected)
    )

    $scope.showpopup = (c) ->
      if $scope.popup
        $timeout.cancel($scope.popup)
      $scope.popup = $timeout(->
        $('#component-popover_' + c._id).popover('show')
      , 1500)

    $scope.hidepopup = (c) ->
      if $scope.popup
        $timeout.cancel($scope.popup)
      $timeout(->
        $('#component-popover_' + c._id).popover('hide')
      , 1)

#    $scope.onStart = (e, ui) ->
#      if !Editor.drag
#        c = $parse(angular.element(e.target).attr('jqyoui-draggable'))($scope)
#        if c and c.component
#          cc = Component.getComponentById(c.node._id)
#          if cc
#            Editor.drag = cc
#            angular.element(e.target).attr('data-drag', Editor.drag.canDrag(cc))
#
#    $scope.onStop = (e, ui) ->
#      Editor.drag = null
#
#    $scope.onDrag = (e, ui) ->
#
#    $scope.onDrop = (e, ui) ->
#
#    $scope.onOver = (e, ui) ->
#      if e.target and Editor.drag
#        c = $parse(angular.element(e.target).attr('jqyoui-droppable'))($scope)
#        if c and c.component
#          node = EditorNode.getNodeById(node._id)
#          if node
#            angular.element(e.target).attr('data-drop', Editor.drag.canDrop(node))
#            Editor.dragover = node
#
#    $scope.onOut = (e, ui) ->
#      Editor.dragover = null
#
#    $scope.canDrag = (c) ->
#      return c and c.$data.canDrag()
#
#    $scope.canDrop = (c) ->
#      if !Editor.drag
#        return true
#      else
#        return Editor.drag and c and Editor.drag.canDrag(c)
])
