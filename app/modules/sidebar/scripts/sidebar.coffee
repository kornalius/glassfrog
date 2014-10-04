angular.module('sidebar', [])

.controller('SidebarCtrl', [
  '$scope'
  '$state'
  '$document'

  ($scope, $state, $document) ->

    $($document).ready(() ->
      $('[data-toggle=offcanvas]').click(() ->
        $(this).toggleClass('visible-xs')
        $(this).find('i').toggleClass('cic-chevron-right2 cic-chevron-left2')
        $('.row-offcanvas').toggleClass('active')
        $('#lg-menu').toggleClass('hidden-xs').toggleClass('visible-xs')
        $('#xs-menu').toggleClass('visible-xs').toggleClass('hidden-xs')
        $('#btnShow').toggle()
      )
    )

    $scope.sidenavs = () ->
      navs = []
      p = $state.current.name.split('.')[0]
      pl = p.length + 1
      for n in $state.get()
        if n.name and n.name.length and !n.abstract and n.url != ''
          if n.name.substr(0, pl) == p + '.'
            navs.push(n)
      return navs
])
