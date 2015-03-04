var orzoroStreamCalltoactionModule = angular.module('OrzoroStreamCalltoactionModule', ['ngRoute', 'ngSanitize', 'ngAnimate']);

OrzoroStreamCalltoactionCtrl.$inject = ['$scope', '$window', '$http', '$timeout', '$interval', '$sce'];
orzoroStreamCalltoactionModule.controller('OrzoroStreamCalltoactionCtrl', OrzoroStreamCalltoactionCtrl);

// csrf-token handling in ajax calls
orzoroStreamCalltoactionModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);


function OrzoroStreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document) {
  angular.extend(this, new StreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document));

  $scope.fromCallToActionInfoToContentPreview = function() {
    thumb_calltoactions = [];
    angular.forEach($scope.calltoactions, function(calltoaction_info) {
      content = new Object();
      content["attributes"] = new Object();
      content["attributes"]["type"] = "cta";
      content["attributes"]["detail_url"] = "/call_to_action/" + calltoaction_info["calltoaction"]["slug"];
      content["attributes"]["thumb_url"] = calltoaction_info["calltoaction"]["thumbnail_medium_url"];
      content["attributes"]["title"] = calltoaction_info["calltoaction"]["title"];
      content["attributes"]["aux"] = new Object();
      content["attributes"]["aux"]["miniformat"] = calltoaction_info["miniformat"];
      content["attributes"]["aux"]["flag"] = calltoaction_info["flag"];
      thumb_calltoactions.push(content);
    });
    return thumb_calltoactions;
  };

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

  $scope.nextCallToActionInCategory = function(direction) {
    //$http.get("/next_calltoaction" , { params: { calltoaction_id: $scope.calltoaction_info.calltoaction.id, category_id: $scope.aux.calltoaction_category.id, direction: direction }})
      $http.post("/next_calltoaction" , { calltoaction_id: $scope.calltoaction_info.calltoaction.id, category_id: $scope.aux.calltoaction_category.id, direction: direction })  
        .success(function(data) { 

          $scope.initCallToActionInfoList(data.calltoaction);
          $scope.aux["related_product"] = data.related_product;

          document.title = data.seo_info.title + " | Orzoro";
          $('meta[name=description]').attr('content', data.seo_info.meta_description);

          $scope.initAnonymousUser();

          if($scope.calltoaction_info) {
            $scope.linked_call_to_actions_count = $scope.calltoaction_info.calltoaction.extra_fields.linked_call_to_actions_count;
            if($scope.linked_call_to_actions_count) {
              $scope.linked_call_to_actions_index = 1;
            }
            window.history.pushState(null, $scope.calltoaction_info.calltoaction.title, "/call_to_action/" + $scope.calltoaction_info.calltoaction.slug);
          }

          $timeout(function() { 

            if($scope.calltoaction_info.calltoaction.media_type == 'YOUTUBE') {
              $(".media-youtube iframe").remove();
              iframe = "<div id=\"main-media-iframe-" + $scope.calltoaction_info.calltoaction.id + "\" main-media=\"main\" calltoaction-id=\"" + $scope.calltoaction_info.calltoaction.id + "\" class=\"embed-responsive-item\"></div>";
              $(".media-youtube").html(iframe);
            }

            angular.forEach($scope.calltoactions, function(sc) {
              appendYTIframe(sc);
            });

          }, 0); // To execute code after page is render

          goToLastLinkedCallToAction();

        }).error(function() {
          // ERROR.
        });
  };

  function goToLastLinkedCallToAction() {
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

  $scope.extraInit = function() {
    if($scope.calltoaction_info) {
      $scope.menu_field = $scope.calltoaction_info.miniformat.name;
      $scope.calltoaction_ids_shown = $scope.calltoaction_info["calltoaction"]["id"];
      goToLastLinkedCallToAction();
    } else {
      if($scope.aux.page_tag) {
        $scope.menu_field = $scope.aux.page_tag.miniformat.name;
      }
    }
    $scope.contentPreviews = $scope.fromCallToActionInfoToContentPreview();
  };


  $scope.orzoroAppendCallToAction = function() {
    $scope.appendCallToAction(function() {
      $scope.contentPreviews = $scope.fromCallToActionInfoToContentPreview();
    });
  };

  $scope.showSearch = function(hidden){
  		if('search' != $scope.menu_field){
	  		if($(".navbar__search").is(":visible")){
	  			$(".navbar__search").slideUp();
	  		}else{
	  			$(".navbar__search").slideDown();
	  		}
	  	}
  	};

}