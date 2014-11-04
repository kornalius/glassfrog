angular.module('editor', ['editor.module', 'editor.component', 'editor.node', 'editor.preview', 'dynamicForm'])

.run([
  'Editor'

  (Editor) ->

    Editor.refresh(true)

])

.config([
  '$stateProvider'

  ($stateProvider) ->
    $stateProvider

    .state('editor',
      abstract: true
      url: '/editor'
      templateUrl: '/partials/editor.html'
      controller: 'EditorCtrl'
#      onEnter: () ->
#        console.log "enter test"
    )

    .state('editor.main',
      altname: 'editor'
      url: ''
      icon: 'cic-treediagram'
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
  '$injector'
  'Rest'
  'Globals'

  (dynModal, $timeout, $interval, $injector, Rest, Globals) ->
    over: null
    prevOver: null
    expandTimeout: null
    dragging: null
    module: null
    rootNodes: []
    oldContainer: null
    refreshNeeded: false

    refresh: (full) ->
      that = @

      require(['vc_global', 'vc_module'], (VCGlobal, VCModule) ->
        $injector.invoke(['EditorComponent', 'EditorModule', (EditorComponent, EditorModule) ->
          if full
            VCGlobal.loadComponents((data) ->
              if data
                EditorComponent.refresh()
            )

          console.log "Loading user's modules..."

          VCGlobal.modules = new Rest('module', '/api/modules')
          VCGlobal.modules.rows = VCGlobal.modules.find({}, (data, err) ->
            if !err and data
              for m in data
                VCModule.make(m)
              console.log "Loaded {0} modules".format(data.length)
              EditorModule.refresh()
              that.refreshNeeded = false
            else
              console.log "Error loading modules", err
          )
        ])
      )

    isModuleSaved: () ->
      !@module or @module.isSaved()

    askSaveModule: (msg, cb) ->
      if type(msg) is 'function'
        cb = msg
        msg = null
      if !@isModuleSaved()
        that = @
        dynModal.yesNoModal({title:"Save?", caption:"{0}Do you want to save changes to {1}?".format((if msg then msg + ' ' else ''), that.module.name)}, (ok) ->
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
#      @askSaveModule((ok) ->
      if m
        require(['vc_node'], (VCNode) ->
          m.edit((ok) ->
            if ok
              that.module = m
              that.rootNodes = m.getRoot().nodes
            console.log "editModule()", ok, that.module.displayName()
            cb(that.module) if cb
          )
        )
#      )

    saveModule: (m, cb) ->
      that = @
      if m
        console.log "saveModule()", m
        m.saveLocally((ok) ->
          if ok
            require(['vc_global', 'vc_module'], (VCGlobal, VCModule) ->
              VCGlobal.modules.update(m, (mm, err) ->
                if !err
                  VCModule.make(mm)
                  mm.clearSyntax()
                  VCGlobal.modules.call(mm, 'build', (err, result) ->
                    if !err
                      if result and result.$e
                        mm.showSyntaxError(result.$e)
                        if result.$e._id
                          n = VCGlobal.findNode(mm, result.$e._id, true)
                          if n
                            n.$data._error = result.$e
                            n.makeVisible()
                      else
                        Globals.showMessage('Module compiled successfully!', 'success')
                    that.editModule(mm, cb)
                  )
                else
                  cb(err) if cb
              )
            )
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
      )
    )

    if Editor.refreshNeeded
      Editor.askSaveModule('A refresh is needed.', ->
        Editor.module = null
        Editor.rootNodes = []
        Editor.refresh()
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
