// Applicazione definita in ng-app="CalltoactionApp" all'interno di un nodo padre.
var rankingModule = angular.module('RankingModule', ['ngRoute', 'ngResource']);

// Gestione del csrf-token nelle chiamate ajax.
rankingModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

RankingCtrl.$inject = ['$scope', '$window', '$resource', '$sce'];
rankingModule.controller('RankingCtrl', RankingCtrl);


function RankingCtrl($scope, $window, $resource, $sce) {

	var Api = $resource('/ranking/page.json');
	
	$scope.init = function(rankings) {
		console.log(rankings);
		$scope.rankings = rankings;
	};
	
	$scope.prev_page = function(current_page, rank){
		page = parseInt(current_page) - 1;
		console.log("PAGE INSIDE PREV " + page);
		$scope.get_rank_page(page, rank);
	};
	
	$scope.next_page = function(current_page, rank){
		page = parseInt(current_page) + 1;
		$scope.get_rank_page(page, rank);
	};
	
	$scope.get_rank_page = function(page, rank){
		if(page >= 1 && page <= rank.number_of_pages){
			Api.get({ page: page, rank: rank }, function(data) {
				var newData = {
					current_page: data.current_page,
					my_position: data.my_position,
					number_of_pages: data.number_of_pages,
					rank_list: data.rank_list,
					rank_type: data.rank_type,
					ranking: data.ranking,
					total: data.total
				};
				console.log("PAGINA: "+page);
			    var newrank = eval("$scope.rankings." + data.ranking.name + " = " + JSON.stringify(newData));
			});
		}
	};
		
}