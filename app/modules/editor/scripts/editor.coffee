angular.module('editor', ['editor.module', 'editor.dragdrop', 'editor.component', 'editor.node', 'editor.preview', 'dynamicForm'])

.run([
  '$http'
  'Rest'
  'EditorComponent'
  'EditorModule'

  ($http, Rest, EditorComponent, EditorModule) ->

    require(['vc_global', 'vc_module', 'vc_component'], (VCGlobal, Module, Component) ->
      console.log "Loading components..."
      $http.get('/api/components')
      .success((data, status) ->
        VCGlobal.components = data
        for c in VCGlobal.components
          Component.make(c)
        console.log "Loaded {0} components".format(VCGlobal.components.length)

        EditorComponent.refresh()
      )
      .error((data, status) ->
      )

      console.log "Loading modules..."
      $http.get('/api/modules')
      .success((data, status) ->
        VCGlobal.modules = new Rest('module')
        VCGlobal.modules.rows = (if data? then data else [])
        for m in VCGlobal.modules.rows
          Module.make(m)
        console.log "Loaded {0} modules".format(VCGlobal.modules.rows.length)

        EditorModule.refresh()
      )
      .error((data, status) ->
      )
    )

])

.config([
  '$stateProvider'

  ($stateProvider) ->
    $stateProvider

    .state('editor_root',
      abstract: true
      templateUrl: '/partials/editor.html'
      controller: 'EditorCtrl'
#      onEnter: () ->
#        console.log "enter test"
    )

    .state('editor',
      url: '/editor'
      parent: 'editor_root'
#      hidden: true
      data:
        root: 'editor'
        ncyBreadcrumbLabel: 'Editor'
#          ncyBreadcrumbParent: 'user'
#          ncyBreadcrumbSkip: true
      views:
        components:
          templateUrl: '/partials/editor.component.html'
          controller: 'EditorComponentCtrl'
        nodes:
          templateUrl: '/partials/editor.node.html'
          controller: 'EditorNodeCtrl'
        modules:
          templateUrl: '/partials/editor.module.html'
          controller: 'EditorModuleCtrl'
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
  'dynModal'
  '$timeout'
  '$interval'

  (dynModal, $timeout, $interval) ->
    over: null
    drag: null
    dragOver: null
    module: null
    rootNodes: []
    oldContainer: null
    draggedWidth: 0
    draggedHeight: 0
    currentDragID: null

    isModuleSaved: () ->
      !@module or @module.isSaved()

    askSaveModule: (cb) ->
      if !@isModuleSaved()
        that = @
        dynModal.yesNoModal("Save?", "Do you want to save changes to {0}?".format(that.module.name), (ok) ->
          if ok
            that.saveModule(that.module, ->
              cb(true) if cb
            )
          else
            cb(false) if cb
        )
      else
        cb(true) if cb

    editModule: (m, cb) ->
      that = @
      @askSaveModule((ok) ->
        require(['vc_global'], (VCGlobal) ->
          if ok
            that.module = m
            for mm in VCGlobal.modules.rows
              mm.delState('e')
            m.addState('e')
            that.rootNodes = m.getRoot().nodes
            m.doGenerate(true)
            m.doGenerate(false)
          cb(that.module) if cb
        )
      )

    saveModule: (m, cb) ->
      m.save((err, result) ->
        cb() if cb
      )

    isOver: (o) ->
      @over == o

    setOver: (o) ->
      @over = o

    isDragOver: (o) ->
      @dragover == o

    setDragOver: (o) ->
      @dragover = o
])

.controller('EditorCtrl', [
  '$scope'
  'Editor'
  'EditorComponent'
  'EditorModule'
  'EditorNode'
  '$timeout'

  ($scope, Editor, EditorComponent, EditorModule, EditorNode, $timeout) ->

    $scope.rootNodes = []
    $scope.service = Editor

    $scope.$watchCollection('service.rootNodes', (newVal) ->
      $scope.rootNodes = newVal
    )

    require(['vc_global', 'vc_module', 'vc_component'], (VCGlobal, Module, Component) ->
      $timeout( ->
        EditorComponent.refresh(EditorNode.selection())
        EditorModule.refresh()
      , 100)
    )

    $scope.isModuleSaved = () ->
      Editor.isModuleSaved()

    $scope.askSaveModule = () ->
      Editor.askSaveModule()

    $scope.editModule = (m, cb) ->
      Editor.editModule(m, cb)

    $scope.saveModule = (m) ->
      Editor.saveModule(m)

    $scope.isOver = (o) ->
      Editor.isOver(o)

    $scope.setOver = (o) ->
      Editor.setOver(o)

    $scope.isDragOver = (o) ->
      Editor.isDragOver(o)

    $scope.setDragOver = (o) ->
      Editor.setDragOver(o)

])
