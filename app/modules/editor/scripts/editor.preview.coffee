angular.module('editor.preview', ['app.globals'])

.controller('EditorPreviewCtrl', [
  '$scope'
  'Rest'
  'Editor'
  '$parse'
  '$document'
  'Globals'

  ($scope, Rest, Editor, $parse, $document, globals) ->

    $($document).ready(() ->
    )

    $scope.refresh = () ->
      @preview()

    $scope.close = () ->

    $scope.preview = () ->

])
