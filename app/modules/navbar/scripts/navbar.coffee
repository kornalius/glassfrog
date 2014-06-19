angular.module('navbar', [])

.controller('NavbarCtrl', [
  '$scope'
  '$state'

  ($scope, $state) ->
    $scope.navs = () ->
      navs = []
      for n in $state.get()
        if n.name and n.name.length and !n.abstract and n.name.indexOf('.') == -1
          navs.push(n)
#      console.log navs
      return navs
])
