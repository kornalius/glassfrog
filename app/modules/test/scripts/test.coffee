angular.module('test', ['test.form', 'test.table', 'test.details', 'test.po', 'test.info'])

.config([
  '$stateProvider'

  ($stateProvider) ->

    $stateProvider

    .state('test',
      abstract: true
      url: '/test'
      templateUrl: '/partials/test.html'
    )

    .state('test.main',
      altname: 'test'
      url: ''
      data:
        root: 'test'
        ncyBreadcrumbLabel: 'Test'
#        ncyBreadcrumbParent: 'Test'
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
      data:
        root: 'test'
        ncyBreadcrumbLabel: 'PO'
        ncyBreadcrumbParent: 'test.main'
#          ncyBreadcrumbSkip: true
      views:
        po:
          templateUrl: '/partials/test.po.html'
          controller: 'TestPOCtrl'
    )

    .state('test.details',
      url: '/details'
      data:
        root: 'test'
        ncyBreadcrumbLabel: 'Details'
        ncyBreadcrumbParent: 'test.main'
#          ncyBreadcrumbSkip: true
      views:
        details:
          templateUrl: '/partials/test.details.html'
          controller: 'TestDetailsCtrl'
    )

    .state('test.info',
      url: '/info'
      data:
        root: 'test'
        ncyBreadcrumbLabel: 'Info'
        ncyBreadcrumbParent: 'test.main'
#          ncyBreadcrumbSkip: true
      views:
        info:
          templateUrl: '/partials/test.info.html'
          controller: 'TestInfoCtrl'
    )
])
