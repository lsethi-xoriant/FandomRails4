var hfarmInmStreamCalltoactionModule = angular.module('HfarmInmStreamCalltoactionModule', ['ngRoute', 'ngSanitize', 'ngAnimate']);

HfarmInmStreamCalltoactionCtrl.$inject = ['$scope', '$window', '$http', '$timeout', '$interval', '$sce', '$upload'];
hfarmInmStreamCalltoactionModule.controller('HfarmInmStreamCalltoactionCtrl', HfarmInmStreamCalltoactionCtrl);

// csrf-token handling in ajax calls
hfarmInmStreamCalltoactionModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

function HfarmInmStreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document, $upload) {
  angular.extend(this, new StreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document, $upload));

  $scope.getGroupingGalleries = function(arr, columns) {
    if(angular.isUndefined($scope.groupingGalleryArrs)) {
      setGroupingGalleries(arr, columns);
    }
    return $scope.groupingGalleryArrs;
  };

  function setGroupingGalleries(arr, columns) {
    $scope.groupingGalleryArrs = [];

    for(var i = 0; i < columns; i++) {
      $scope.groupingGalleryArrs.push([]);
    }

    index = 0;
    angular.forEach(arr, function(el) {
      $scope.groupingGalleryArrs[index % columns].push(el);
      console.log($scope.groupingGalleryArrs[index % columns]);
      index++;
    });
  }

}