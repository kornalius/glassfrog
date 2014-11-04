'use strict'

angular.module('dashboard', ['app', 'dashboard.models', 'dashboard.lineChart', 'dashboard.barChart', 'dashboard.pieChart', 'dashboard.topNChart'])

.controller('DashboardCtrl', [
  '$scope'
  '$rootScope'
  'Globals'
  '$interval'
  '$window'
  'DashboardRestModel'

($scope, $rootScope, globals, $interval, $window, DashboardRestModel) ->

  $scope.dashboardOptions =
    widgetButtons: true

    widgetDefinitions: [

      name: 'Line'
      title: 'Line Chart'
      directive: 'dashboard-line-chart'
      dataModelType: DashboardRestModel
      dataAttrName: 'data'
      dataModelArgs:
        limit: 50
        interval: 5000
        valueField: '@total'
        type: 'count'
        model: 'test'
      storage: $window.localStorage
      storageId: 'rest-line-chart'
      style:
        width: '33%'
    ,

      name: 'Bar'
      title: 'Bar Chart'
      directive: 'dashboard-bar-chart'
      dataModelType: DashboardRestModel
      dataAttrName: 'data'
      dataModelArgs:
        limit: 50
        interval: 5000
        valueField: '@total'
        type: 'count'
        model: 'test'
      storage: $window.localStorage
      storageId: 'rest-bar-chart'
      style:
        width: '33%'
    ,

      name: 'Pie'
      title: 'Pie Chart'
      directive: 'dashboard-pie-chart'
      dataModelType: DashboardRestModel
      dataAttrName: 'data'
      dataModelArgs:
        limit: 50
        interval: 5000
        type: 'list'
        model: 'test'
      storage: $window.localStorage
      storageId: 'rest-pie-chart'
      style:
        width: '33%'
    ,

      name: 'TopN'
      title: 'TopN List'
      directive: 'dashboard-top-n-chart'
      dataModelType: DashboardRestModel
      dataAttrName: 'data'
      dataModelArgs:
        limit: 5
        interval: 5000
        type: 'top'
        model: 'test'
      storage: $window.localStorage
      storageId: 'rest-topN-chart'
      style:
        width: '33%'

    ]

    defaultWidgets: [
    ]

])

.config([
  '$stateProvider'

  ($stateProvider) ->

    $stateProvider
      .state('dashboard',
        abstract: true
        url:'/dashboard'
        templateUrl: '/partials/dashboard.html'
      )

      .state('dashboard.main',
        url:''
        icon: 'cic-dashboard2'
        data:
          ncyBreadcrumbLabel: 'Dashboard'
      )
])
