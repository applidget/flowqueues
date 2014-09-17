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
  var refresh = function() {
    var start = new Date();
    $scope.job = $routeParams.jobName
    request = $http.get("./api/jobs/" + $routeParams.jobName + "/tasks");
    request.success(function(data) {
      $scope.tasks = data;
      var end = new Date();
      $scope.last_updated = end;
      setTimeout(refresh, Math.max((end - start) * 10, 200));
    });
    request.error(function(err) {
      var end = new Date();
      setTimeout(refresh, 2000);
    });  
  };
  refresh();
}])
