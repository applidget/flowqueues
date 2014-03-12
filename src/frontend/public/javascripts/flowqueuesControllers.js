angular.module("flowqueuesControllers", [])
.controller("DashboardCtrl",function($scope, $http) {
  request = $http.get('./api/jobs');
  request.success(function(data) {
    $scope.jobs = data;

  });
  request.error(function(err) {
    console.log(err);
  });
})

.controller("JobDetailCtrl",['$scope', '$http', '$routeParams', function($scope, $http, $routeParams) {
  request = $http.get("./api/jobs/" + $routeParams.jobName + "/tasks");
  request.success(function(data) {
    $scope.tasks = data;
  });
  request.error(function(err) {
    console.log(err);
  });
}])
