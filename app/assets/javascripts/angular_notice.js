// Applicazione definita in ng-app="CalltoactionApp" all'interno di un nodo padre.
var noticeModule = angular.module('NoticeModule', ['ngRoute', 'ngTable', 'ngResource']);

// Gestione del csrf-token nelle chiamate ajax.
noticeModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

NoticeCtrl.$inject = ['$scope', '$window', '$timeout', '$resource','ngTableParams', '$sce'];
NoticeBarCtrl.$inject = ['$scope', '$resource', '$sce'];
noticeModule.controller('NoticeCtrl', NoticeCtrl);
noticeModule.controller('NoticeBarCtrl', NoticeBarCtrl);

noticeModule.service("LatestNoticeService", function($scope, $resource){
	this.get_notices = function(){
		var Api = $resource("/profile/notices/get_recent_notice");
		
		Api.get({}, function(data) {
			console.log(data);
		    angular.forEach(data.result, function(value, key) {
		       value.html_notice = $sce.trustAsHtml(value.html_notice);
		    });
		    $scope.notices = data.result;
	});
	};
});

function NoticeCtrl($scope, $window, $timeout, $resource, ngTableParams, $sce) {

	var Api = $resource('/easyadmin/notices/filter');
	var columns = [];
	
	$scope.init = function(fields) {
		
		$.each(fields, function(key,value){
			column = {title: value[1].name, field: value[1].id, visible: value[1].visible };
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
	
	$scope.resend_notice = function(notice_id){
		var mail_api = $resource("/easyadmin/notices/sendnotice");
		mail_api.get({ notice_id: notice_id}, function(data){
			alert("notifica reinviata correttamente");
		}); 
	};
	
	$scope.tableParams = new ngTableParams({
		page: 1,
	    count: 2,
	}, 
	{
	    total: 0,
	    getData: function($defer, params) {
		    Api.get({ page: params.page(), perpage: params.count(), conditions: JSON.stringify($scope.tableFilters) }, function(data) {
			    angular.forEach(data.result, function(value, key) {
			       value.notice = $sce.trustAsHtml(value.notice);
			       console.log(value);
			     });
			    params.total(data.total);
			    $defer.resolve(data.result);
		    });
    	}
	});
	
}

function NoticeBarCtrl($scope, $resource, $sce) {
	//LatestNoticeService.get_notices();
	var Api = $resource('/profile/notices/get_recent_notice');
		
	Api.get({}, function(data) {
		console.log(data);
	    angular.forEach(data.result, function(value, key) {
	       value.html_notice = $sce.trustAsHtml(value.html_notice);
	     });
	     $scope.notices = data.result;
	});
}