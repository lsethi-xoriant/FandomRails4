// Applicazione definita in ng-app="CalltoactionApp" all'interno di un nodo padre.
var browseModule = angular.module('BrowseModule', ['ngRoute']);

// Gestione del csrf-token nelle chiamate ajax.
browseModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

BrowseCtrl.$inject = ['$scope', '$window', '$filter'];
browseModule.controller('BrowseCtrl', BrowseCtrl);

function BrowseCtrl($scope, $window, $filter) {
	var orderBy = $filter('orderBy');
	var content_array = [];
	
	$scope.init = function(contents) {
		console.log(contents);
		$.each(contents, function(key,value){
			element = value.attributes;
			content_array.push(element);
		});
		$scope.contents = content_array;
		$scope.order('created_at',false);
	};
	
	
	$scope.order = function(predicate, reverse) {
      $scope.contents = orderBy($scope.contents, predicate, reverse);
    };

}


