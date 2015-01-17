// Applicazione definita in ng-app="CalltoactionApp" all'interno di un nodo padre.
var rewardCatalogueModule = angular.module('RewardCatalogueModule', ['ngRoute']);

// Gestione del csrf-token nelle chiamate ajax.
searchModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

RewardCatalogueCtrl.$inject = ['$scope', '$window', '$filter', '$http'];
rewardCatalogueModule.controller('rewardCatalogueCtrl', RewardCatalogueCtrl);

function RewardCatalogueCtrl($scope, $window, $filter, $http) {
	
	$scope.init = function(reward_list) {
		$scope.reward_list = reward_list;
	};
	
}