angular.module('editor.component', ['app.globals', 'dragdrop.service', 'editor.node'])

.factory('EditorComponent', [
  '$timeout'
  'Editor'

  ($timeout, Editor) ->

    componentNodes: []
    origComponentNodes: null
    popup: null

    nodeElement: (m) ->
      m.element()

    showpopup: (c) ->
      if @popup
        $timeout.cancel(@popup)
      @popup = $timeout(->
        $('#component-popover_' + c._id).popover('show')
      , 1500)

    hidepopup: (c) ->
      if @popup
        $timeout.cancel(@popup)
      $timeout(->
        $('#component-popover_' + c._id).popover('hide')
      )

    refresh: (selected, cb) ->
      that = @
      require(['vc_component'], (Component) ->
        that.componentNodes = Component.list(selected, Editor.module)
        that.origComponentNodes = _.cloneDeep(that.componentNodes)
        if Component.scope()
          Component.scope().$apply()
        cb() if cb
      )

])

.controller('EditorComponentCtrl', [
  '$scope'
  'Rest'
  'Editor'
  'EditorNode'
  'EditorComponent'
  '$parse'
  '$document'
  'Globals'
  '$timeout'

  ($scope, Rest, Editor, EditorNode, EditorComponent, $parse, $document, globals, $timeout) ->

    $scope.componentNodes = []
    $scope.service = EditorComponent

    $scope.$watchCollection('service.componentNodes', (newVal) ->
      $scope.componentNodes = newVal
    )

    $scope.treeOptions =

      accept: (sourceNodeScope, destNodesScope, destIndex) ->
        return false

      beforeDrag: (sourceNodeScope) ->
        return true

      dropped: (event) ->
        c = event.source.nodeScope.$modelValue
        t = event.dest
        if c and t and !t.nodesScope.nodrop and Editor.module
          nodes = event.dest.nodesScope.$modelValue
          parentNodeScope = event.dest.nodesScope.$nodeScope
          idx = event.dest.index
          d = event.dest.nodesScope.$nodeScope
          require(['vc_global', 'vc_node', 'vc_component'], (VCGlobal, Node, Component) ->
            event.dest.nodesScope.$apply(->
              if parentNodeScope
                p = parentNodeScope.$modelValue
              else if !d
                p = VCGlobal.module().getRoot()
              else
                p = null
              n = c.add(c.name, VCGlobal.module(), p)
              nodes.splice(idx, 1)
              n.setOrder(idx)
              EditorNode.setSelection(n)
            )
          )

      dragStart: (event) ->
#        console.log "dragStart()", event.source.nodeScope.$treeScope.$parent
        event.source.nodeScope.$treeScope.$parent.hidepopup(event.source.nodeScope.$modelValue)

        if !$scope.origComponentNodes
          $scope.origComponentNodes = _.cloneDeep($scope.componentNodes)

        $timeout(->
          event.elements.placeholder.replaceWith(event.elements.dragging.clone().find('li'))
        )

      dragMove: (event) ->
#        console.log event.source.nodeScope.c, event.source.index, event.dest.nodesScope, event.dest.index

      dragStop: (event) ->
        if $scope.origComponentNodes
          for i in [0..$scope.origComponentNodes.length - 1]
            if i < $scope.componentNodes.length and $scope.componentNodes[i].getName() != $scope.origComponentNodes[i].getName()
              $scope.componentNodes.splice(i, 0, _.cloneDeep($scope.origComponentNodes[i]))

      beforeDrop: (event) ->


    $($document).ready(() ->
      $('[data-toggle=components-offcanvas]').click(() ->
        $(this).toggleClass('visible-xs text-center')
        $(this).find('span').toggleClass('cic-chevron-right2 cic-chevron-left2')
        $('.row-toolbar-offcanvas').toggleClass('active')
        $('#lg-components').toggleClass('hidden-xs').toggleClass('visible-xs')
        $('#xs-components').toggleClass('visible-xs').toggleClass('hidden-xs')
        $('#btnShow').toggle()
      )
    )

    require(['vc_global', 'vc_component'], (VCGlobal, Component) ->
      $scope.findComponent = VCGlobal.findComponent
    )

    $scope.search = Editor.search

    $scope.nodeElement = (c) ->
      EditorComponent.nodeElement(c)

    $scope.showpopup = (c) ->
      EditorComponent.showpopup(c)

    $scope.hidepopup = (c) ->
      EditorComponent.hidepopup(c)

    $scope.refresh = (selected, cb) ->
      EditorComponent.refresh(selected, cb)

])

.directive('renderComponent', [
  '$parse'

  ($parse) ->
    restrict: 'A'

    link: (scope, element, attrs) ->
      c = $parse(attrs.renderComponent)(scope)
      if c
        c.doRender()
])
