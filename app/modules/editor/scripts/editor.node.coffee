angular.module('editor.node', ['app.globals', 'editor.component', 'nodes', 'dynamicForm', 'ui.bootstrap.tpls', 'ui.bootstrap.modal'])

.factory('EditorNode', [
  'Editor'
  '$timeout'
  '$injector'
  'Globals'
  '$http'
  'dynForm'
  'dynModal'
  '$rootScope'

  (Editor, $timeout, $injector, globals, $http, dynForm, dynModal, $rootScope) ->
    edit: null
    expandOver: null
    toolIconOver: null

    selected: null
    searchValue: 0
    searchNode: null
    searchVisible: false

    clipboard: null

    makeNode: (n) ->
      EditorNode = $injector.get('EditorNode')

      n.$data.isOpened = () ->
        return @hasState('o')

      n.$data.isClosed = () ->
        return !@hasState('o')

      n.$data.toggleExpandCollapse = (all) ->
        if @isClosed()
          @expand(all)
        else
          @collapse(all)

      n.$data.expand = (all) ->
        if (all? and all == true)
          for n in @children()
            if n.$data
              n.$data.expand(all)
        @addState('o')

      n.$data.expandAll = () ->
        @expand(true)

      n.$data.collapse = (all) ->
        if (all? and all == true)
          for n in @children()
            if n.$data
              n.$data.collapse(all)
        @delState('o')

      n.$data.collapseAll = () ->
        @collapse(true)

      n.$data.nodeElement = () ->
        return angular.element('#node-element_' + @node._id)

      n.$data.labelElement = () ->
        return angular.element('#node-label_' + @node._id)

      n.$data.iconElement = () ->
        return angular.element('#node-icon_' + @node._id)

      n.$data.attributesElement = () ->
        return angular.element('#node-attributes_' + @node._id)

      n.$data.canEdit = () ->
        return globals.Node_Data and !@isSystem() and !@isShared() and @component and @component.$data and !@component.$data.isLocked()
      #        return !@isSystem() and !@isShared() and @getOwner() == Globals.user._id and @component and @component.$data and !@component.$data.isLocked()

      n.$data.editOptions = () ->
        l = []
        m = @parentModule()
        if m and m.$data and @component and @component.$data and @component.$data.valueKind?
          nl = m.$data.childrenOfKind(@component.$data.valueKind.name, true)
          for n in nl
            l.push({id: n._id, text: n.name})
        return l

      n.$data.edit = () ->
        if @canEdit()
          EditorNode.edit = @node
          EditorNode.oldEditValue = @node.name
          if @isValueKind()
            if @node.name?
              n = globals.Node_Data.getNodeById(@node.name)
            i = angular.element('#node-select_' + @node._id)
            if i and n
              i.select2('data', {id: n._id, text: n.name})
            $timeout(->
              i.select2('focus')
            , 100)
          else
            i = angular.element('#node-input_' + @node._id)
            $timeout(->
              i.focus()
              i.select()
            , 100)

      n.$data.saveEdit = () ->
        if @isValueKind()
          if @node.name.id
            @node.name = @node.name.id
          @setLink(@node.name)
        if EditorNode.oldEditValue != @node.name
          @addState('m')
        EditorNode.edit = null
        EditorNode.oldEditValue = null

      n.$data.cancelEdit = () ->
        if EditorNode.edit == @node and EditorNode.oldEditValue
          @node.name = EditorNode.oldEditValue
        EditorNode.edit = null
        EditorNode.oldEditValue = null

      n.$data.isEditing = () ->
        EditorNode.edit == @node

      n.$data.makeVisible = () ->
        p = @parent
        while p
          if !p.$data
            break
          p.$data.expand()
          p = p.$data.parent

      n.$data.select = (select) ->
        if select
          EditorNode.selected = @node
        else if @isSelected()
          EditorNode.selected = null

      n.$data.isSelected = () ->
        EditorNode.selected == @node

      n.$data.search = () ->
        @_this.search(@node)

      n.$data.copy = () ->
#        EditorNode.clipboard = angular.copy(@node)

      n.$data.cut = () ->
        @copy()
        @remove()

      n.$data.paste = () ->

      n.$data.render = () ->
        if @component and @component.$data
          @component.$data.render(@node)
        for n in @children()
          if n.$data and n.$data.component and n.$data.component.$data
            n.$data.component.$data.render(n)

      n.$data.canShare = () ->
        @kindOf('Module') and !@isSharing()

      n.$data.share = (cb) ->
        if @canShare()
          that = @

          model = [{users:[], host: false}]
          formDefinition =
            label: "Modal Form"
            name: "modalForm"
            size: 'md'
            layout: {type: 'modal', style: 'horizontal'}

            fields: [
              label: "Share with"
              type: "select"
              description: "Who would you like to share this module with?"
              config:
                tags:[]
                tokenSeparators: [",", " "]
              fieldname: 'users'
              required: true
            ,
              label: "Host data"
              type: "check"
              description: "Do you want to host all data on your plan?"
              fieldname: 'host'
            ]

          dynModal.showModalForm(formDefinition, model, (ok) ->
            if ok
              console.log model[0]
              dynModal.yesNoModal("Are you sure?", "Do you really want to share this module?", (ok) ->
                if ok
                  users = []
                  if model[0].users
                    for u in model[0].users
                      users.push(u.text)
                  $http.post('/api/sharenode?node={0}&host={1}&users={2}'.format(that.node._id, model[0].host, users.join(',')))
                  .success((data, status) ->
                    that.addOption('*')
                    EditorNode.save(that.node, () ->
                      cb(data) if cb
                    )
                  )
                  .error((data, status) ->
                    cb(null) if cb
                  )
              )
          )

      n.$data.isOver = () ->
        return Editor.isOver(@node)

      n.$data.setOver = (n) ->
        Editor.setOver(n)

      return n

    clearSelection: () ->
      @selected = null

    setSelection: (n) ->
      if n
        @selected = globals.Node_Data.getNode(n)
        if n.$data
          n.$data.makeVisible()
      else
        @clearSelection()

    selection: (l, n) ->
      return @selected

    isOver: (n) ->
      return Editor.isOver(n)

    setOver: (n) ->
      Editor.setOver(n)

    save: (n, cb) ->

      _refresh = () ->
        delete n.$data
        r.$data = null
        Node_Data.makeNode(n)
        Node.makeNode(n)
        EditorNode.makeNode(n)
        cb(true) if cb

      if n.$data
        if n.$data.isNew()
          Node.restPush(n, (result) ->
            _refresh()
          )
        else if n.$data.isDeleted()
          Node.restDelete(n, (result) ->
            _refresh()
          )
        else if n.$data.isModified()
          Node.restUpdate(n, (result) ->
            _refresh()
          )
        else
          cb(false) if cb
      else
        cb(false) if cb

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
  'Node'
  'Globals'
  'dynForm'
  'dynModal'
  '$rootScope'

  ($scope, Rest, Editor, EditorNode, Node, globals, dynForm, dynModal, $rootScope) ->

    require(['Node_Data'], (Node_Data) ->
      $scope.setOver = EditorNode.setOver
      $scope.isOver = EditorNode.isOver
      $scope.clearSelection = EditorNode.clearSelection
      $scope.setSelection = EditorNode.setSelection
      $scope.getNode = Node_Data.getNode
      $scope.getNodeById = Node_Data.getNodeById
      $scope.getNodeByName = Node_Data.getNodeByName
    )

    #    $timeout(->
    #    s = angular.element("#search-dropdown-select")
    #    s.bind('change', (event) ->
    #      if $scope.$$phase || $scope.$root.$$phase
    #        return
    #
    #      if Node.$searchNode and Node.$searchValue?
    #        if child
    #          nn = Node.searchNode.$data.addChild(null, Node.searchValue)
    #        else
    #          nn = Node.searchNode.$data.add(null, Node.searchValue)
    #
    #      $timeout(->
    #        Node.searchVisible = false
    #        Node.searchNode = null
    #      , 100)
    #    )
    #    , 100)

    $scope.list = () ->
      _listChildren = (list, node) ->
        if node.$data
          for n in node.$data.children()
            list.push(n)
            if n.$data.isOpened()
              _listChildren(list, n)

      list = []

      if globals.Node_Data and globals.Node_Data.rest
        for n in globals.Node_Data.rest.rows
          if n.$data and n.$data.isRoot() and !n.$data.isDeleted()
            list.push(n)
            if n.$data.isOpened()
              _listChildren(list, n)

      return list.sort((a, b) ->
        if a.$data and b.$data
          ao = a.$data.flatOrder()
          bo = b.$data.flatOrder()
          if ao < bo
            return -1
          else if ao > bo
            return 1
          else
            return 0
        else
          return 0
      )

    $scope.save = (cb) ->
      require(['async'], (async) ->
        if globals.Node_Data and globals.Node_Data.rest
          async.eachSeries(globals.Node_Data.rest.rows, (row, callback) ->
            EditorNode.save(row, (ok) ->
              callback()
            )
          , (err) ->
            cb(err) if cb
          )
        else
          cb(null) if cb
      )

    $scope.alert = (cb) ->
      dynModal.alert("This is an alert!", () ->
        cb() if cb
      )

    $scope.choose = (cb) ->
      dynModal.chooseModal("Select", "Select all that applies", [{label:'Alain', value:1}, {label:'Steven', value:2}, {label:'Paul', value:3}, {label:'Joe', value:4}, {label:'Aganistaz', value:5}], () ->
        cb() if cb
      )

    $scope.quickForm = (cb) ->
      dynForm.quickForm('testForm', null, null, 'Test Form', 'user', (formDefinition) ->
        console.log formDefinition
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
      Node.refresh(cb)

    $scope.rebuild = (cb) ->
      Node.rebuild(cb)

    $scope.keyup = ($event) ->
      if @n and @n.$data and @n.$data.isEditing()
        if $event.keyCode == 13
          @n.$data.saveEdit()
        else if $event.keyCode == 27
          @n.$data.cancelEdit()
])
