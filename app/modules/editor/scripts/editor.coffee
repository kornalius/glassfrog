angular.module('editor', ['components', 'nodes', 'editor.component', 'editor.node', 'editor.preview'])

.config([
  '$stateProvider'

  ($stateProvider) ->
    $stateProvider

    .state('editor_root',
      abstract: true
      templateUrl: '/partials/editor.html'
      controller: ($scope) ->
        $scope.localVariable = "HELLO WORLD!"
#      onEnter: () ->
#        console.log "enter test"
    )

    .state('editor',
      url: '/editor'
      parent: 'editor_root'
      data:
        root: 'editor'
      views:
        components:
          templateUrl: '/partials/editor.component.html'
          controller: 'EditorComponentCtrl'
        nodes:
          templateUrl: '/partials/editor.node.html'
          controller: 'EditorNodeCtrl'
    )

#    .state('editor.preview',
#      url: '/preview'
#      parent: 'editor_root'
#      data:
#        root: 'editor'
#      views:
#        preview:
#          templateUrl: '/partials/editor.preview.html'
#          controller: 'EditorPreviewCtrl'
#    )
])

.factory('Editor', [

  () ->
    over: null
    drag: null
    dragOver: null

    isOver: (o) ->
      @over == o

    setOver: (o) ->
      @over = o

    isDragOver: (o) ->
      @dragover == o

    setDragOver: (o) ->
      @dragover = o
])

.run([

  () ->
])
