var braunIcStreamCalltoactionModule = angular.module('IntesaExpoStreamCalltoactionModule', ['ngRoute', 'ngSanitize', 'ngAnimate']);

BraunIcStreamCalltoactionCtrl.$inject = ['$scope', '$window', '$http', '$timeout', '$interval', '$sce'];
braunIcStreamCalltoactionModule.controller('BraunIcStreamCalltoactionCtrl', BraunIcStreamCalltoactionCtrl);

// csrf-token handling in ajax calls
braunIcStreamCalltoactionModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);


function BraunIcStreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document) {
  angular.extend(this, new StreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document));

  $scope.extraInit = function() {
    $scope.covers = {};
  };

  $scope.isCoverHidden = function(cta_info) {
    cover = $scope.covers[$scope.getParentCtaId(cta_info)];
    return (cover == false || angular.isUndefined(cover));
  };

  $scope.openCover = function(cta_info) {
    $scope.covers[$scope.getParentCtaId(cta_info)] = true
  };

  $scope.getCtaBadge = function(cta_info) {
    key = $scope.getParentCtaInfo(calltoaction_info).calltoaction.name;
    return $scope.aux.badges[key];
  };

  $scope.resetToRedo = function(cta_info) {
    user_interaction_ids = $scope.getUserInteractionsHistory(cta_info);
    parent_cta_id = $scope.getParentCtaId(cta_info);
    $http.post("/reset_redo_user_interactions", { user_interaction_ids: user_interaction_ids, parent_cta_id: parent_cta_id })
    .success(function(data) {   
      $scope.replaceCallToActionInCallToActionInfoList(cta_info, data.calltoaction_info);
    }).error(function() {
    });
  };

}