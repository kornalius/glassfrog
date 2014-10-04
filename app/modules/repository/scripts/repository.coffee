angular.module('repository', ['repository.available', 'repository.installed'])

.config([
  '$stateProvider'

  ($stateProvider) ->
    $stateProvider

    .state('repository',
      abstract: true
      url: '/repository'
      templateUrl: '/partials/repository.html'
    )

    .state('repository.main',
      url: ''
      icon: 'cic-cord'
      data:
        root: 'repository'
        ncyBreadcrumbLabel: 'Repository'
      onEnter: ['$state', ($state) ->
        window.setTimeout(->
          $state.go('repository.available')
        )
      ]
    )

    .state('repository.available',
      url: '/available'
      icon: 'cic-basket'
      data:
        root: 'repository'
        ncyBreadcrumbLabel: 'Available'
        ncyBreadcrumbParent: 'repository.main'
      views:
        available:
          templateUrl: '/partials/repository.available.html'
          controller: 'RepositoryAvailableCtrl'
    )

    .state('repository.installed',
      url: '/installed'
      icon: 'cic-cord'
      data:
        root: 'repository'
        ncyBreadcrumbLabel: 'Installed'
        ncyBreadcrumbParent: 'repository.main'
#          ncyBreadcrumbSkip: true
      views:
        installed:
          templateUrl: '/partials/repository.installed.html'
          controller: 'RepositoryInstalledCtrl'
    )
])
