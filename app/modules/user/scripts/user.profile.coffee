angular.module('user.profile', ['dynamicForm'])

.controller('UserProfileCtrl', [
  '$scope'
  '$rootScope'
  'dynForm'
  'Rest'

($scope, $rootScope, dynForm, Rest) ->

  $scope.usr = new Rest('user')

  $scope.usr.fetch($scope.user._id, ->
    userProfileForm =
      label: "User Profile"
      name: "UserProfileForm"
      layout: {type:'form', style:'horizontal'}
      container: true
      buttons: []

      fields: [
        label: "Login Information"
        type: "group"
        column: 6
      ,
        label: "Username"
        type: "input"
        fieldname: 'username'
        required: true
        username: true
      ,
        label: "Email"
        type: "input"
        email: true
        fieldname: 'email'
        required: true
      ,
        label: "Current Password"
        type: "input"
        password: true
        fieldname: 'current_password'
      ,
        label: "New Password"
        type: "input"
        password: true
        fieldname: 'new_password'
      ,
        label: "Confirm Password"
        type: "input"
        password: true
        fieldname: 'confirm_password'
      ,
        label: "Personal Information"
        type: "group"
        column: 6
      ,
        label: "First Name"
        type: "input"
        fieldname: 'firstname'
        required: true
      ,
        label: "Last Name"
        type: "input"
        fieldname: 'lastname'
        required: true
      ,
        label: "Address"
        type: "input"
        fieldname: 'address'
        required: true
      ,
        label: "City"
        type: "input"
        fieldname: 'city'
        city: true
        required: true
      ,
        label: "State"
        type: "select"
        fieldname: 'state'
        options: []
        config:
          url: '/api/state?where="country" = \'{0}\'&limit=100'.format("CA")
          field: 'name'
        state: true
        required: true
      ,
        label: "Country"
        type: "select"
        fieldname: 'country'
        options: []
        config:
          url: '/api/country?limit=100'
          field: 'name'
        country: true
        required: true
      ,
        label: "Postal Code"
        type: "input"
        fieldname: 'zip'
        zipcode: true
        required: true
      ,
        label: "Phone"
        type: "input"
        fieldname: 'tel'
        phone: true
        required: true
      ,
        label: "Fax"
        type: "input"
        fieldname: 'fax'
        phone: true
        required: true
      ,
        label: "Web Site"
        type: "input"
        fieldname: 'url'
        url: true
        required: true
      ]
    dynForm.build($scope, userProfileForm, $scope.usr, '#form')
  )

])
