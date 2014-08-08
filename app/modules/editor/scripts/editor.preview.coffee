angular.module('editor.preview', ['app.globals', 'editor.node'])

.controller('EditorPreviewCtrl', [
  '$scope'
  'Rest'
  'Editor'
  'EditorNode'
  '$parse'
  '$document'
  'Globals'

  ($scope, Rest, Editor, EditorNode, $parse, $document, globals) ->

    $($document).ready(() ->
    )

    $scope.refresh = () ->
      @preview()

    $scope.close = () ->

    $scope.preview = () ->

])
