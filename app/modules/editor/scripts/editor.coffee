angular.module('editor', ['editor.module', 'editor.component', 'editor.node', 'editor.preview', 'dynamicForm'])

.run([
  '$http'
  'Rest'

  ($http, Rest) ->

    require(['vc_global', 'vc_module', 'vc_component'], (VCGlobal, Module, Component) ->
      console.log "Loading components..."
      $http.get('/api/components')
      .success((data, status) ->
        VCGlobal.components = data
        for c in VCGlobal.components
          Component.make(c)
        console.log "Loaded {0} components".format(VCGlobal.components.length)
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

  (dynModal) ->
    over: null
    drag: null
    dragOver: null
    module: null

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
        if ok
          that.module = m
        cb(that.module) if cb
      )

    saveModule: (m) ->
      m.save()

    isOver: (o) ->
      @over == o

    setOver: (o) ->
      @over = o

    isDragOver: (o) ->
      @dragover == o

    setDragOver: (o) ->
      @dragover = o
])
