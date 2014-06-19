angular.module('test', ['test.form', 'test.table', 'test.details', 'test.po', 'test.info'])

.config([
  '$stateProvider'

  ($stateProvider) ->
    $stateProvider

    .state('test_root',
      abstract: true
      templateUrl: '/partials/test.html'
      controller: ($scope) ->
        $scope.localVariable = "HELLO WORLD!"
#      onEnter: () ->
#        console.log "enter test"
    )

    .state('test',
      url: '/test'
      parent: 'test_root'
      data:
        root: 'test'
      views:
        form:
          templateUrl: '/partials/test.form.html'
          controller: 'TestFormCtrl'
        table:
          templateUrl: '/partials/test.table.html'
          controller: 'TestTableCtrl'
    )

    .state('test.po',
      url: '/po'
      parent: 'test_root'
      data:
        root: 'test'
      views:
        po:
          templateUrl: '/partials/test.po.html'
          controller: 'TestPOCtrl'
    )

    .state('test.details',
      url: '/details'
      parent: 'test_root'
      data:
        root: 'test'
      views:
        details:
          templateUrl: '/partials/test.details.html'
          controller: 'TestDetailsCtrl'
    )

    .state('test.info',
      url: '/info'
      parent: 'test_root'
      data:
        root: 'test'
      views:
        info:
          templateUrl: '/partials/test.info.html'
          controller: 'TestInfoCtrl'
    )
])
