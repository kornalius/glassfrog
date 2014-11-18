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
  'jm.i18next'
  'app.globals'
  'ui.router.state'
  'ngCookies'
  'ngResource'
  'ngScope'
  'angular-loading-bar'
  'ngAnimate'
  'ngSanitize'
  'angularMoment'
  'webStorageModule'
  'ui.config'
  'ui.directives'
  'ui.filters'
  'rest.services'
  'frapontillo.ex.filters'
  'angular-lodash'
  'underscore.string'
  'perfect_scrollbar'
  'ngClickSelect'
  'dynform.services'
  'schemaForm'
  'schemaFormCustomDecorators'
  'angular-centered'
  'ui.bootstrap'
  'ui.bootstrap.rating.controller'
  'angular-blocks'

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
  'countrystate.services'

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
  'schemaFormProvider'
  'schemaFormDecoratorsProvider'
  'sfPathProvider'

  ($stateProvider, $urlRouterProvider, $i18nextProvider, $breadcrumbProvider, markedProvider, cfpLoadingBarProvider, schemaFormProvider, schemaFormDecoratorsProvider, sfPathProvider) ->

#    _.mixin(_.string.exports())

    $i18nextProvider.options =
#      preload: ['en', 'fr']
      useCookie: true
      cookieName: 'lang'
      useLocalStorage: false
      ignoreRoutes: ['images/', 'public/', 'css/', 'js/']
      supportedLngs: ['en', 'fr']
      lng: 'en'
      fallbackLng: 'en'
      load: 'unspecific'
      detectLngQS: 'lang'
      resGetPath: '/locales/__ns__-__lng__.json'
      lowerCaseLng: true
#      sendMissing: true
#      resPostPath: '/locales/add/__ns__-__lng__.json'
#      sendMissingTo: 'all'
      debug: true

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


    # Importing angular-schema-form custom decorators

#    schemaFormProvider.defaults.date = []

    base = '/partials/decorators/'

    schemaFormDecoratorsProvider.createDecorator('customDecorator',
      'default': base + 'default.html'
      textarea: base + 'textarea.html'
      fieldset: base + 'fieldset.html'
      array: base + 'array.html'
      tabarray: base + 'tabarray.html'
      tabs: base + 'tabs.html'
      section: base + 'section.html'
      conditional: base + 'section.html'
      actions: base + 'actions.html'
      select: base + 'select.html'
      checkbox: base + 'checkbox.html'
      checkboxes: base + 'checkboxes.html'
      number: base + 'default.html'
      password: base + 'default.html'
      submit: base + 'submit.html'
      button: base + 'submit.html'
      radios: base + 'radios.html'
      'radios-inline': base + 'radios-inline.html'
      radiobuttons: base + 'radio-buttons.html'
      help: base + 'help.html'
      multi: base + 'select-multi.html'
      tags: base + 'select-tags.html'
      checklist: base + 'checklist.html'
      countries: base + 'countries.html'
      states: base + 'states.html'
      date: base + 'date.html'
      time: base + 'time.html'
      datetime: base + 'datetime.html'
      icon: base + 'icon.html'
      image: base + 'image.html'
      twolist: base + 'twolist.html'
      url: base + 'url.html'
      email: base + 'email.html'
      phone: base + 'phone.html'
      rating: base + 'rating.html'
      callout: base + 'callout.html'
      template: base + 'template.html'
      'form-vertical': base + 'form-vertical.html'
      'form-table': base + 'form-table.html'
      'form-grid': base + 'form-grid.html'
    , [
#       function(form) {
#         if (form.readonly && form.key && form.type !== 'fieldset') {
#           return base + 'readonly.html';
#         }
#       }
    ])

    schemaFormDecoratorsProvider.createDirectives(
      textarea: base + 'textarea.html'
      select: base + 'select.html'
      checkbox: base + 'checkbox.html'
      checkboxes: base + 'checkboxes.html'
      number: base + 'default.html'
      submit: base + 'submit.html'
      button: base + 'submit.html'
      text: base + 'default.html'
      password: base + 'default.html'
      input: base + 'default.html'
      radios: base + 'radios.html'
      'radios-inline': base + 'radios-inline.html'
      radiobuttons: base + 'radio-buttons.html'
      multi: base + 'select-multi.html'
      tags: base + 'select-tags.html'
      checklist: base + 'checklist.html'
      countries: base + 'countries.html'
      states: base + 'states.html'
      date: base + 'date.html'
      time: base + 'time.html'
      datetime: base + 'datetime.html'
      icon: base + 'icon.html'
      image: base + 'image.html'
      twolist: base + 'twolist.html'
      url: base + 'url.html'
      email: base + 'email.html'
      phone: base + 'phone.html'
      rating: base + 'rating.html'
      callout: base + 'callout.html'
      template: base + 'template.html'
      'form-vertical': base + 'form-vertical.html'
      'form-table': base + 'form-table.html'
      'form-grid': base + 'form-grid.html'
    )

    schemaFormProvider.defaults.string.unshift((name, schema, options) ->
      if schema.type == 'string' and schema.enum? and type(schema.enum) is 'array'
        f = schemaFormProvider.stdFormObj(name, schema, options)
        f.key = options.path
        f.type = 'select'
        f.titleMap = []
        for e in schema.enum
          f.titleMap.push({name: e, value: e})
        options.lookup[sfPathProvider.stringify(options.path)] = f
        return f
    )

    schemaFormProvider.postProcess((form) ->
#      form.supressPropertyTitles = true

      for f in form
#        f.onChange = "updated(modelValue, form)"

        if !f.notitle and !f.title? and f.key?
          if type(f.key) is 'array'
            s = _.last(f.key)
          else
            s = f.key
          f.title = _.str.humanize(s)

        if !f.ngModelOptions
          f.ngModelOptions = {}

        if f.titleMap
          for i in [0..f.titleMap.length - 1]
            v = f.titleMap[i]
            if type(v) != 'object'
              f.titleMap[i] = {name: v, value: v}

      #      l = _.last(form)
#      if l.type == 'defaults'
#        form.pop()
#        form.push(
#          type: 'actions'
#          items: [
#            type: "submit"
#            title: "Save"
#            style: 'btn-success'
#          ,
#            type: "button"
#            title: "Cancel"
#            style: 'btn-danger'
#            onClick: "cancel()"
#          ]
#        )
      return form
    )

])
