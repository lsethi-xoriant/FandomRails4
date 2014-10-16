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
	
	$scope.init = function(rankings, user) {
		$scope.rankings = rankings;
		$scope.user = user;
		user_off = rankings.general_user_position[user.id] % 10;
		if(user_off == 0){
			$scope.user_offset = 9;
		}else{
			$scope.user_offset = user_off - 1;
		}
	};
	
	$scope.prev_page = function(current_page, rank){
		page = parseInt(current_page) - 1;
		$scope.get_rank_page(page, rank);
	};
	
	$scope.next_page = function(current_page, rank){
		page = parseInt(current_page) + 1;
		$scope.get_rank_page(page, rank);
	};
	
	$scope.get_rank_page = function(page, rank){
		if(page >= 1 && page <= rank.number_of_pages){
			Api.save({ page: page, rank: JSON.stringify(rank) }, function(data) {
				var newData = {
					current_page: data.current_page,
					my_position: data.my_position,
					number_of_pages: data.number_of_pages,
					rank_list: data.rank_list,
					rank_type: data.rank_type,
					ranking: data.ranking,
					total: data.total
				};
			    var newrank = eval("$scope.rankings." + data.ranking.name + " = " + JSON.stringify(newData));
			});
		}
	};
		
}