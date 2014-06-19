angular.module('editor.preview', ['app.globals', 'dragdrop.service', 'editor.node', 'nodes', 'components'])

.controller('EditorPreviewCtrl', [
  '$scope'
  'Rest'
  'Editor'
  'EditorNode'
  'Node'
  'Component'
  '$parse'
  '$document'
  'Globals'

  ($scope, Rest, Editor, EditorNode, Node, Component, $parse, $document, globals) ->

    $($document).ready(() ->
    )

    $scope.refresh = () ->
      @preview()

    $scope.close = () ->

    $scope.preview = () ->
      require(['Node_Data', 'Component_Data'], (Node_Data, Component_Data) ->

      )

])
