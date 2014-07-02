angular.module('editor.module', ['app.globals', 'editor.component', 'editor.node', 'dynamicForm', 'ui.bootstrap.tpls', 'ui.bootstrap.modal'])

.factory('EditorModule', [
  'Editor'
  '$timeout'
  'Globals'
  '$http'
  'dynForm'
  'dynModal'
  '$rootScope'

  (Editor, $timeout, globals, $http, dynForm, dynModal, $rootScope) ->

    selected: null

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

    save: (m, cb) ->
      require(['vc_module'], (Module) ->
        if m.isModified()
          m.push(n, (result) ->
            Module.make(m)
            cb(true) if cb
          )
        else
          cb(false) if cb
      )

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
          that.selected = VCGlobal.findModule(m)
          if that.isSelection(m)
            Editor.editModule(m, (sm) ->
              that.selected = sm
              angular.element('#module-element_' + sm._id).scope().$apply()
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

])

.controller('EditorModuleCtrl', [
  '$scope'
  'Rest'
  'Editor'
  'EditorModule'
  '$timeout'

  ($scope, Rest, Editor, EditorModule, $timeout) ->

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

    require(['vc_global'], (VCGlobal) ->
      $scope.list = () ->
        list = []

        if VCGlobal.modules
          for m in VCGlobal.modules.rows
            list.push(m)

        return list.sort((a, b) ->
          ao = a.name
          bo = b.name
          if ao < bo
            return -1
          else if ao > bo
            return 1
          else
            return 0
        )
    )

    $scope.showpopup = (m) ->
      if $scope.popup
        $timeout.cancel($scope.popup)
      $scope.popup = $timeout(->
        $('#module-popover_' + m._id).popover('show')
      , 1500)

    $scope.hidepopup = (m) ->
      if $scope.popup
        $timeout.cancel($scope.popup)
      $timeout(->
        $('#module-popover_' + m._id).popover('hide')
      , 1)

    $scope.edit = (m) ->
      Editor
    $scope.new = (cb) ->

    $scope.save = (cb) ->
      if @selected
        EditorModule.save(@selected, cb)

    $scope.saveAll = (cb) ->
      EditorModule.saveAll(cb)

    $scope.share = (cb) ->
      if @selected
        EditorModule.share(@selected, cb)

    $scope.delete = (cb) ->

    $scope.refresh = (cb) ->
#      Node.refresh(cb)
])
