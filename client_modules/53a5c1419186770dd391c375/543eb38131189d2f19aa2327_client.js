/*3da31e9b9b3f9edf39de9993*/
'use strict';

(function() {
  angular.module('TravelReservation', ['app'])
    .controller('TravelReservationCtrl', ['$scope', 'Globals', 'Rest', 'dynForm', function($scope, globals, Rest, dynForm) {}])
    /*1351d040ada2f272ab9b4654*/
    .controller('TravelReservationPageCtrl', ['$scope', 'Globals', 'Rest', 'dynForm', function($scope, globals, Rest, dynForm) { /*21add129a8ecafbd30b61ff6*/ /*63cb25d43d270753dc800e8a*/ }])
    /*21add129a8ecafbd30b61ff6*/
    .controller('TravelReservationPageViewCtrl', ['$scope', 'Globals', 'Rest', 'dynForm', function($scope, globals, Rest, dynForm) {}])
    .config(['$stateProvider', function($stateProvider) {
      $stateProvider.state('travelreservation', {
          abstract: true,
          url: '/travelreservation',
          templateUrl: '/partials/travelreservation.html',
          controller: 'TravelReservationCtrl'
        })
        .state('travelreservation.page', {
          url: '',
          data: {
            root: 'travelreservation',
            ncyBreadcrumbLabel: 'Travelreservation'
          },
          views: {
            page_view: {
              templateUrl: 'travelreservation_page_view.html',
              controller: 'TravelReservationPageViewCtrl'
            }
          }
        });
    }]);
})();