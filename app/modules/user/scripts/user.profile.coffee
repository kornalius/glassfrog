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
        fieldname: 'name.first'
        required: true
      ,
        label: "Last Name"
        type: "input"
        fieldname: 'name.last'
        required: true
      ,
        fieldname: 'name'
        fields: [
          label: "First Name"
          type: "input"
          fieldname: 'first'
          required: true
        ,
          label: "Last Name"
          type: "input"
          fieldname: 'last'
          required: true
        ]
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
      ,
        label: "State"
        type: "state"
        fieldname: 'state'
        state: true
      ,
        label: "Country"
        type: "country"
        fieldname: 'country'
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
      ,
        label: "Fax"
        type: "input"
        fieldname: 'fax'
        phone: true
      ,
        label: "Web Site"
        type: "input"
        fieldname: 'url'
        url: true
      ]
    dynForm.build($scope, userProfileForm, $scope.usr, '#form')
  )

])
