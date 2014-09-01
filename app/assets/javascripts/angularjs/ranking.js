// Applicazione definita in ng-app="CalltoactionApp" all'interno di un nodo padre.
var rankingModule = angular.module('RankingModule', ['ngRoute', 'ngResource']);

// Gestione del csrf-token nelle chiamate ajax.
rankingModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

RankingCtrl.$inject = ['$scope', '$window', '$resource', '$sce'];
rankingModule.controller('RankingCtrl', RankingCtrl);


function RankingCtrl($scope, $window, $resource, $sce) {

	var Api = $resource('/ranking/page');
	
	$scope.init = function(rankings) {
		$scope.rankings = rankings;
	};
	
	function get_data_for_page(page, rank){
		Api.get({ page: page, perpage: params.count(), conditions: JSON.stringify($scope.tableFilters) }, function(data) {
		    angular.forEach(data.result, function(value, key) {
		       value.notice = $sce.trustAsHtml(value.notice);
		     });
		});
	}
	
}