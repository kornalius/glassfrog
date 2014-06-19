angular.module('user.shares', ['dynamicForm'])

.controller('UserSharesCtrl', [
  '$scope'
  '$rootScope'
  '$injector'
  'dynForm'
  'Rest'

($scope, $rootScope, $injector, dynForm, Rest) ->

  $scope.share = new Rest('share', 1)

  $scope.share.fetch(1, ->
    sharesTable =
      label: 'Shares'
      name: "sharesTable"
      editMode: 'none'
      canMove: false
      layout: {type:'table'}

      fields: [
        label: "Module"
        description: "Module name"
        fieldname: 'node.name'
      ,
        label: "Host"
        type: 'check'
        description: "Data are hosted on your plan"
        fieldname: 'hostData'
      ]

    dynForm.build($scope, sharesTable, $scope.share, '#shares')
  )

])
