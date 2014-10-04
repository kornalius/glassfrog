angular.module('user', ['user.profile', 'user.invoices', 'user.info'])

.config([
  '$stateProvider'

  ($stateProvider) ->
    $stateProvider

    .state('user',
      abstract: true
      url: '/user'
      templateUrl: '/partials/user.html'
    )

    .state('user.info',
      url: ''
      navbarHidden: true
      sidebarHidden: true
      data:
        root: 'user'
        ncyBreadcrumbLabel: 'User'
#          ncyBreadcrumbSkip: true
      views:
        info:
          templateUrl: '/partials/user.info.html'
          controller: 'UserInfoCtrl'
    )

    .state('user.profile',
      url: '/profile'
      icon: 'cic-user32'
      data:
        root: 'user'
        ncyBreadcrumbLabel: 'Profile'
        ncyBreadcrumbParent: 'user'
#          ncyBreadcrumbSkip: true
      views:
        profile:
          templateUrl: '/partials/user.profile.html'
          controller: 'UserProfileCtrl'
    )

    .state('user.invoices',
      url: '/invoices'
      icon: 'cic-cash'
      data:
        root: 'user'
        ncyBreadcrumbLabel: 'Invoices'
        ncyBreadcrumbParent: 'user'
#          ncyBreadcrumbSkip: true
      views:
        profile:
          templateUrl: '/partials/user.invoices.html'
          controller: 'UserInvoicesCtrl'
    )

    .state('user.shares',
      url: '/shares'
      icon: 'cic-share52'
      data:
        root: 'user'
        ncyBreadcrumbLabel: 'Shares'
        ncyBreadcrumbParent: 'user'
#          ncyBreadcrumbSkip: true
      views:
        profile:
          templateUrl: '/partials/user.shares.html'
          controller: 'UserSharesCtrl'
    )
])
