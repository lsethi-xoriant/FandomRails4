// Applicazione definita in ng-app="CalltoactionApp" all'interno di un nodo padre.
var filterModule = angular.module('FilterEventModule', ['ngRoute', 'ngTable', 'ngResource']);

// Gestione del csrf-token nelle chiamate ajax.
filterModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

FilterCtrl.$inject = ['$scope', '$window', '$timeout', '$resource','ngTableParams'];
filterModule.controller('FilterCtrl', FilterCtrl);

function FilterCtrl($scope, $window, $timeout, $resource, ngTableParams) {

	var Api = $resource('/easyadmin/events/filter');
	var columns = [];
	
	$scope.init = function(fields) {
		
		$.each(fields, function(key,value){
			column = {title: value[1].name, field: value[1].id, visible: true };
			columns.push(column);
		});
	};
	
	$scope.columns = columns;

	$scope.tableFilters = [];
	
	$scope.updateFilter = function(){
		$scope.tableFilters = [];
		$("#event_filter .row-filter:visible").each(function(key,value){
			
			var fieldname = $(value).find(".condition-field-name").attr("name");
			var operand = $(value).find(".condition-type").val();
			var parameter = $(value).find(".condition-value").val();
			var condition = {field: fieldname, operand: operand, value: parameter };
			$scope.tableFilters.push(condition);
		});
		$scope.tableParams.reload();
	};
	
	$scope.tableParams = new ngTableParams({
		page: 1,
	    count: 2,
	}, 
	{
	    total: 0,
	    getData: function($defer, params) {
		    console.log($scope.tableFilters);
		    
		    Api.get({ page: params.page(), perpage: params.count(), conditions: JSON.stringify($scope.tableFilters) }, function(data) {
			    params.total(data.total);
			    $defer.resolve(data.result);
		    });
    	}
	});
	
}

