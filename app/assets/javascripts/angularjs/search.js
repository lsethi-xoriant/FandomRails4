// Applicazione definita in ng-app="CalltoactionApp" all'interno di un nodo padre.
var searchModule = angular.module('SearchModule', ['ngRoute']);

// Gestione del csrf-token nelle chiamate ajax.
searchModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

SearchCtrl.$inject = ['$scope', '$window', '$filter', '$http'];
searchModule.controller('searchCtrl', SearchCtrl);

function SearchCtrl($scope, $window, $filter, $http) {

	$scope.init = function(browseSections) {
		$scope.sections = browseSections;
	};
	
	$scope.init_search = function(contents, total, query) {
		$scope.contents = contents;
		$scope.total = total;
		$scope.offset = 12;
		$scope.query = query;
	};
	
	$scope.init_view_all = function(contents, total, per_page) {
		$scope.contents = contents;
		$scope.total = total;
		$scope.offset = $scope.perpage = per_page;
	};
	
	$scope.getResults = function(val) {
		
		api_path = "/browse/search.json";
        if($scope.aux.current_property_info && $scope.aux.current_property_info.path) {
        	api_path = "/" + $scope.aux.current_property_info.path + "" + api_path;
        }
		
	    return $http.get(api_path, {
	      params: {
	        q: val,
	        sensor: false
	      }
	    }).then(function(response){
	      return response.data.map(function(item){
	        return item.attributes;
	      });
	    });
  	};
  	
  	$scope.load_more = function(offset){
  		$http.get("/browse/full_search_load_more.json", {
	      params: {
	        offset: offset,
	        query: $scope.query
	      }
	    }).then(function(response){
	      $scope.contents = $scope.contents.concat(response.data);
	      $scope.offset = offset + 12;
	    });
  	};
  	
  	$scope.load_more_recent = function(offset){
  		$http.get("/browse/view_recent/load_more.json", {
	      params: {
	        offset: offset,
	        per_page: $scope.per_page
	      }
	    }).then(function(response){
	      $scope.contents = $scope.contents.concat(response.data);
	      $scope.offset = parseInt(offset) + 12;
	    });
  	};
	
}