angular.module('sidebar', [])

.controller('SidebarCtrl', [
  '$scope'
  '$state'
  '$document'

  ($scope, $state, $document) ->

    $($document).ready(() ->
      $('[data-toggle=offcanvas]').click(() ->
        $(this).toggleClass('visible-xs text-center')
        $(this).find('span').toggleClass('cic-chevron-right2 cic-chevron-left2')
        $('.row-offcanvas').toggleClass('active')
        $('#lg-menu').toggleClass('hidden-xs').toggleClass('visible-xs')
        $('#xs-menu').toggleClass('visible-xs').toggleClass('hidden-xs')
        $('#btnShow').toggle()
      )
    )

    $scope.sidenavs = () ->
      navs = []
      if $state.$current
        cl = $state.$current.name.split('.')

      if cl.length >= 1
        cn = cl[0] + '.'
        for n in $state.get()
          if n.name and n.name.length and !n.abstract and (n.name == cl[0] or n.name.startsWith(cn))
            navs.push(n)
      else
        for n in $state.get()
          if n.name and n.name.length and !n.abstract and n.name.indexOf('.') == -1
            navs.push(n)
      return navs
])
