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
    request = $http.get("./api/jobs/" + $routeParams.jobName + "/tasks");
    $scope.job = $routeParams.jobName
    request.success(function(data) {
      $scope.tasks = data;
      var end = new Date();
      setTimeout(refresh, Math.max((end - start) * 10, 200));
    });
    request.error(function(err) {
      var end = new Date();
      setTimeout(refresh, 20000);
    });  
  };
  refresh();
}])
