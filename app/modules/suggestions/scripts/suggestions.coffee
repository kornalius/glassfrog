angular.module('suggestions', ['app', 'dynamicForm'])

.controller('suggestionsCtrl', [
  '$scope'
  '$rootScope'
  '$injector'
  'Globals'
  'dynForm'
  'Rest'

($scope, $rootScope, $injector, globals, dynForm, Rest) ->
  $scope.test = new Rest('suggestions')
  $scope.test.rows.push(
    name: ''
    message: ''
    type: '1'
  )

  form =
    label: "Suggestions"
    name: "suggestionsForm"
    layout: {type:'form', style:'horizontal'}
    container: true

    fields: [
      label: "Name"
      type: "input"
      description: "Enter your name"
      fieldname: 'name'
      required: true
    ,
      label: "Message"
      type: "textarea"
      description: "Enter a message"
      fieldname: 'message'
      required: true
    ,
      label: "Type"
      type: "select"
      description: "Select the type of suggestion"
      options: [
        "General Question"
        "Server Issues"
        "Billing Question"
      ].sort()
      fieldname: 'type'
      required: true
    ]

  dynForm.build($scope, form, $scope.test, '#form')

])

.config([
  '$stateProvider'

  ($stateProvider) ->
    $stateProvider

    .state('suggestions',
      url:'/suggestions'
      templateUrl: '/partials/suggestions.html'
    )
])
