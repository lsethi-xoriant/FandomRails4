// Applicazione definita in ng-app="CalltoactionApp" all'interno di un nodo padre.
var browseModule = angular.module('BrowseModule', ['ngRoute']);

// Gestione del csrf-token nelle chiamate ajax.
browseModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

BrowseCtrl.$inject = ['$scope', '$window', '$filter', '$http'];
browseModule.controller('BrowseCtrl', BrowseCtrl);

function BrowseCtrl($scope, $window, $filter, $http) {
	var orderBy = $filter('orderBy');
	
	$scope.$watch('visibleElements', function() {
		$scope.tagsEnabled = {};
       	angular.forEach($scope.visibleElements, function(element){
       		angular.forEach(element.tags, function(tag){
       			if(!(tag in $scope.tagsEnabled)){
       				$scope.tagsEnabled[tag] = tag;
       			}
       		});
       	});
    });
	
	$scope.init = function(category_id, elements, tags, has_more) {
		$scope.isTagFilterOpen = false;
		$scope.category_id = category_id;
		$scope.elements = elements;
		$scope.elements_in_page = 12;
		$scope.visibleElements = $scope.elements;
		$scope.tags = tags;
		$scope.tagsEnabled = tags;
		$scope.activeTags = {};
		$scope.has_more = has_more;
		console.log(has_more);
	};
	
	$scope.init_intesa_browse = function(category_id, elements, tags, has_more, column_number) {
		$scope.isTagFilterOpen = false;
		$scope.category_id = category_id;
		$scope.elements = elements;
		$scope.elements_in_page = 12;
		$scope.visibleElements = $scope.elements;
		$scope.tags = tags;
		$scope.tagsEnabled = tags;
		$scope.activeTags = {};
		$scope.has_more = has_more;
		$scope.column_number = column_number;
		$scope.column_class = "col-sm-" + (12/column_number).toString;
		$scope.elements_per_column = $scope.elements_in_page / $scope.column_number;
		$scope.$watch('elements_in_page', function(){
			$scope.elements_per_column = $scope.elements_in_page / $scope.column_number;
			console.log($scope.elements_per_column);
		});
	};
	
	$scope.init_light = function(elements) {
		$scope.elements = elements;
	};
	
	$scope.tagSelected = function(tag){
		if(tag in $scope.activeTags){
			delete $scope.activeTags[tag];
		}else{
			$scope.activeTags[tag] = tag;
		}
		updateContents();
	};
	
	$scope.getColumnIndexElement = function(col, elem){
		return ((elem - 1) * $scope.column_number) + col;
	};
	
	function updateContents(){
		var visibleContents = [];
		angular.forEach($scope.elements, function(elem, key){
			if(isElementVisible(elem)){
				visibleContents.push(elem);
			}
		});
		console.log($scope.visibleElements);
		$scope.visibleElements = visibleContents;
	}
	
	function isElementVisible(elem){
		visible = true;
		angular.forEach($scope.activeTags, function(tagid){
			if(!(tagid in elem.tags)){
				visible = false;
			}
		});
		return visible;
	}
	
	// This function is need to implement a Set of tag to improve performance in search an element
	// in set to avoid complexity of O(n2)  
	function arrayToSet(array){
		var set = {};
		angular.forEach(array, function(value, key){
			set[value] = true;
		});
		return set;
	}
	
	$scope.order = function(predicate, reverse) {
      $scope.visibleElements = orderBy($scope.visibleElements, predicate, reverse);
    };
    
    $scope.load_more = function(offset){
      loadMoreUrl = $scope.updatePathWithProperty("/browse/index_category_load_more.json")

  		$http.get(loadMoreUrl, {
	      params: {
	        offset: offset,
	        tag_id: $scope.category_id
	      }
	    }).then(function(response){
	      $scope.elements = $scope.elements.concat(response.data);
	      $scope.elements_in_page = offset + 12;
	      updateContents();
	      if (response.data.length == 0){
	      	$("a.btn-load-more").hide();
	      }
	    });
  	};

}


