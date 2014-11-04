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
      if n and n.$data
        return n.element('label')
      return null

    iconElement: (n) ->
      if n and n.$data
        return n.element('icon')
      return null

    attributesElement: (n) ->
      if n and n.$data
        return n.element('attributes')
      return null

    inputElement: (n) ->
      if n and n.$data
        if n.$data.isNode
          if n.hasEnum()
            return n.element('select')
          else
            return n.element('input')
        else if n.$data.isArg
          return n.element('input-' + n.getInputType())
      return null

    canEdit: (n) ->
      if n and n.$data and (n.$data.isNode or n.$data.isArg)
        return n.canEdit()
      else
        return false

    hasEnum: (n) ->
      n.hasEnum()

    getEnum: (n, asObject) ->
      return n.getEnum(asObject)

    hasMulti: (n) ->
      n.hasMulti()

    getMulti: (n, asObject) ->
      return n.getMulti(asObject)

    edit: (n, $event) ->
      if @canEdit(n)
        if @currentEdit != n
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
#          if n.hasEnum() and typeof n.name != 'string'
#            id = n.name.id
#            n.name = null
#            require(['vc_global'], (VCGlobal) ->
#              n.setLink(id)
#            )
#          else
          newName = n.name
          n.name = ''
          n.setName(newName)
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
      n.makeVisible()

    copy: (n) ->
#     @clipboard = _.cloneDeep(n)

    cut: (n) ->
#      @copy(n)
#      @remove(n)

    paste: (n) ->

    canRemove: (n) ->
      n.canRemove()

    remove: (n) ->
      n.remove()

    render: (n) ->
      cc = n.getComponent()
      if cc
        cc.render(n)

      for nn in n.children()
        cc = nn.getComponent()
        if cc
          cc.render(n)

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

    $scope.treeOptions =
      accept: (sourceNodeScope, destNodesScope, destIndex) ->
        ok = false
        sn = sourceNodeScope.$modelValue
        dn = destNodesScope.$modelValue
        if destNodesScope.$nodeScope
          dn = destNodesScope.$nodeScope.$modelValue
        else if Editor.module
          dn = Editor.module.getRoot()
        else
          dn = null
        if sn and dn
          if sn.$data and sn.$data.isComponent
            ok = dn.canAdd(sn, true)
          else if sn.$data and sn.$data.isNode
            ok = sn.canMove(dn, true)
#        console.log sourceNodeScope, sn, destNodesScope, dn, destIndex, ok
        return ok

      dropped: (e) ->
        sourceIndex = e.source.index
        destIndex = e.dest.index
        n = e.source.nodeScope.$modelValue
        if e.source.nodesScope.$nodeScope
          psn = e.source.nodesScope.$nodeScope.$modelValue
        else
          psn = Editor.module.getRoot()
        if e.dest.nodesScope.$nodeScope
          pdn = e.dest.nodesScope.$nodeScope.$modelValue
        else
          pdn = Editor.module.getRoot()
        if psn != pdn or sourceIndex != destIndex
          psn.setModified(true)
          n.setModified(true)
        Editor.dragging = null

      dragStart: (e) ->
        sourceNodeScope = e.source.nodeScope
        Editor.dragging = sourceNodeScope.$modelValue

      dragStop: (e) ->
        Editor.dragging = null

#      dragMove: (e) ->
#        sourceNodeScope = e.source.nodeScope
#        destNodesScope = e.dest.nodesScope
#        destIndex = e.dest.index
#        sn = sourceNodeScope.$modelValue
#        dn = destNodesScope.$modelValue
#        n = if dn then dn[destIndex] else null
#        if sn != n and n != $scope.prevDragOver
#          console.log n
#          $scope.prevDragOverTime = Date.now()
#          $scope.prevDragOver = n
#        if n and n.$data and n.$data.isNode and n.isClosed()
#          t = Date.now()
#          console.log t - $scope.prevDragOverTime
#          if n == $scope.prevDragOver and t >= $scope.prevDragOverTime + 1000
#            n.open()

    $scope.tinycolor = window.tinycolor

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

    $scope.inputElement = (n) ->
      EditorNode.inputElement(n)

    $scope.canEdit = (n) ->
      EditorNode.canEdit(n)

    $scope.hasEnum = (n) ->
      EditorNode.hasEnum(n)

    $scope.getEnum = (n, asObject) ->
      EditorNode.getEnum(n, asObject)

    $scope.hasMulti = (n) ->
      EditorNode.hasMulti(n)

    $scope.getMulti = (n, asObject) ->
      EditorNode.getMulti(n, asObject)

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

    $scope.canRemove = (n) ->
      EditorNode.canRemove(n)

    $scope.removeIt = (n) ->
      EditorNode.remove(n)

    $scope.refresh = (selected) ->
      EditorNode.refresh(selected)

#    $scope.getSchema = (cb) ->
#      planes = new Rest('Planes')
#      planes.create({'FlightNo': '1'}, (p, err) ->
#        console.log p, err
#        planes.create({'FlightNo': '2'}, (p, err) ->
#          console.log p, err
#          planes.create({'FlightNo': '3'}, (p, err) ->
#            console.log p, err
#            planes.find({l: 10}, (result, err) ->
#              console.log result, err
#              for p in planes.rows
#                console.log p
#            )
#          )
#        )
#      )

    $scope.toggle = (n, recursive) ->
      if !@isEditing(n)
        n.toggle(recursive)

    $scope.save = (cb) ->
      Editor.saveModule(Editor.module, (ok) ->
        cb(ok) if cb
      )

    $scope.alert = (cb) ->
      dynModal.alert("This is an alert!", () ->
        cb() if cb
      )

    $scope.choose = (cb) ->
      dynModal.chooseModal({title:"Select", caption:"Select all that applies", items:[
        {label: 'Alain', value: 1},
        {label: 'Steven', value: 2},
        {label: 'Paul', value: 3},
        {label: 'Joe', value: 4},
        {label: 'Aganistaz', value: 5}
      ]}, ->
        cb() if cb
      )

    $scope.quickForm = (cb) ->
      dynForm.quickForm('testForm', null, null, 'Test Form', 'user', (formDefinition) ->
        user = new Rest('user')
        user.findById(globals.user._id, ->
#          $('#editor-preview-main').contents().remove()
          dynModal.showModalForm({scope:$scope, formDefinition:formDefinition, model:user}, ->
            cb() if cb
          )
        )
      )

    $scope.preview = (node, cb) ->
      dynForm.quickForm('testForm', null, null, 'Test Form', 'user', (formDefinition) ->
        user = new Rest('user')
        user.findById(globals.user._id, ->
          scope = $rootScope.$new(true)
          dynForm.build(scope, formDefinition, user, null, (template) ->
            dynModal.showModal({title:'Preview', scope:scope, model:user, template:template}, ->
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

.controller('EditorNodeEditCtrl', [
  '$scope'

  ($scope) ->

    $scope.$watch('n.name', (newValue, oldValue) ->
      if newValue != oldValue
        $scope.n.setName(newValue)
    )

])

.controller('EditorNodeArgEditCtrl', [
  '$scope'

  ($scope) ->

    $scope.$watch('a.value', (newValue, oldValue) ->
      if !_.isEqual(newValue, oldValue)
#        console.log "$watch a.value", newValue, oldValue
        $scope.a.setValue(newValue)
        $scope.a.setModified(true)
    )

])

.directive('renderNode', [
  '$parse'

  ($parse) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
      n = $parse(attrs.renderNode)(scope)
      if n
        n.render()
])
