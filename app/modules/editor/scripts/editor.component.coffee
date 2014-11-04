angular.module('editor.component', ['editor.node'])

.factory('EditorComponent', [
  '$timeout'
  'Editor'

  ($timeout, Editor) ->

    componentNodes: []
    componentCategories: []
#    origComponentNodes: null
    expandOver: null
    popup: null

    nodeElement: (m) ->
      m.element()

    showpopup: (c) ->
      if @popup
        $timeout.cancel(@popup)
      @popup = $timeout(->
        $('#component-popover-id_' + c._id).popover('show')
      , 1500)

    hidepopup: (c) ->
      if @popup
        $timeout.cancel(@popup)
      $timeout(->
        $('#component-popover-id_' + c._id).popover('hide')
      )

    refresh: (selected, cb) ->
      that = @
      require(['vc_global', 'vc_component'], (VCGlobal, VCComponent) ->
        that.componentNodes = VCComponent.list(selected, Editor.module)

#        console.log "refresh()"
#        for c in that.componentNodes
#          console.log c.getName()

        #        that.origComponentNodes = _.cloneDeep(that.componentNodes)

#        _findComponent = (c) ->
#          for cc in that.componentNodes
#            if cc.name and cc.name.toLowerCase() == c
#              return cc
#          return VCGlobal.findComponent(c)

        l = []
        if that.componentNodes
          for c in that.componentNodes
            categories = c.getCategories().reverse()
            if categories.length
              cc = categories.shift()
              if l.indexOf(cc) == -1
                l.push(cc)

        for c in l
          c.$data._components = c.getComponents(that.componentNodes)

        that.componentCategories = l

#        console.log "refresh()", l
#        if VCComponent.scope()
#          VCComponent.scope().$apply()
        cb() if cb
      )

    isExpandOver: (n) ->
      @expandOver == n

    setExpandOver: (n) ->
      @expandOver = n

])

.controller('EditorComponentCtrl', [
  '$scope'
  'Rest'
  'Editor'
  'EditorNode'
  'EditorComponent'
  '$parse'
  '$document'
  '$timeout'

  ($scope, Rest, Editor, EditorNode, EditorComponent, $parse, $document, $timeout) ->

    $scope.componentNodes = []
    $scope.componentCategories = []
    $scope.service = EditorComponent

    $scope.$watchCollection('service.componentNodes', (newVal) ->
      $scope.componentNodes = newVal
#      console.log "$watchCollection.componentNodes", $scope.componentNodes
    )

    $scope.$watchCollection('service.componentCategories', (newVal) ->
      $scope.componentCategories = newVal
#      console.log "$watchCollection.componentCategories", $scope.componentCategories
    )

    $scope.treeOptions =

      beforeDrag: (sourceNodeScope) ->
        return !sourceNodeScope.$modelValue.isCategory()

      dropped: (e) ->
        el = e?.dest?.nodesScope?.$element
        if el and el.length and $(el).is('.nodes-tree')
          c = angular.copy(e.source.nodeScope.$modelValue)
          idx = e.source.index
          if idx == -1
            e.source.nodesScope.$modelValue.push(c)
          else
            e.source.nodesScope.$modelValue.splice(idx, 0, c)

          idx = e.dest.index
          if idx != -1
            nodes = e.dest.nodesScope.$modelValue
            if e.dest.nodesScope.$nodeScope
              parent = e.dest.nodesScope.$nodeScope.$modelValue
            else
              parent = Editor.module.getRoot()
            n = c.newNode(null, parent, parent.module())
            nodes.splice(idx, 1, n)

        Editor.dragging = null

      dragStart: (e) ->
        sourceNodeScope = e.source.nodeScope
        Editor.dragging = sourceNodeScope.$modelValue

      dragStop: (e) ->
        Editor.dragging = null


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

    $scope.isExpandOver = (n) ->
      EditorComponent.isExpandOver(n)

    $scope.setExpandOver = (n) ->
      EditorComponent.setExpandOver(n)

])

.directive('renderComponent', [
  '$parse'
  '$timeout'

  ($parse, $timeout) ->
    restrict: 'A'

    link: (scope, element, attrs) ->
      c = $parse(attrs.renderComponent)(scope)
      if c
        c.render()
])
