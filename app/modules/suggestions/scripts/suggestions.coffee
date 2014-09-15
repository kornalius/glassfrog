angular.module('suggestions', ['app', 'dynamicForm'])

.controller('suggestionsCtrl', [
  '$scope'
  '$rootScope'
  '$injector'
  'Globals'
  'dynForm'
  'Rest'

($scope, $rootScope, $injector, globals, dynForm, Rest) ->
  $scope.suggestion = new Rest('suggestion')
  $scope.suggestion.createTemp({}, true, () ->
    form =
      label: "Suggestions"
      name: "suggestionsForm"
      layout: {type:'form', style:'horizontal'}
      container: true
      blank: true

      fields: [
        label: "Name"
        type: "input"
        description: "Enter your name"
        fieldname: 'name'
        required: true
      ,
        label: "Email"
        type: "input"
        description: "Enter your email so we can communicate with you"
        fieldname: 'email'
  #      email: true
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
        fieldname: 'kind'
        required: true
      ]

#      events:
#        save: (row) ->
#          $scope.suggestion.createTemp({}, true)
#
#        cancel: (row) ->
#          $scope.suggestion.createTemp({}, true)


    dynForm.build($scope, form, $scope.suggestion, '#form')
  )

])

.config([
  '$stateProvider'

  ($stateProvider) ->
    $stateProvider

    .state('suggestions',
      url:'/suggestions'
      templateUrl: '/partials/suggestions.html'
      sidebarHidden: true
      data:
        ncyBreadcrumbLabel: 'Suggestions'
#          ncyBreadcrumbSkip: true
    )
])
