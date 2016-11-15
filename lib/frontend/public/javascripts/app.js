var flowqueuesApp;

flowqueuesApp = angular.module('flowqueuesApp', ['ngRoute', "flowqueuesControllers"]);

flowqueuesApp.config([
  '$routeProvider', function($routeProvider) {
    return $routeProvider.when('/jobs/:jobName', {
      templateUrl: 'partials/job-detail.html',
      controller: 'JobDetailCtrl'
    }).when('/', {
      templateUrl: 'partials/dashboard.html',
      controller: 'DashboardCtrl'
    }).otherwise({
      redirectTo: '/'
    });
  }
]);
