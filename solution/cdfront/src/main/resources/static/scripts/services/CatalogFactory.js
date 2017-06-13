angular.module('cdservice').factory('CatalogResource', function ($resource, config) {
  return $resource(config.getApiUrl() + ':CatalogId', { CatalogId: '@id' }, {
    'queryAll': {
      method: 'GET',
      isArray: true
    }, 'query': { method: 'GET', isArray: false }, 'update': { method: 'PUT' }
  });
});