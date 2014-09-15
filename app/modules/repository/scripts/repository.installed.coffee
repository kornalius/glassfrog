angular.module('repository.installed', ['dynamicForm'])

.controller('RepositoryInstalledCtrl', [
  '$scope'
  '$rootScope'
  '$injector'
  'dynForm'
  'Rest'
  '$window'

($scope, $rootScope, $injector, dynForm, Rest, $window) ->

  $scope.installed = new Rest('module')

  $scope.installed.fetch(->
    installedForm =
      label: "Installed modules"
      name: "installedForm"
      layout: {type:'table'}

      fields: [
      ]

    dynForm.build($scope, installedForm, $scope.installed, '#installed')
  )

])
