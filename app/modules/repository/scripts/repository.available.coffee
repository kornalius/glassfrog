angular.module('repository.available', ['dynamicForm'])

.controller('RepositoryAvailableCtrl', [
  '$scope'
  '$rootScope'
  '$injector'
  'dynForm'
  'Rest'
  '$window'

($scope, $rootScope, $injector, dynForm, Rest, $window) ->

  $scope.available = new Rest('repository')

  $scope.available.fetch(->
    availableForm =
      label: "Available modules"
      name: "availableForm"
      layout: {type:'table', style:'form', include:'repository-card-template'}

      fields: [
        fieldname: 'name'
        label: 'Module'
        type: 'include'
        template: '/partials/repository-card-template.html'
      ,
        fieldname: 'version.version'
        label: 'Version'
#        inputHidden: true
      ,
        fieldname: 'version'
        label: 'Date'
#        inputHidden: true
      ,
        fieldname: 'author'
        label: 'Author'
        inputHidden: true
      ]

    dynForm.build($scope, availableForm, $scope.available, '#available')
  )

])
