'use strict'

require.config(
  baseUrl: "/js",
#  paths:
#    "validator": "validator"
#    "assurance": "assurance"
)

moduleNames = [
  'home'
  'todo'
  'view1'
  'view2'
  'test'
  'suggestions'
  'user'
  'editor'
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
  'ngAnimate'

  'webStorageModule'

  'ui.config'
  'ui.directives'
  'ui.filters'

  'pagination.services'

  'rest.services'

  'jm.i18next'
  'ajoslin.promise-tracker'
  'frapontillo.ex.filters'
  'angular-lodash'
  'underscore.string'

  'Datetimepicker'

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

  'select.services'
  'switch.services'
  'twolist.services'

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

  ($stateProvider, $urlRouterProvider, $i18nextProvider) ->

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

])
