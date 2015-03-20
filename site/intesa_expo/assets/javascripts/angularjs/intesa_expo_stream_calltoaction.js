var intesaExpoStreamCalltoactionModule = angular.module('IntesaExpoStreamCalltoactionModule', ['ngRoute', 'ngSanitize', 'ngAnimate']);

IntesaExpoStreamCalltoactionCtrl.$inject = ['$scope', '$window', '$http', '$timeout', '$interval', '$sce'];
intesaExpoStreamCalltoactionModule.controller('IntesaExpoStreamCalltoactionCtrl', IntesaExpoStreamCalltoactionCtrl);

// csrf-token handling in ajax calls
intesaExpoStreamCalltoactionModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);


function IntesaExpoStreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document) {
  angular.extend(this, new StreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document));

  $scope.extraInit = function() {
    if($scope.calltoaction_info) {
      $scope.menu_field = "";

      if($scope.calltoaction_info.calltoaction.extra_fields) {
        contents = [];
        angular.forEach($scope.calltoaction_info.calltoaction.extra_fields, function(value, key) {
          if(key.indexOf("content_") > -1) {
            content = { key: key, value: value }; 
            contents.push(content);
          }
        });
        if(contents.length > 0) {
          $scope.calltoaction_info.calltoaction.contents = contents;
        }
      }
    } else {
      if($scope.aux.page_tag) {
        $scope.menu_field = $scope.aux.page_tag.miniformat.name;
      }
    }
  };

  $scope.orderContent = function(content) {
    return content["key"];
  }

  $scope.linkTo = function(url, stripe_name) {
    if(angular.isUndefined(stripe_name)) {
      stripe_name = "";
    }
    if(stripe_name == "article-it") {
      if($scope.aux.context_root && url.indexOf("/" + $scope.aux.context_root + "/") > -1) {
        url = url.replace("/" + $scope.aux.context_root + "/", "/imprese/");
      } else {
        url = "/imprese" + url;
      }
    } else {
      if($scope.aux.context_root && url.indexOf("/" + $scope.aux.context_root + "/") < 0) {
        url = "/" + $scope.aux.context_root + "" + url;
      }
    }
    return url;
  };

}