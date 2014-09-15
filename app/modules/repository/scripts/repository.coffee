angular.module('repository', ['repository.available', 'repository.installed'])

.config([
  '$stateProvider'

  ($stateProvider) ->
    $stateProvider

    .state('repository_root',
      abstract: true
      url: '/repository'
      templateUrl: '/partials/repository.html'
      controller: ($scope) ->
      data:
        ncyBreadcrumbLabel: 'Repositories'
#          ncyBreadcrumbSkip: true
    )

    .state('repository',
      altname: 'repository.main'
      sidebarHidden: true
      url: '/'
      parent: 'repository_root'
      controller: ($scope) ->
      onEnter: ($state) ->
        $state.go("repository.available")
      data:
        ncyBreadcrumbLabel: 'Repositories'
#          ncyBreadcrumbSkip: true
      views: {}
    )

    .state('repository.available',
      url: '/available'
      parent: 'repository_root'
      data:
        root: 'repository'
        ncyBreadcrumbLabel: 'Available'
        ncyBreadcrumbParent: 'repository'
#          ncyBreadcrumbSkip: true
      views:
        available:
          templateUrl: '/partials/repository.available.html'
          controller: 'RepositoryAvailableCtrl'
    )

    .state('repository.installed',
      url: '/installed'
      parent: 'repository_root'
      data:
        root: 'repository'
        ncyBreadcrumbLabel: 'Installed'
        ncyBreadcrumbParent: 'repository'
#          ncyBreadcrumbSkip: true
      views:
        installed:
          templateUrl: '/partials/repository.installed.html'
          controller: 'RepositoryInstalledCtrl'
    )
])
