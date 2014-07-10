angular.module('user', ['user.profile', 'user.info'])

.config([
  '$stateProvider'

  ($stateProvider) ->
    $stateProvider

    .state('user_root',
      abstract: true
      templateUrl: '/partials/user.html'
      controller: ($scope) ->
    )

    .state('user',
      url: '/user'
      parent: 'user_root'
      hidden: true
      data:
        root: 'user'
      views:
        info:
          templateUrl: '/partials/user.info.html'
          controller: 'UserInfoCtrl'
    )

    .state('user.profile',
      url: '/profile'
      parent: 'user_root'
      icon: 'user32'
      data:
        root: 'user'
      views:
        profile:
          templateUrl: '/partials/user.profile.html'
          controller: 'UserProfileCtrl'
    )

    .state('user.invoices',
      url: '/invoices'
      parent: 'user_root'
      icon: 'cash'
      data:
        root: 'user'
      views:
        profile:
          templateUrl: '/partials/user.invoices.html'
          controller: 'UserInvoicesCtrl'
    )

    .state('user.shares',
      url: '/shares'
      parent: 'user_root'
      icon: 'share52'
      data:
        root: 'user'
      views:
        profile:
          templateUrl: '/partials/user.shares.html'
          controller: 'UserSharesCtrl'
    )
])
