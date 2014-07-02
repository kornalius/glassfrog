angular.module('user.info', ['dynamicForm'])

.controller('UserInfoCtrl', [
  '$scope'
  '$rootScope'
  'dynForm'
  'Rest'

($scope, $rootScope, dynForm, Rest) ->

  $scope.usr = new Rest('user')

  $scope.usr.fetch($scope.user._id, ->
    userInfoForm =
      label: "User Information"
      name: "UserInfoForm"
      layout: {type:'display', style:'horizontal'}
      container: true

      fields: [
        fieldname: 'fullname'
        bold: true
        break: true
      ,
        fieldname: 'address'
        break: true
      ,
        fieldname: 'city'
      ,
        fieldname: 'state'
        prefix: ", "
      ,
        fieldname: 'zip'
        prefix: ", "
        break: true
      ,
        fieldname: 'country'
        break: true
      ,
        fieldname: 'tel'
        phone: true
        break: true
      ,
        hidden: 'true'
        fieldname: 'fax'
        phone: true
        break: true
      ,
        fieldname: 'url'
        url: true
        break: true
      ,
        fieldname: 'email'
        email: true
        break: true
      ]
    dynForm.build($scope, userInfoForm, $scope.usr, '#form')
  )

])
