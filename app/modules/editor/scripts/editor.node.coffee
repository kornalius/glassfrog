angular.module('editor.node', ['app.globals', 'editor.module', 'editor.component', 'dynamicForm', 'ui.bootstrap.tpls', 'ui.bootstrap.modal'])

.factory('EditorNode', [
  'Editor'
  'EditorComponent'
  '$timeout'

  (Editor, EditorComponent, $timeout) ->
    currentEdit: null
    expandOver: null
    toolIconOver: null

    selected: null
    searchValue: 0
    searchNode: null
    searchVisible: false

    clipboard: null

#    makeNode: (n) ->
#
#      n.$data.share = (cb) ->
#        if @canShare()
#          that = @
#
#          model = [{users:[], host: false}]
#          formDefinition =
#            label: "Modal Form"
#            name: "modalForm"
#            size: 'md'
#            layout: {type: 'modal', style: 'horizontal'}
#
#            fields: [
#              label: "Share with"
#              type: "select"
#              description: "Who would you like to share this module with?"
#              config:
#                tags:[]
#                tokenSeparators: [",", " "]
#              fieldname: 'users'
#              required: true
#            ,
#              label: "Host data"
#              type: "check"
#              description: "Do you want to host all data on your plan?"
#              fieldname: 'host'
#            ]
#
#          dynModal.showModalForm(formDefinition, model, (ok) ->
#            if ok
#              console.log model[0]
#              dynModal.yesNoModal("Are you sure?", "Do you really want to share this module?", (ok) ->
#                if ok
#                  users = []
#                  if model[0].users
#                    for u in model[0].users
#                      users.push(u.text)
#                  $http.post('/api/sharenode?node={0}&host={1}&users={2}'.format(that.node._id, model[0].host, users.join(',')))
#                  .success((data, status) ->
#                    that.addOption('*')
#                    EditorNode.save(that.node, () ->
#                      cb(data) if cb
#                    )
#                  )
#                  .error((data, status) ->
#                    cb(null) if cb
#                  )
#              )
#          )


    refreshComponents: (selected) ->
      EditorComponent.refresh(selected)

    refresh: () ->

    module: () ->
      Editor.module

    clearSelection: () ->
      @setSelection(null)

    setSelection: (n) ->
      that = @
      require(['vc_global'], (VCGlobal) ->
        n = VCGlobal.findNode(Editor.module, n)
        that.selected = n

        if n
          that.makeVisible(n)
        else if Editor.module
          n = Editor.module.getRoot()

        that.refreshComponents(n)

        if n and n.scope()
          n.scope().$apply()
      )

    selection: () ->
      @selected

    isSelection: (n) ->
      @selected == n

    isOver: (n) ->
      Editor.isOver(n)

    setOver: (n) ->
      Editor.setOver(n)

    isExpandOver: (n) ->
      @expandOver == n

    setExpandOver: (n) ->
      @expandOver = n

    toggleExpandCollapse: (n, all) ->
      if n.isCollapsed()
        n.expand(all)
      else
        n.collapse(all)

    expand: (n, all) ->
      if (all? and all == true)
        for nn in n.children()
          nn.expand(all)
      n.addState('o')

    expandAll: (n) ->
      n.expand(true)

    collapse: (n, all) ->
      if (all? and all == true)
        for nn in n.children()
          nn.collapse(all)
      n.delState('o')

    collapseAll: (n) ->
      n.collapse(true)

    nodeElement: (n) ->
      n.element()

    labelElement: (n) ->
      angular.element('#node-label_' + n.id())

    iconElement: (n) ->
      angular.element('#node-icon_' + n.id())

    attributesElement: (n) ->
      angular.element('#node-attributes_' + n.id())

    canEdit: (n) ->
      if n and n.$data and n.$data.isNode
        return n.canEdit()
      else
        return false

    hasEnum: (n) ->
      n.hasEnum()

    getEnum: (n) ->
      l = []
      x = 0
      for nn in n.getEnum()
        if nn and nn.$data and nn.$data.isNode
          l.push({ id: nn.id(), text: nn.getPath(true) })
        else if nn and nn.$data and nn.$data.isComponent
          l.push({ id: nn.id(), text: nn.name })
        else if nn and nn.$data and nn.$data.isModule
          l.push({ id: nn.id(), text: nn.name })
        else if typeof nn is 'string'
          l.push({ id: x++, text: nn })
      return l

    edit: (n) ->
      if @canEdit(n)
        @currentEdit = n
        @oldEditValue = n.name
        if n.hasEnum()
          i = angular.element('#node-select_' + n.id())
          if i
            i.select2('data', { id: n.id(), text: n.name })
          $timeout(->
            i.select2('focus')
          , 100)
        else
          i = angular.element('#node-input_' + n.id())
          $timeout(->
            i.focus()
            i.select()
          , 100)

    saveEdit: () ->
      n = @currentEdit
      if n and @oldEditValue and @oldEditValue != n.name
        if n.hasEnum() and typeof n.name != 'string'
          id = n.name.id
          n.name = null
          require(['vc_global'], (VCGlobal) ->
            n.setLink(id)
          )
        else
          n.setName(n.name)
      @currentEdit = null
      @oldEditValue = null

    cancelEdit: () ->
      n = @currentEdit
      if n and @currentEdit == n and @oldEditValue
        n.setName(@oldEditValue)
      @currentEdit = null
      @oldEditValue = null

    isEditing: (n) ->
      @currentEdit == n

    makeVisible: (n) ->
      p = n.getParent()
      while p
        p.expand()
        p = p.getParent()

    copy: (n) ->
#     @clipboard = _.cloneDeep(@)

    cut: (n) ->
#      @copy()
#      @remove()

    paste: (n) ->

    doRender: (n) ->
      cc = n.getComponent()
      if cc
        cc.doRender(n)

      for nn in n.children()
        cc = nn.getComponent()
        if cc
          cc.doRender(n)

#    save: (n, cb) ->
#
#      _refresh = () ->
#        n.clearData()
#        r.$data = null
#        Node.make(n)
#        cb(true) if cb
#
#      if n.isNew()
#        Node.restPush(n, (result) ->
#          _refresh()
#        )
#      else if n.isDeleted()
#        Node.restDelete(n, (result) ->
#          _refresh()
#        )
#      else if n.isModified()
#        Node.restUpdate(n, (result) ->
#          _refresh()
#        )
#      else
#        cb(false) if cb

#    search: (n, child) ->
#      @searchNode = n
#
#      l = []
#
#      cn = null
#      if @searchNode
#        if child
#          cn = @searchNode
#        else if @searchNode.$data
#          cn = @searchNode.$data.parent
#
#      if cn
#        if cn.$data
#        ac = cn.$data.component.$data.accepts()
#        a = ac
#      else
#        ac = null
#        a = Editor.components.rows
#
#      for c in a
#        if c.name
#          l.push({id: c._id, text: c.name})
#
#      for nn in Editor.nodes.rows
#        if nn.name
#          if !ac or ac.indexOf(nn.$data.component) != -1
#            ok = true
#            for ll in l
#              if ll.$data.id() == nn.$data.id()
#                ok = false
#                break
#            if ok
#              l.push({id: nn.$data.id(), text: nn.name})
#
#      console.log cn, a, l
#
#      s.select2(
#        data:
#          results: l
#          text: 'text'
#      )
#
#      @searchVisible = true
#
#      $timeout(->
#        $timeout(->
#          s.data('select2').focus()
#        , 10)
#      , 10)
])

