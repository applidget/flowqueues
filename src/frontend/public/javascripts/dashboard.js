function DashboardCtrl($scope, $http) {
  request = $http.get('./api/tasks');
  request.success(function(data) {
    $scope.tasks = data;

  });
  request.error(function(err) {
    console.log(err);
  });
}