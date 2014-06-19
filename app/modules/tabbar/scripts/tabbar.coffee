angular.module('tabbar', ['app'])

.controller('TabbarCtrl', [
  '$scope'
  '$state'
  'Globals'

  ($scope, $state, globals) ->

    $scope.tabs = () ->
      if $state.current and $state.current.name
        tabs=[]
        p = $state.current.name.split('.')
        if p and p.length
          if $state.current.data and $state.current.data.root
            tabs.push($state.get($state.current.data.root))
          for t in $state.get()
            if t.parent and t.name.startsWith(p[0] + '.')
              tabs.push(t)
#        console.log tabs
        globals.tabsCount = tabs.length
        return tabs
])
