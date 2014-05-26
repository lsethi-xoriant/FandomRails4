// Applicazione definita in ng-app="CalltoactionApp" all'interno di un nodo padre.
var filterApp = angular.module('EventApp', ['ngRoute', 'ngTable', 'ngResource']);

// Gestione del csrf-token nelle chiamate ajax.
filterApp.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

FilterCtrl.$inject = ['$scope', '$window', '$timeout', '$resource','ngTableParams'];
filterApp.controller('FilterCtrl', FilterCtrl);

function FilterCtrl($scope, $window, $timeout, $resource, ngTableParams) {

	var Api = $resource('/easyadmin/events/filter');

	$scope.columns = [
        { title: 'Date', field: 'date', visible: true },
        { title: 'User', field: 'user', visible: true },
        { title: 'Interaction', field: 'interaction', visible: true },
        { title: 'Answer', field: 'answer_correct', visible: true }
    ];
	
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

