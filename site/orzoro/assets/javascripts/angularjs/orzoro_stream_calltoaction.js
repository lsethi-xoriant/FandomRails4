var orzoroStreamCalltoactionModule = angular.module('OrzoroStreamCalltoactionModule', ['ngRoute', 'ngSanitize', 'ngAnimate']);

OrzoroStreamCalltoactionCtrl.$inject = ['$scope', '$window', '$http', '$timeout', '$interval', '$sce'];
orzoroStreamCalltoactionModule.controller('OrzoroStreamCalltoactionCtrl', OrzoroStreamCalltoactionCtrl);

// Gestione del csrf-token nelle chiamate ajax.
orzoroStreamCalltoactionModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);


function OrzoroStreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document) {
  angular.extend(this, new StreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document));

  $scope.extraInit = function() {
    if($scope.calltoaction_info) {
      $scope.parent_calltoaction_info = $scope.calltoaction_info;
    }
  };

}