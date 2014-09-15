angular.module('editor', ['editor.module', 'editor.component', 'editor.node', 'editor.preview', 'dynamicForm'])

.run([
  '$http'
  'Rest'
  'EditorComponent'
  'EditorModule'

  ($http, Rest, EditorComponent, EditorModule) ->

    require(['vc_global', 'vc_module', 'vc_component'], (VCGlobal, Module, Component) ->
#      console.log "Loading components..."
#      VCGlobal.components = new Rest('component', '/api/components')
#      VCGlobal.components.rows = VCGlobal.components.fetch({}, (data) ->
#        for c in data
#          Component.make(c)
#        console.log "Loaded {0} components".format(VCGlobal.components.rows.length), data
#        EditorComponent.refresh()
#      )

      VCGlobal.loadComponents((data) ->
        if data
          EditorComponent.refresh()
      )

      console.log "Loading user's modules..."
      VCGlobal.modules = new Rest('module', '/api/modules')
      VCGlobal.modules.rows = VCGlobal.modules.fetch({}, (data, err) ->
        if !err
          for m in data
            Module.make(m)
          console.log "Loaded {0} modules".format(data.length)
          EditorModule.refresh()
        else
          console.log "Error loading modules", err
      )

#      $http.get('/api/modules')
#      .success((data, status) ->
#        VCGlobal.modules = new Rest('module')
#        VCGlobal.modules.rows = (if data? then data else [])
#        for m in VCGlobal.modules.rows
#          Module.make(m)
#        console.log "Loaded {0} modules".format(VCGlobal.modules.rows.length), data
#
#        EditorModule.refresh()
#      )
#      .error((data, status) ->
#      )
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
    prevOver: null
    expandTimeout: null
    dragging: null
    module: null
    rootNodes: []
    oldContainer: null

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
            m.edit((ok) ->
              if ok
                that.module = m
                that.rootNodes = m.getRoot().nodes
#                $timeout(->
#                  m.generateCode(true)
#                  m.generateCode(false)
#                , 1000)
              cb(that.module) if cb
            )
          else
            cb(that.module) if cb
        )
      )

    saveModule: (m, cb) ->
      m.save((ok) ->
        cb(ok) if cb
      )

    isOver: (o) ->
      @over == o

    setOver: (o) ->
      if @prevOver != o
        @over = o
        @prevOver = o
        if @expandTimeout
          $timeout.cancel(@expandTimeout)
          @expandTimeout = null
        if @dragging and @dragging != o and o and o.$data and o.$data.isNode and o.isClosed()
          that = @
          @expandTimeout = $timeout( ->
            o.open()
            that.expandTimeout = null
          , 500)
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
      if Editor.module
        Editor.module.getRoot().nodes = newVal
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

])
