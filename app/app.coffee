'use strict'

require.config(
  baseUrl: "/js",
#  paths:
#    "validator": "validator"
#    "assurance": "assurance"
)

moduleNames = [
  'home'
  'blog'
  'todo'
  'view1'
  'view2'
  'test'
  'suggestions'
  'user'
  'editor'
#  'dashboard'
  'repository'
]

modules = []
for m in moduleNames
  sf = m.replace('.', '_')
  modules.push(
    name: m
    expandedName: m
    href: '#/' + m
    url: '/' + m
    templateUrl: '/partials/' + m + '.html'
    label: 'nav.' + sf
  )

# Declare app level module which depends on filters, and services
app = angular.module('app', [
  'app.globals'

  #used for angular-ui-router
  'ui.router.state'
  'ngCookies'
  'ngResource'
  'angular-loading-bar'
  'ngAnimate'
  'ngSanitize'
  'angularMoment'
  'webStorageModule'
  'ui.config'
  'ui.directives'
  'ui.filters'
  'rest.services'
  'jm.i18next'
  'frapontillo.ex.filters'
  'angular-lodash'
  'underscore.string'
  'perfect_scrollbar'

#  'ngDatatables'
#  'ngBaseDataTables'

#  'dynamicForm'
#  'builder'
#  'builder.components'
#  'validator.rules'

  'app.controllers'
  'app.directives'
  'app.filters'
  'app.services'

  'autosize.services'
  'switch.services'
  'twolist.services'
  'checklistbox.services'
  'iconpicker.services'
  'pageslide-directive'
  'Datetimepicker'
  'angularSpectrumColorpicker'
  'ui.tree'
  'ui.selectize'
  'nvd3ChartDirectives'
  'ui.dashboard'
  'pagination.services'
  'querybuilder.services'
  'ncy-angular-breadcrumb'
  'hc.marked'

  'sidebar'
  'navbar'
  'tabbar'

].concat(modules.map( (m) ->
    m.expandedName
  )
))

.constant('_', window._)

#.factory('_', [
#  '$window',
#
#  ($window) ->
#    $window._
#])

#.factory('_', [
#  '$window',
#
#  ($window) ->
#    $window._
#])

.run([
  '$rootScope'
  'Globals'

  ($rootScope, globals) ->
    globals.modules = modules
    $rootScope.globals = globals

#    $rootScope.$on('$locationChangeSuccess', () ->
#      console.log "$locationChangeSuccess"
#    )

  #  some init code here
])

.config([
  '$stateProvider'
  '$urlRouterProvider'
  '$i18nextProvider'
  '$breadcrumbProvider'
  'markedProvider'
  'cfpLoadingBarProvider'

  ($stateProvider, $urlRouterProvider, $i18nextProvider, $breadcrumbProvider, markedProvider, cfpLoadingBarProvider) ->

#    _.mixin(_.string.exports())

    $i18nextProvider.options = {
      useCookie: true
      ignoreRoutes: ['images/', 'public/', 'css/', 'js/']
      supportedLngs: ['en', 'fr']
      lng: 'en'
      fallbackLng: 'en'
      load: 'unspecific'
 #    detectLngQS: 'lng'
      resGetPath: '/locales/__ns__-__lng__.json'
#      sendMissing: true
#      resPostPath: '/locales/add/__ns__-__lng__.json'
#      sendMissingTo: 'all'
      debug: true
    };

    # default to the home page
    $urlRouterProvider.otherwise("/home")

#    for m in modules
#      $stateProvider.state(m.name,
#        url: m.url
#        views:
#          "main-content":
#            templateUrl: m.templateUrl
#      )

    $breadcrumbProvider.setOptions(
      prefixStateName: 'home'
#      template: 'bootstrap3'
      templateUrl: 'partials/breadcrumb.html'
    )

    markedProvider.setOptions(
      gfm: true
      tables: true
      breaks: true
      sanitize: true
      smartLists: true
      smartypants: true
    )

    cfpLoadingBarProvider.includeSpinner = false
    cfpLoadingBarProvider.latencyThreshold = 50
])
