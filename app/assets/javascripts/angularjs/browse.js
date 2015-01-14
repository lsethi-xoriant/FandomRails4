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
	
	$scope.init = function(category, elements, tags) {
		$scope.isTagFilterOpen = false;
		$scope.category = category.attributes;
		$scope.elements = normalizeElements(elements);
		$scope.elements_in_page = 10;
		$scope.visibleElements = $scope.elements.slice(0,$scope.elements_in_page);
		$scope.tags = $scope.tagsEnabled = tags;
		$scope.activeTags = {};
	};
	
	$scope.tagSelected = function(tag){
		if(tag in $scope.activeTags){
			delete $scope.activeTags[tag];
		}else{
			$scope.activeTags[tag] = tag;
		}
		updateContents();
	};
	
	function normalizeElements(elements){
		normalizedElements = [];
		angular.forEach(elements, function(element){
			normalizedElements.push(element.attributes);
		});
		return normalizedElements;
	}
	
	function updateContents(){
		var visibleContents = [];
		angular.forEach($scope.elements, function(elem, key){
			if(isElementVisible(elem)){
				visibleContents.push(elem);
			}
		});
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

}


