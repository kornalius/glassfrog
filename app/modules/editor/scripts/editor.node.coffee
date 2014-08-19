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
      if @currentEdit
        @saveEdit()

    setSelection: (n) ->
      that = @
      require(['vc_global'], (VCGlobal) ->
        n = VCGlobal.findNode(Editor.module, n)
        that.selected = n

        if n
          if n.$data and n.$data.isNode
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

    nodeElement: (n) ->
      n.element()

    labelElement: (n) ->
      if n and n.$data and n.$data.isNode
        angular.element('#node-label-id_' + n.id())
      else if n and n.$data and n.$data.isArg
        angular.element('#node-arg-label-id_' + n.getName())

    iconElement: (n) ->
      angular.element('#node-icon-id_' + n.id())

    attributesElement: (n) ->
      angular.element('#node-attributes-id_' + n.id())

    inputElement: (n) ->
      if n and n.$data
        if n.$data.isNode
          if n.hasEnum()
            return angular.element('#node-select-id_' + n.id())
          else
            return angular.element('#node-input-id_' + n.id())
        else if n.$data.isArg
          return angular.element('#node-arg-' + n.getInputType() + '-id_' + n.getName())
      return null

    canEdit: (n) ->
      if n and n.$data and (n.$data.isNode or n.$data.isArg)
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

    edit: (n, $event) ->
      if @canEdit(n)
        if @currentEdit
          @saveEdit()
        @currentEdit = n
        if n.$data and n.$data.isNode
          @oldEditValue = n.name
        else if n.$data and n.$data.isArg
          @oldEditValue = n.value
#        console.trace "edit()", @currentEdit, @oldEditValue
        that = @
        $timeout(->
          i = that.inputElement(n)
          if i and i.length
            if i[0].selectize
              i[0].selectize.focus()
            else
              i[0].focus()
            if i[0].select
              i[0].select()
        , 100)
        if $event
          $event.stopPropagation()

    saveEdit: () ->
      n = @currentEdit
#      console.trace "saveEdit()", @currentEdit, @oldEditValue
      if n
        if n.$data and n.$data.isNode and @oldEditValue and @oldEditValue != n.name
          if n.hasEnum() and typeof n.name != 'string'
            id = n.name.id
            n.name = null
            require(['vc_global'], (VCGlobal) ->
              n.setLink(id)
            )
          else
            n.setName(n.name)
        else if n.$data and n.$data.isArg and @oldEditValue and @oldEditValue != n.value
          n.setValue(n.value)

#        e = n.element()
#        if e and e.length
#          e = e.find('input')
#          if e and e.length
#            $(e).hide()

      @currentEdit = null
      @oldEditValue = null

    cancelEdit: () ->
      n = @currentEdit
#      console.trace "cancelEdit()", @currentEdit, @oldEditValue
      if n and @oldEditValue
        if n.$data and n.$data.isNode
          n.setName(@oldEditValue)
        else if n.$data and n.$data.isArg
          n.setValue(@oldEditValue)
      @currentEdit = null
      @oldEditValue = null

    isEditing: (n) ->
      @currentEdit == n

    makeVisible: (n) ->
      p = n.getParent()
      while p
        p.open()
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

    $scope.refresh = (selected) ->
      EditorNode.refresh(selected)

    $scope.toggle = (n, recursive) ->
#      console.log $(".nodes-tree")
      n.toggle(recursive)

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
      if EditorNode.currentEdit
        if $event.keyCode == 13
          @saveEdit(EditorNode.currentEdit)
        else if $event.keyCode == 27
          @cancelEdit()

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
