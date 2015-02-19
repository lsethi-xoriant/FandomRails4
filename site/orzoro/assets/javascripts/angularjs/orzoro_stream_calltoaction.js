var orzoroStreamCalltoactionModule = angular.module('OrzoroStreamCalltoactionModule', ['ngRoute', 'ngSanitize', 'ngAnimate']);

OrzoroStreamCalltoactionCtrl.$inject = ['$scope', '$window', '$http', '$timeout', '$interval', '$sce'];
orzoroStreamCalltoactionModule.controller('OrzoroStreamCalltoactionCtrl', OrzoroStreamCalltoactionCtrl);

// Gestione del csrf-token nelle chiamate ajax.
orzoroStreamCalltoactionModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);


function OrzoroStreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document) {
  angular.extend(this, new StreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document));

  $scope.resetToRedo = function(interaction_info) {
    anonymous_user_interactions = getAnonymousUserStorage();
    angular.forEach($scope.user_interactions_history, function(index) {
      user_interaction_info = anonymous_user_interactions["user_interaction_info_list"][index];
      if(user_interaction_info) {
        aux_parse = JSON.parse(user_interaction_info.user_interaction.aux);
        aux_parse.to_redo = true;
        user_interaction_info.user_interaction.aux = JSON.stringify(aux_parse);
      }

      $scope.updateAnonymousUserStorageUserInteractions(user_interaction_info);

      $scope.initCallToActionInfoList([$scope.parent_calltoaction_info]);
      $scope.linked_call_to_actions_index = 1;
      $scope.user_interactions_history = [];
      $scope.updateCallToActionInfoWithAnonymousUserStorage();
      
    });
  };

  $scope.extraInit = function() {
    if($scope.calltoaction_info) {
      $scope.parent_calltoaction_info = $scope.calltoaction_info;

      $scope.compute_in_progress = true;

      // Too long for get.
      $http.post("/last_linked_calltoaction", { "anonymous_user_interactions": getAnonymousUserStorage(), "calltoaction_id": $scope.calltoaction_info.calltoaction.id })
      .success(function(data) { 

        if(data.go_on) {
          $scope.initCallToActionInfoList(data.calltoaction_info_list);
          $scope.linked_call_to_actions_index = data.linked_call_to_actions_index;
          $scope.user_interactions_history = data.user_interactions_history;
          $scope.updateCallToActionInfoWithAnonymousUserStorage();
        }

        $scope.compute_in_progress = false;

      }).error(function() {

        $scope.compute_in_progress = false;

      });


    }

  };

}