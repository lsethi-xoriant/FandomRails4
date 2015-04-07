// Applicazione definita in ng-app="CalltoactionApp" all'interno di un nodo padre.
var searchModule = angular.module('SearchModule', ['ngRoute']);

// Gestione del csrf-token nelle chiamate ajax.
searchModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

SearchCtrl.$inject = ['$scope', '$window', '$filter', '$http', '$sce'];
searchModule.controller('searchCtrl', SearchCtrl);

function SearchCtrl($scope, $window, $filter, $http, $sce) {

	$scope.init = function(browseSections) {
		angular.forEach(browseSections, function(value, key) {
       		value.icon_url = $sce.trustAsHtml(value.icon_url);
     	});
		$scope.sections = browseSections;
	};
	
	$scope.init_search = function(contents, total, query) {
		$scope.contents = contents;
		$scope.total = total;
		$scope.offset = 12;
		$scope.query = query;
	};
	
	$scope.init_intesa_search = function(contents, total, query, column_number) {
		$scope.contents = contents;
		console.log(contents);
		$scope.total = total;
		$scope.offset = 12;
		$scope.query = query;
		$scope.column_number = column_number;
		$scope.column_class = "col-sm-" + (12/column_number).toString;
		$scope.elements_per_column = $scope.offset / $scope.column_number;
		$scope.$watch('offset', function(){
			$scope.elements_per_column = $scope.offset / $scope.column_number;
		});
	};
	
	$scope.init_view_all = function(contents, total, per_page) {
		$scope.contents = contents;
		$scope.total = total;
		$scope.offset = $scope.perpage = per_page;
	};
	
	$scope.getColumnIndexElement = function(col, elem){
		return ((elem - 1) * $scope.column_number) + col;
	};
	
	$scope.getResults = function(val) {
		
		api_path = "/browse/autocomplete_search";
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
	        return item;
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