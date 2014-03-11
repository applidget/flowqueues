function DashboardCtrl($scope, $http) {
  request = $http.get('./api/jobs');
  request.success(function(data) {
    $scope.jobs = data;

  });
  request.error(function(err) {
    console.log(err);
  });
}