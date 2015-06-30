var braunIcStreamCalltoactionModule = angular.module('IntesaExpoStreamCalltoactionModule', ['ngRoute', 'ngSanitize', 'ngAnimate']);

BraunIcStreamCalltoactionCtrl.$inject = ['$scope', '$window', '$http', '$timeout', '$interval', '$sce'];
braunIcStreamCalltoactionModule.controller('BraunIcStreamCalltoactionCtrl', BraunIcStreamCalltoactionCtrl);

// csrf-token handling in ajax calls
braunIcStreamCalltoactionModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);


function BraunIcStreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document) {
  angular.extend(this, new StreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document));

}