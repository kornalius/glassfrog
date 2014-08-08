angular.module('editor', ['editor.module', 'editor.component', 'editor.node', 'editor.preview', 'dynamicForm'])

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

    refreshDragTrees: () ->
#      console.log "refreshDragTrees()", $(".nodes-tree")
#      console.log "refreshDragTrees()", $(".nodes-args-tree")

#      $(".nodes-tree").sortable("refresh")
      $(".nodes-tree").sortable("destroy")

#      $(".nodes-args-tree").sortable("refresh")
#      $(".nodes-args-tree").sortable("destroy")

      $(".components-tree").sortable("destroy")

      that = @

      $timeout(->
        $("ol.nodes-tree").sortable(
#          group: 'nodes-tree'
          tolerance: 8
          distance: 8
          dragID: 'N'
#          containerPath: ''
#          containerSelector: 'ol.nodes-tree'
#          itemPath: ''
#          itemSelector: 'li.nodes-tree-line'
#          handle: 'td.node-color-col, td.node-icon-col, td.node-label-col'
          nested: true
          vertical: true
#          exclude: 'ol.nodes-args-tree'
#          pullPlaceholder: false
#          placeholder: '<li class="placeholder"/>'

          isValidTarget: (item, container) ->
#            console.log "isValidTarget", item, container
            return container.options.dragID == 'N' && that.currentDragID == 'N'

#          onMousedown: (item, _super, event) ->
#            that.draggedWidth = 0
#            that.draggedHeight = 0
#            that.oldContainer = null
#
##            console.log "onMouseDown", $(event.target), $(event.target).parents('li.nodes-args-tree-line')
#            if _super(item, _super, event)
#              return $(event.target).parents('ol.nodes-args-tree').length == 0
#            else
#              return false

          onCancel: (item, container, _super, event) ->
            console.log "onCancel", item, container

          onDrag: (item, position, _super, event) ->
#            console.log "onDrag", item.position(), position
#            position.left /= 2
#            item.css(position)
            _super(item, position)

          onDragStart: (item, container, _super, event) ->
            that.currentDragID = container.options.dragID
            that.draggedWidth = item.width()
            that.draggedHeight = item.height()
            _super(item, container)

          afterMove: (placeholder, container) ->
  #            console.log "afterMove", placeholder, container
            if that.oldContainer != container
              if that.oldContainer
                that.oldContainer.el.removeClass("active")
              if container
                container.el.addClass("active")
              that.oldContainer = container
            if placeholder
              placeholder.width(that.draggedWidth)
              placeholder.height(that.draggedHeight)

          onDrop: (item, container, _super) ->
            console.log "onDrop", item, container
            _super(item, container)
            if container
              container.el.removeClass("active")
            scope = angular.element(item).scope()
            if scope and scope.$parent and scope.$parent.n
              scope.$parent.n.setModified(true)

          serialize: (parent, children, isContainer) ->
            return (if isContainer then children.join() else parent.text())
        )

#        $("ol.nodes-args-tree").sortable(
#          group: 'nodes-args-tree'
#          tolerance: 8
#          distance: 8
#          dragID: 'A'
##          containerPath: '> .nodes-args-tree'
##          containerSelector: '.nodes-args-tree'
##          itemPath: '.nodes-args-tree-line'
##          itemSelector: '.nodes-args-tree-line'
##          handle: 'div'
#          nested: false
#          vertical: false
#          exclude: 'ol.nodes-tree'
##          placeholder: '<li class="placeholder"/>'
##          pullPlaceholder: false
#
#          isValidTarget: (item, container) ->
##            console.log "isValidTarget(args)", item, container
#            return container.options.dragID == 'A' && that.currentDragID == 'A'
#
#          onMousedown: (item, _super, event) ->
#            that.draggedWidth = 0
#            that.draggedHeight = 0
#            that.oldContainer = null
#
##            console.log "onMouseDown(args)", item, event
#            if _super(item, _super, event)
#              return $(event.target).parents('ol.nodes-args-tree').length > 0
#            else
#              return false
#
#          onCancel: (item, container, _super, event) ->
#            console.log "onCancel(args)", item, container
#
#          onDrag: (item, position, _super, event) ->
##            console.log "onDrag(args)", item, position
##            position.left /= 2
##            item.css(position)
#            _super(item, position)
#
#          onDragStart: (item, container, _super, event) ->
#            that.currentDragID = container.options.dragID
#            that.draggedWidth = item.width()
#            that.draggedHeight = item.height()
#            _super(item, container)
#
#          afterMove: (placeholder, container) ->
##            console.log "afterMove(args)", placeholder, container
#            if that.oldContainer != container
#              if that.oldContainer
#                that.oldContainer.el.removeClass("active")
#              if container
#                container.el.addClass("active")
#              that.oldContainer = container
#            if placeholder
#              placeholder.width(that.draggedWidth)
#              placeholder.height(that.draggedHeight)
#
#          onDrop: (item, container, _super) ->
#            console.log "onDrop(args)", item, container
#            _super(item, container)
#            if container
#              container.el.removeClass("active")
#            scope = angular.element(item).scope()
#            if scope and scope.$parent and scope.$parent.n
#              scope.$parent.n.setModified(true)
#
##          serialize: (parent, children, isContainer) ->
##            return (if isContainer then children.join() else parent.text())
#        )

#        $(".nodes-args-tree").sortable("refresh")
#        $(".nodes-tree").sortable("refresh")

        $("ol.components-tree").sortable(
#          group: 'components-tree'
          tolerance: 8
          distance: 8
          dragID: 'C'
#          containerPath: ''
#          containerSelector: 'ol.nodes-tree'
#          itemPath: ''
#          itemSelector: 'li.nodes-tree-line'
#          handle: 'td.node-color-col, td.node-icon-col, td.node-label-col'
          nested: false
          vertical: true
          exclude: 'ol.components-tree'
#          pullPlaceholder: false
#          placeholder: '<li class="placeholder"/>'

          isValidTarget: (item, container) ->
            console.log "isValidTarget", item, container, that.currentDragID, container.options.dragID, container.options.dragID == 'N' && that.currentDragID == 'C'
            return container.options.dragID == 'N' && that.currentDragID == 'C'

#          onMousedown: (item, _super, event) ->
#            that.draggedWidth = 0
#            that.draggedHeight = 0
#            that.oldContainer = null
#
##            console.log "onMouseDown", $(event.target), $(event.target).parents('li.nodes-args-tree-line')
#            if _super(item, _super, event)
#              return $(event.target).parents('ol.nodes-args-tree').length == 0
#            else
#              return false

          onCancel: (item, container, _super, event) ->
            console.log "onCancel", item, container

          onDrag: (item, position, _super, event) ->
#            console.log "onDrag", item.position(), position
#            position.left /= 2
#            item.css(position)
            _super(item, position)

          onDragStart: (item, container, _super, event) ->
            that.currentDragID = container.options.dragID
            that.draggedWidth = item.width()
            that.draggedHeight = item.height()
            _super(item, container)

          afterMove: (placeholder, container) ->
  #            console.log "afterMove", placeholder, container
            if that.oldContainer != container
              if that.oldContainer
                that.oldContainer.el.removeClass("active")
              if container
                container.el.addClass("active")
              that.oldContainer = container
            if placeholder
              placeholder.width(that.draggedWidth)
              placeholder.height(that.draggedHeight)

          onDrop: (item, container, _super) ->
            console.log "onDrop", item, container
            _super(item, container)
            if container
              container.el.removeClass("active")
            scope = angular.element(item).scope()
            if scope and scope.$parent and scope.$parent.n
              scope.$parent.n.setModified(true)

          serialize: (parent, children, isContainer) ->
            return (if isContainer then children.join() else parent.text())
        )

      )
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

      $timeout(->
        Editor.refreshDragTrees()
      )
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
