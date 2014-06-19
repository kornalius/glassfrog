angular.module('editor.component', ['app.globals', 'dragdrop.service', 'editor.node', 'components'])

.controller('EditorComponentCtrl', [
  '$scope'
  'Rest'
  'Editor'
  'EditorNode'
  'Component'
  '$parse'
  '$document'
  'Globals'

  ($scope, Rest, Editor, EditorNode, Component, $parse, $document, globals) ->

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

    require(['Component_Data'], (Component_Data) ->
#      $scope.setOver = Editor.setOver
#      $scope.isOver = Editor.isOver
      $scope.search = Editor.search
      $scope.getComponent = Component_Data.getComponent
      $scope.getComponentById = Component_Data.getComponentById
      $scope.getComponentByName = Component_Data.getComponentByName
    )

    $scope.list = () ->
      l = []

      if EditorNode.selection()
        selected = EditorNode.selection().$data
      else
        selected = null

      if globals.Component_Data and globals.Component_Data.rest
        for c in globals.Component_Data.rest.rows
          if c.$data.isVisible() and (!selected or selected.component.$data.doAccept(selected.node, c))
            l.push(c)
      return l

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