.controller('EditorNodeCtrl', [
  '$scope'
  'Rest'
  'Editor'
  'EditorNode'
  'Globals'
  'dynForm'
  'dynModal'
  '$rootScope'
  '$timeout'

  ($scope, Rest, Editor, EditorNode, globals, dynForm, dynModal, $rootScope, $timeout) ->

    $scope.dragOver = (n, dragNode, dragParent) ->
      return true

    $scope.drop = (n, dragNode, dragParent) ->

#    $scope.treeOptions =
#      accept: (sourceNodeScope, destNodesScope, destIndex) ->
#        s = sourceNodeScope.$modelValue
#        t = destNodesScope.$nodeScope
#        if t
#          p = t.$modelValue
#        else if Editor.module
#          p = Editor.module.getRoot()
#        else
#          p = null
#
#        ok = false
#        if p and p.$data and p.$data.isNode and s and s.$data
#          if s.$data.isComponent
#            ok = p.getComponent().doAccept(null, s)
#          else
#            ok = p.getComponent().doAccept(s, s.getComponent())
#
#        return Editor.module and ok
#
#      beforeDrag: (sourceNodeScope) ->
#        return true
#
#      dropped: (event) ->
#        n = event.source.nodeScope.$modelValue
#        if n and n.$data and Editor.module
#          d = event.dest.nodesScope.$nodeScope
#          if d and d.$data and d.$data.isNode
#            p = d.$modelValue
#          else if !d
#            p = Editor.module.getRoot()
#          else
#            p = null
#
#          if n.$data._parent != p
#            if n.$data._parent and n.$data._parent.$data
#              n.$data._parent.setModified(true)
#            n.$data._parent = p
#            n.setModified(true)
#
#      dragStart: (event) ->
#
#      dragMove: (event) ->
#
#      dragStop: (event) ->
#
#      beforeDrop: (event) ->

    $scope.module = () ->
      EditorNode.module()

    $scope.setOver = (n) ->
      EditorNode.setOver(n)

    $scope.isOver = (n) ->
      EditorNode.isOver(n)

    $scope.clearSelection = () ->
      EditorNode.clearSelection()

    $scope.setSelection = (n) ->
      EditorNode.setSelection(n)

    $scope.isSelection = (n) ->
      EditorNode.isSelection(n)

    $scope.isExpandOver = (n) ->
      EditorNode.isExpandOver(n)

    $scope.setExpandOver = (n) ->
      EditorNode.setExpandOver(n)

    $scope.toggleExpandCollapse = (n, all) ->
      EditorNode.toggleExpandCollapse(n, all)

    $scope.expand = (n, all) ->
      EditorNode.expand(n, all)

    $scope.expandAll = (n) ->
      EditorNode.expandAll(n)

    $scope.collapse = (n, all) ->
      EditorNode.collapse(n, all)

    $scope.collapseAll = (n) ->
      EditorNode.collapseAll(n)

    $scope.nodeElement = (n) ->
      EditorNode.nodeElement(n)

    $scope.labelElement = (n) ->
      EditorNode.labelElement(n)

    $scope.iconElement = (n) ->
      EditorNode.iconElement(n)

    $scope.attributesElement = (n) ->
      EditorNode.attributesElement(n)

    $scope.canEdit = (n) ->
      EditorNode.canEdit(n)

    $scope.hasEnum = (n) ->
      EditorNode.hasEnum(n)

    $scope.getEnum = (n) ->
      EditorNode.getEnum(n)

    $scope.edit = (n) ->
      EditorNode.edit(n)

    $scope.saveEdit = () ->
      EditorNode.saveEdit()

    $scope.cancelEdit = () ->
      EditorNode.cancelEdit()

    $scope.isEditing = (n) ->
      EditorNode.isEditing(n)

    $scope.makeVisible = (n) ->
      EditorNode.makeVisible(n)

    $scope.copy = (n) ->
      EditorNode.copy(n)

    $scope.cut = (n) ->
      EditorNode.cut(n)

    $scope.paste = (n) ->
      EditorNode.paste(n)

    $scope.toggle = (n) ->
      n.collapsed = !n.collapsed

    $scope.refresh = (selected) ->
      EditorNode.refresh(selected)

    #    $scope.save = (cb) ->
    #      require(['async'], (async) ->
    #        async.eachSeries(Node.rows, (row, callback) ->
    #          EditorNode.save(row, (ok) ->
    #            callback()
    #          )
    #        , (err) ->
    #          cb(err) if cb
    #        )
    #      )

    $scope.alert = (cb) ->
      dynModal.alert("This is an alert!", () ->
        cb() if cb
      )

    $scope.choose = (cb) ->
      dynModal.chooseModal("Select", "Select all that applies", [
        {label: 'Alain', value: 1},
        {label: 'Steven', value: 2},
        {label: 'Paul', value: 3},
        {label: 'Joe', value: 4},
        {label: 'Aganistaz', value: 5}
      ], () ->
        cb() if cb
      )

    $scope.quickForm = (cb) ->
      dynForm.quickForm('testForm', null, null, 'Test Form', 'user', (formDefinition) ->
        user = new Rest('user')
        user.fetch(globals.user._id, ->
#          $('#editor-preview-main').contents().remove()
          dynModal.showModalForm(formDefinition, user, () ->
            cb() if cb
          )
        )
      )

    $scope.preview = (node, cb) ->
      dynForm.quickForm('testForm', null, null, 'Test Form', 'user', (formDefinition) ->
        user = new Rest('user')
        user.fetch(globals.user._id, ->
          scope = $rootScope.$new(true)
          dynForm.build(scope, formDefinition, user, null, (template) ->
            dynModal.showModal('Preview', scope, template, () ->
              cb() if cb
            )
          )
        )
      )

    $scope.keyup = ($event) ->
      if @n and @isEditing(@n)
        if $event.keyCode == 13
          @saveEdit(@n)
        else if $event.keyCode == 27
          @cancelEdit(@n)
])

.directive('renderNode', [
  '$parse'

  ($parse) ->
    restrict: 'A'

    link: (scope, element, attrs) ->
      n = $parse(attrs.renderNode)(scope)
      if n
        n.doRender()
])
