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
      autolabel: false

      fields: [
        fieldname: 'name.full'
        username: true
        break: true
      ,
        fieldname: 'address'
        address: true
        break: true
      ,
        fieldname: 'city'
        city: true
      ,
        fieldname: 'state'
        state: true
      ,
        fieldname: 'zip'
        zipcode: true
        break: true
      ,
        fieldname: 'country'
        country: true
        break: true
      ,
        fieldname: 'tel'
        phone: true
        break: true
      ,
        hidden: 'true'
        fieldname: 'fax'
        fax: true
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
