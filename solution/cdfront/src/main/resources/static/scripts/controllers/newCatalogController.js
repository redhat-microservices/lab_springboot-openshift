
angular.module('cdservice').controller('NewCatalogController', function ($scope, $location, locationParser, flash, CatalogResource ) {
    $scope.disabled = false;
    $scope.$location = $location;
    $scope.catalog = $scope.catalog || {};
    

    $scope.save = function() {
        var successCallback = function(data,responseHeaders){
            var id = locationParser(responseHeaders);
            flash.setMessage({'type':'success','text':'The catalog was created successfully.'});
            $location.path('/Catalogs');
        };
        var errorCallback = function(response) {
            if(response && response.data) {
                flash.setMessage({'type': 'error', 'text': response.data.message || response.data}, true);
            } else {
                flash.setMessage({'type': 'error', 'text': 'Something broke. Retry, or cancel and start afresh.'}, true);
            }
        };
        CatalogResource.save($scope.catalog, successCallback, errorCallback);
    };
    
    $scope.cancel = function() {
        $location.path("/Catalogs");
    };
});