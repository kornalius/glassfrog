angular.module('repository.available', ['dynamicForm', 'editor'])

.controller('RepositoryAvailableCtrl', [
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

    $scope.available = new Rest('repository')

    $scope.available.find({l: 10, sort: '-updated_at'}, ->
      availableForm =
        label: "Available modules"
        name: "availableForm"
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

      dynForm.build($scope, availableForm, $scope.available, '#available')
    )

    $scope.install = (_id, cb) ->
      console.log "install()", _id
      $http.get("/api/repository/call/install/" + _id)
      .success((module) ->
        if module?
          a = $scope.available.findRowById(_id)
          if a
            a.canInstall = false
            a.canUninstall = true
            a.needsUpdate = false
            a.installed = true
            a.installations++
            globals.showMessage("Module '" + a.name + "' was installed successfully", 'success')
            Editor.refreshNeeded = true
            cb(true) if cb
          else
            globals.showMessage("Could not install module", 'danger')
            cb(false) if cb
      )
      .error((data, status) ->
        globals.showMessage(data, 'danger')
        cb(false) if cb
      )

    $scope.uninstall = (_id, cb) ->
      a = $scope.available.findRowById(_id)
      if a
        console.log "uninstall()", _id
        dynModal.yesNoModal({title:'Uninstall...', caption:'Are you sure you want to uninstall the module \'' + a.name + '\'?'}, (ok) ->
          if ok
            $http.get("/api/repository/call/uninstall/" + _id)
            .success((ok) ->
              if ok
                a = $scope.available.findRowById(_id)
                if a
                  a.canInstall = true
                  a.canUninstall = false
                  a.needsUpdate = false
                  a.installed = false
                  a.installations--
                  globals.showMessage("Module '" + a.name + "' was uninstalled successfully", 'success')
                  Editor.refreshNeeded = true
                  cb(true) if cb
                else
                  globals.showMessage("Could not uninstall module", 'danger')
                  cb(false) if cb
              else
                globals.showMessage("Could not uninstall module", 'danger')
                cb(false) if cb
            )
            .error((data, status) ->
              globals.showMessage(data, 'danger')
              cb(false) if cb
            )
        )

    $scope.update = (_id, cb) ->
      console.log "update()", _id
      $http.get("/api/repository/call/update/" + _id)
      .success((module) ->
        if module?
          a = $scope.available.findRowById(_id)
          if a
            a.needsUpdate = false
            globals.showMessage("Module '" + a.name + "' was updated successfully", 'success')
            Editor.refreshNeeded = true
            cb(true) if cb
          else
            globals.showMessage("Could not update module", 'danger')
            cb(false) if cb
      )
      .error((data, status) ->
        globals.showMessage(data, 'danger')
        cb(false) if cb
      )

    $scope.more = (_id) ->
      r = $scope.available.findRowById(_id)
      console.log "more()", _id
      dynModal.showModal({title:r.name, scope:$scope, template:'<marked>' + r.readme + '</marked>'}, ->
      )

    $scope.like = (_id, cb) ->
      console.log "like()", _id
      $http.get("/api/repository/call/like/" + _id)
      .success((ok) ->
        if ok?
          a = $scope.available.findRowById(_id)
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
      $http.get("/api/repository/call/dislike/" + _id)
      .success((ok) ->
        if ok?
          a = $scope.available.findRowById(_id)
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
