'use strict'

angular.module('home', ['app'])

.controller('HomeCtrl', [
  '$scope'
  '$rootScope'
  'Globals'

($scope, $rootScope, globals) ->
])

.config([
  '$stateProvider'

  ($stateProvider) ->

    $stateProvider
      .state('home',
        url:'/home'
        templateUrl: '/partials/home.html'
        sidebarHidden: true
        data:
          ncyBreadcrumbLabel: '<i class="cic cic-home3"/>'
#          ncyBreadcrumbParent: 'user'
#          ncyBreadcrumbSkip: true
      )
])
