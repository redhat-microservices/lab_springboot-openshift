angular.module('cdservice').factory('CatalogResource', function($resource){
    var resource = $resource('rest/catalogs/:CatalogId',{CatalogId:'@id'},{'queryAll':{method:'GET',isArray:true},'query':{method:'GET',isArray:false},'update':{method:'PUT'}});
    return resource;
});