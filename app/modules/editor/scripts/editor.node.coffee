angular.module('editor.node', ['app.globals', 'editor.module', 'editor.component', 'dynamicForm', 'ui.bootstrap.tpls', 'ui.bootstrap.modal'])

.factory('EditorNode', [
  'Editor'
  '$timeout'
  'Globals'
  '$http'
  'dynForm'
  'dynModal'
  '$rootScope'

  (Editor, $timeout, globals, $http, dynForm, dynModal, $rootScope) ->
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


    module: () ->
      Editor.module

    clearSelection: () ->
      @selected = null

    setSelection: (n) ->
      that = @
      require(['vc_global'], (VCGlobal) ->
        that.clearSelection()
        if n
          n = VCGlobal.findNode(n)
          if n
            that.selected = n
            n.makeVisible()
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

    getWidth: (n) ->
      w = 100
      n.foreachProperty(true, (p) ->
        w += p.width()
      )
      return w

    getHeight: (n, recursive) ->
      h = 24
      if recursive
        n.foreachChild((n) ->
          h += n.height(true)
        )
      n.foreachProperty(true, (p) ->
        h += p.height(recursive)
      )
      return h

    toggleExpandCollapse: (n, all) ->
      if n.isClosed()
        @expand(n, all)
      else
        @collapse(n, all)

    expand: (n, all) ->
      n.open(all)

    expandAll: (n) ->
      @expand(n, true)

    collapse: (n, all) ->
      n.close(all)

    collapseAll: (n) ->
      @collapse(n, true)

    nodeElement: (n) ->
      angular.element('#node-element_' + n.id())

    labelElement: (n) ->
      angular.element('#node-label_' + n.id())

    iconElement: (n) ->
      angular.element('#node-icon_' + n.id())

    attributesElement: (n) ->
      angular.element('#node-attributes_' + n.id())

    canEdit: (n) ->
      if n and n.$data.isNode
        return n.canEdit()
      else
        return false

    editOptions: (n) ->
      l = []
      m = n.module().getRoot()
      cc = n.getComponent()
      if m and cc and cc.valueKind()
        nl = m.childrenOfKind(cc.valueKind().name, true)
        for nn in nl
          l.push({ id: nn.id(), text: nn.name })
      return l

    edit: (n) ->
      if @canEdit(n)
        @currentEdit = n
        @oldEditValue = n.name
        if n.isValueKind()
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
#      if @isValueKind()
#        if @id
#          @node.name = @node.name.id
#        @setLink(@id())
      n = @currentEdit
      if n
        n.setModified(@oldEditValue != n.name)
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
#     @clipboard = angular.copy(@)

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

  ($scope, Rest, Editor, EditorNode, globals, dynForm, dynModal, $rootScope) ->

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

    $scope.editOptions = (n) ->
      EditorNode.editOptions(n)

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

    $scope.refresh = (cb) ->
      EditorNode.refresh(cb)

    $scope.rebuild = (cb) ->
      EditorNode.rebuild(cb)

    $scope.keyup = ($event) ->
      if @n and @isEditing(@n)
        if $event.keyCode == 13
          @saveEdit(@n)
        else if $event.keyCode == 27
          @cancelEdit(@n)
])

.controller('EditorNodePropertyCtrl', [
  '$scope'
  'Rest'
  'Editor'
  'EditorNode'
  'Globals'
  'dynForm'
  'dynModal'
  '$rootScope'

  ($scope, Rest, Editor, EditorNode, globals, dynForm, dynModal, $rootScope) ->

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

    $scope.canEdit = (n) ->
      EditorNode.canEdit(n)

    $scope.editOptions = (n) ->
      EditorNode.editOptions(n)

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

    $scope.keyup = ($event) ->
      if @n and @isEditing(@n)
        if $event.keyCode == 13
          @saveEdit(@n)
        else if $event.keyCode == 27
          @cancelEdit(@n)
])
