angular.module('cdservice').factory('config', function ($http, $q) {
  var deferred = $q.defer();
  var apiUrl = null;
  $http.get("service.json")
    .success(function (data) {
      console.log("Resource : " + data['cd-service'] + ':CatalogId');
      deferred.resolve(data['cd-service']);
      apiUrl = data['cd-service'];
    })
    .error(function () {
      deferred.reject('could not find service.json ....');
    });

  return {
    promise: deferred.promise,
    getApiUrl: function () {
      return apiUrl;
    }
  };
});
