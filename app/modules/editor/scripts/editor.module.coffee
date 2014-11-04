angular.module('editor.module', ['editor.component', 'editor.node', 'dynamicForm', 'ui.bootstrap.tpls', 'ui.bootstrap.modal'])

.factory('EditorModule', [
  'Editor'
  'EditorNode'
  'EditorComponent'
  '$timeout'
  '$http'
  'dynForm'
  'dynModal'
  '$rootScope'

  (Editor, EditorNode, EditorComponent, $timeout, $http, dynForm, dynModal, $rootScope) ->

    moduleNodes: []
    selected: null
    popup: null

    share: (m, cb) ->
#      if @canShare()
#        that = @
#
#        model = [{users:[], host: false}]
#        formDefinition =
#          label: "Modal Form"
#          name: "modalForm"
#          size: 'md'
#          layout: {type: 'modal', style: 'horizontal'}
#
#          fields: [
#            label: "Share with"
#            type: "select"
#            description: "Who would you like to share this module with?"
#            config:
#              tags:[]
#              tokenSeparators: [",", " "]
#            fieldname: 'users'
#            required: true
#          ,
#            label: "Host data"
#            type: "check"
#            description: "Do you want to host all data on your plan?"
#            fieldname: 'host'
#          ]
#
#        dynModal.showModalForm(formDefinition, model, (ok) ->
#          if ok
#            console.log model[0]
#            dynModal.yesNoModal("Are you sure?", "Do you really want to share this module?", (ok) ->
#              if ok
#                users = []
#                if model[0].users
#                  for u in model[0].users
#                    users.push(u.text)
#                $http.post('/api/sharenode?node={0}&host={1}&users={2}'.format(that.node._id, model[0].host, users.join(',')))
#                .success((data, status) ->
#                  that.addOption('*')
#                  EditorNode.save(that.node, () ->
#                    cb(data) if cb
#                  )
#                )
#                .error((data, status) ->
#                  cb(null) if cb
#                )
#            )
#        )

    saveAll: (cb) ->
      require(['async', 'vc_global'], (async, VCGlobal) ->
        async.eachSeries(VCGlobal.modules.rows, (r, callback) ->
          @save(r, (ok) ->
            callback()
          )
        , (err) ->
          cb(err) if cb
        )
      )

    clearSelection: () ->
      @selected = null

    setSelection: (m) ->
      that = @
      @clearSelection()
      if m
        require(['vc_global'], (VCGlobal) ->
          m = VCGlobal.findModule(m)
          if !that.isSelection(m)
            Editor.editModule(m, (sm) ->
              EditorNode.clearSelection()
              that.selected = sm
              EditorComponent.refresh()
              if sm.scope()
                sm.scope().$apply()
            )
        )

    selection: () ->
      @selected

    isSelection: (m) ->
      @selected == m

    isOver: (m) ->
      Editor.isOver(m)

    setOver: (m) ->
      Editor.setOver(m)

    showpopup: (m) ->
      if @popup
        $timeout.cancel(@popup)
      @popup = $timeout(->
        $('#module-popover-id_' + m._id).popover('show')
      , 1500)

    hidepopup: (m) ->
      if @popup
        $timeout.cancel(@popup)
      $timeout(->
        $('#module-popover-id_' + m._id).popover('hide')
      )

    refresh: (cb) ->
      that = @
      require(['vc_module'], (Module) ->
        that.moduleNodes = Module.list()
        if Module.scope()
          Module.scope().$apply()
        cb() if cb
      )

    save: (m, cb) ->
      m.save((ok) ->
        cb(true) if cb
      )

    edit: (m, cb) ->
      m.edit((ok) ->
        cb(ok) if cb
      )

    new: (cb) ->

    delete: (m, cb) ->

    nodeElement: (m) ->
      m.element()

])

.controller('EditorModuleCtrl', [
  '$scope'
  'Rest'
  'Editor'
  'EditorModule'
  '$timeout'

  ($scope, Rest, Editor, EditorModule, $timeout) ->

    $scope.moduleNodes = []
    $scope.service = EditorModule

    $scope.$watchCollection('service.moduleNodes', (newVal) ->
      $scope.moduleNodes = newVal
    )

    $scope.treeOptions =
      accept: (sourceNodeScope, destNodesScope, destIndex) ->
        return false
#        s = sourceNodeScope.$modelValue
#        return s and s.$data and s.$data.isNode

      beforeDrag: (sourceNodeScope) ->
        return true

      dropped: (event) ->
#        n = event.source.nodeScope.$modelValue
#        if n
#          m = event.dest.nodesScope.$nodeScope
#          if m
#            n.$data._module = m
#            n.$data._parent = m.getRoot()

      dragStart: (event) ->

      dragMove: (event) ->

      dragStop: (event) ->

      beforeDrop: (event) ->

    $scope.nodeElement = (m) ->
      EditorModule.nodeElement(m)

    $scope.setOver = (m) ->
      EditorModule.setOver(m)

    $scope.isOver = (m) ->
      EditorModule.isOver(m)

    $scope.clearSelection = () ->
      EditorModule.clearSelection()

    $scope.setSelection = (m) ->
      EditorModule.setSelection(m)

    $scope.isSelection = (m) ->
      EditorModule.isSelection(m)

    $scope.showpopup = (m) ->
      EditorModule.showpopup(m)

    $scope.hidepopup = (m) ->
      EditorModule.hidepopup(m)

    $scope.edit = (m) ->
      EditorModule.edit(m, cb)

    $scope.new = (cb) ->
      EditorModule.edit(cb)

    $scope.save = (cb) ->
      EditorModule.save(@selected, cb)

    $scope.saveAll = (cb) ->
      EditorModule.saveAll(cb)

    $scope.share = (cb) ->
      EditorModule.share(@selected, cb)

    $scope.delete = (cb) ->
      EditorModule.share(@selected, cb)

    $scope.refresh = (cb) ->
      EditorModule.refresh(cb)

])
