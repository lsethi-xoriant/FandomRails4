// Applicazione definita in ng-app="CalltoactionApp" all'interno di un nodo padre.
var noticeModule = angular.module('NoticeModule', ['ngRoute', 'ngTable', 'ngResource']);

// Gestione del csrf-token nelle chiamate ajax.
noticeModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

NoticeCtrl.$inject = ['$scope', '$window', '$timeout', '$resource','ngTableParams', '$sce'];
NoticeBarCtrl.$inject = ['$scope', '$resource', '$sce'];
NoticePageCtrl.$inject = ['$scope', '$resource', '$sce', '$filter'];
noticeModule.controller('NoticeCtrl', NoticeCtrl);
noticeModule.controller('NoticeBarCtrl', NoticeBarCtrl);
noticeModule.controller('NoticePageCtrl', NoticePageCtrl);

noticeModule.service("LatestNoticeService", function($scope, $resource){
	this.get_notices = function(){
		var Api = $resource("/profile/notices/get_recent_notice");
		
		Api.get({}, function(data) {
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
			var condition = { field: fieldname, operand: operand, value: parameter };
			$scope.tableFilters.push(condition);
		});
		$scope.tableParams.reload();
	};

	$scope.resend_notice = function(notice_id){
		var mail_api = $resource("/easyadmin/notices/resend_notice");
		mail_api.get({ notice_id: notice_id}, function(data){
			alert("notifica reinviata correttamente");
		}); 
	};

	$scope.tableParams = new ngTableParams({
		page: 1,
	    count: 10,
	}, 
	{
	    total: 0,
	    getData: function($defer, params) {
		    Api.get({ page: params.page(), perpage: params.count(), conditions: JSON.stringify($scope.tableFilters) }, function(data) {
			    angular.forEach(data.result, function(value, key) {
			       value.notice = $sce.trustAsHtml(value.notice);
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
	    angular.forEach(data.result, function(value, key) {
	       value.html_notice = $sce.trustAsHtml(value.html_notice);
	     });
	     $scope.notices = data.result;
	});
}

function NoticePageCtrl($scope, $resource, $sce, $filter) {
	//LatestNoticeService.get_notices();
	var Api = $resource('/profile/notices/load_more');

	$scope.init = function(notices) {

		angular.forEach(notices, function(value, key) {
			angular.forEach(value, function(value, key) {
	       		value.html_notice = $sce.trustAsHtml(value.html_notice);
	     	});
	    });

	    result = new Array();
	    currentDate = {'date': notices[0].date, notices: [] };

	    angular.forEach(notices, function(value, key) {

	    	if(currentDate.date != value.date){
	    		result.push(currentDate);
	    		currentDate = {'date': value.date, notices: [] };
	    		currentDate.notices.push(value.notice);
	    	}else{
	    		currentDate.notices.push(value.notice);
	    	}
	    });
	    result.push(currentDate);
	    $scope.notice_list = result;
		$scope.notice_number = 20;
	};

	$scope.loadMore = function(){
		Api.get({count: $scope.notice_number + 20}, function(data) {
		   if (data.length > 0){
		   	 angular.forEach(data, function(value, key) {
		   	 	angular.forEach(value, function(value, key) {
		       		value.html_notice = $sce.trustAsHtml(value.html_notice);
		      	});
		     });
		     $scope.notices = data;
		     $scope.notice_number = $scope.notice_number + 20;
		   }else{
		   	$(".notice-load-more").hide();
		   }
		});
	};

	$scope.mark_as_read = function(id){
		$.ajax({
      type: "POST",
      url: "/profile/notices/mark_as_read",
      data: { notice_id: id },
      beforeSend: function(jqXHR, settings) {
        jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
      },
      success: function(data) {
        if(data.success){
        	$("li#"+id).removeClass("notice--unread");
        	$("li#"+id+" i.fa").removeClass("fa-circle-o").addClass("fa-circle");
        }else{
        	alert(data.message);
        }
      } // success AJAX
  	});
	};

	$scope.min = function(arr) {
  	return $filter('min')
  		($filter('map')(arr, 'date'));
 	};
}