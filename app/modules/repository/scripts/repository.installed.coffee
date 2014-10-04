angular.module('repository.installed', ['dynamicForm', 'editor'])

.controller('RepositoryInstalledCtrl', [
  '$scope'
  '$rootScope'
  '$injector'
  'dynForm'
  'Rest'
  '$window'
  '$http'
  'Globals'
  'dynModal'
  'Editor'

  ($scope, $rootScope, $injector, dynForm, Rest, $window, $http, globals, dynModal, Editor) ->

    $scope.installed = new Rest('module')

    $scope.installed.find({l: 10, sort: '-updated_at'}, ->
      installedForm =
        label: "Installed modules"
        name: "installedForm"
        gridpart_lg: 4
        gridpart_md: 3
        gridpart_sm: 2
        gridpart_xs: 1
        layout: {type: 'grid', style: 'form-inline', include: 'repository-card-template'}

        fields: [
          fieldname: 'name'
          label: 'Module'
          type: 'include'
          template: '/partials/repository-card-template.html'
        ]

      dynForm.build($scope, installedForm, $scope.installed, '#installed')
    )

    $scope.uninstall = (_id, cb) ->
      a = $scope.installed.findRowById(_id)
      if a
        console.log "uninstall()", _id
        dynModal.yesNoModal({title:'Uninstall...', caption:'Are you sure you want to uninstall the module \'' + a.name + '\'?'}, (ok) ->
          if ok
            $http.get("/api/module/call/uninstall/" + _id)
            .success((ok) ->
              if ok
                a.canInstall = true
                a.canUninstall = false
                a.installed = false
                a.needsUpdate = false
                a.installations--
                idx = $scope.installed.findRowIndexById(_id)
                if idx != -1
                  $scope.installed.rows.splice(idx, 1)
                globals.showMessage("Module '" + a.name + "' was uninstalled successfully", 'success')
                Editor.refreshNeeded = true
                cb(true) if cb
              else
                globals.showMessage("Could not uninstall module", 'danger')
                cb(false) if cb
            )
            .error((data, status) ->
              console.log data, status
              globals.showMessage(data, 'danger')
              cb(false) if cb
            )
        )

    $scope.update = (_id, cb) ->
      a = $scope.installed.findRowById(_id)
      if a
        console.log "update()", _id
        $http.get("/api/module/call/update/" + _id)
        .success((module) ->
          if module?
            a.name = module.name
            a.desc = module.desc
            a.readme = module.readme
            a.icon = module.icon
            a.color = module.color
            a.version = new VersionClass(module.version).versionString()
            a.extra = _.cloneDeep(module.extra)
            a.needsUpdate = false
            globals.showMessage("Module '" + a.name + "' was updated successfully", 'success')
            Editor.refreshNeeded = true
            cb(true) if cb
        )
        .error((data, status) ->
          globals.showMessage(data, 'danger')
          cb(false) if cb
        )

    $scope.publish = (_id, cb) ->
      a = $scope.installed.findRowById(_id)
      if a
        console.log "publish()", _id
        dynModal.yesNoModal({title:'Publish...', caption:'Are you sure you want to publish the module \'' + a.name + '\'?'}, (ok) ->
          if ok
            $http.get("/api/module/call/publish/" + _id)
            .success((ok) ->
              if ok
                a.published = true
                a.canPublish = false
                a.canUnpublish = true
                globals.showMessage("Module '" + a.name + "' was published successfully", 'success')
                cb(true) if cb
            )
            .error((data, status) ->
              globals.showMessage(data, 'danger')
              cb(false) if cb
            )
        )

    $scope.unpublish = (_id, cb) ->
      a = $scope.installed.findRowById(_id)
      if a
        console.log "unpublish()", _id
        dynModal.yesNoModal({title:'Unpublish...', caption:'Are you sure you want to unpublish the module \'' + a.name + '\'?'}, (ok) ->
          if ok
            $http.get("/api/module/call/unpublish/" + _id)
            .success((ok) ->
              if ok
                a.published = false
                a.canPublish = true
                a.canUnpublish = false
                a.canDelete = a.isOwned
                globals.showMessage("Module '" + a.name + "' was unpublished successfully", 'success')
                cb(true) if cb
            )
            .error((data, status) ->
              globals.showMessage(data, 'danger')
              cb(false) if cb
            )
        )

    $scope.delete = (_id, cb) ->
      that = @
      a = $scope.installed.findRowById(_id)
      if a
        name = @name
        console.log "remove()", _id
        dynModal.yesNoModal({title:'Delete...', caption:'Are you sure you want to delete the module \'' + a.name + '\'?'}, (ok) ->
          if ok

            $http.get("/api/module/call/delete/" + _id)
            .success((ok) ->
              if ok?
                idx = $scope.installed.findRowIndexById(_id)
                if idx != -1
                  $scope.installed.rows.splice(idx, 1)
                globals.showMessage("Module '" + name + "' was deleted successfully", 'success')
                Editor.refreshNeeded = true
                cb(true) if cb
              else
                globals.showMessage("Could not delete module '" + name + "'", 'danger')
                cb(false) if cb
            )
            .error((data, status) ->
              globals.showMessage(data, 'danger')
              cb(false) if cb
            )

        )

    $scope.more = (_id) ->
      a = $scope.installed.findRowById(_id)
      if a
        console.log "more()", _id
        dynModal.showModal({title:a.name, scope:$scope, template:'<marked>' + a.readme + '</marked>'}, ->
        )

    $scope.like = (_id, cb) ->
      console.log "like()", _id
      $http.get("/api/module/call/like/" + _id)
      .success((ok) ->
        if ok?
          a = $scope.installed.findRowById(_id)
          if a
            a.liked = true
            a.totalLikes++
            cb(true) if cb
          else
            cb(false) if cb
      )
      .error((data, status) ->
        globals.showMessage(data, 'danger')
        cb(false) if cb
      )

    $scope.dislike = (_id, cb) ->
      console.log "dislike()", _id
      $http.get("/api/module/call/dislike/" + _id)
      .success((ok) ->
        if ok?
          a = $scope.installed.findRowById(_id)
          if a
            a.liked = false
            a.totalLikes--
            cb(true) if cb
          else
            cb(false) if cb
      )
      .error((data, status) ->
        globals.showMessage(data, 'danger')
        cb(false) if cb
      )

])
