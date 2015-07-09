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
    $scope.buildbadgeArray();

    if($scope.aux.redirect) {
      cta_info = $scope.getParentCtaInfo($scope.calltoaction_info);
      window.location = "/#" + cta_info.calltoaction.slug;
    }
  };

  $scope.buildbadgeArray = function() {
    $scope.aux.badge_array = [];
    angular.forEach($scope.aux.badges, function(badge) {
      $scope.aux.badge_array.push(badge);
    });
  }

  $scope.isCoverHidden = function(cta_info) {
    cover = $scope.covers[$scope.getParentCtaId(cta_info)];
    return (cover == false || angular.isUndefined(cover));
  };

  $scope.orderBadgesByCtas = function(badge) {
    return badge.activated_at;
  };

  $scope.openCover = function(cta_info) {
    $scope.covers[$scope.getParentCtaId(cta_info)] = true
  };

  $scope.updateAnswerAjaxSuccessCallback = function(cta_info, data) {
    if(data.badge) {
      $scope.setCtaBadge($scope.getParentCtaInfo(cta_info), data.badge);
    }
  };

  $scope.hasBadge = function(cta_info) {
    return !$scope.getCtaBadge(cta_info).inactive;
  }

  function getCtaBadgeKey(cta_info) {
    return $scope.getParentCtaInfo(cta_info).calltoaction.name;
  }

  $scope.setCtaBadge = function(cta_info, badge) {
    $scope.aux.badges[getCtaBadgeKey(cta_info)] = badge;
    $scope.buildbadgeArray();
  };

  $scope.getCtaBadge = function(cta_info) {
    return $scope.aux.badges[getCtaBadgeKey(cta_info)];
  };

  $scope.getCtaBadgeCost = function(cta_info) {
    badge = $scope.aux.badges[getCtaBadgeKey(cta_info)];
    return $scope.getBadgeCost(badge);
  };

  $scope.getBadgeCost = function(badge) {
    if(badge.inactive) {
      return 0;
    } else {
      return badge.cost;
    }
  };

  $scope.getUserBadgesPercent = function() {
    badge_value = Math.ceil(100 / Object.keys($scope.aux.badges).length);
    badge_percent = 0;
    angular.forEach($scope.aux.badges, function(badge) {
      if(!badge.inactive) {
        badge_percent += badge_value;
      }
    });
    return Math.min(badge_percent, 100);
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

  $scope.appendTips = function() {

    $scope.append_tips_in_progress = true;

    tip_ids_shown = [];
    angular.forEach($scope.aux.tips.tip_info_list, function(_info) {
      tip_ids_shown.push(_info.calltoaction.id);
    });

    $http.post("/append_tips", { calltoaction_ids_shown: tip_ids_shown, tag_name: "tip" })
    .success(function(data) {

      angular.forEach(data.calltoaction_info_list, function(cta_info) {
        $scope.aux.tips.tip_info_list.push(cta_info);
      });

      $scope.aux.tips.has_more = data.has_more;
      $scope.append_tips_in_progress = false;

    });
    
  };

  $scope.shareFreeAjaxSuccess = function(data) {
    if(data.current_user) $scope.current_user = data.current_user;
    if(data.notice_anonymous_user) {
      showRegistrateView();
    }
  };


}