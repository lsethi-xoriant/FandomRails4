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
      content = new Object();
      content["type"] = "cta";
      content["detail_url"] = calltoaction_info["calltoaction"]["detail_url"];
      content["thumb_url"] = calltoaction_info["calltoaction"]["thumbnail_url"];
      content["title"] = calltoaction_info["calltoaction"]["title"];
      content["aux"] = new Object();
      content["aux"]["miniformat"] = calltoaction_info["miniformat"];
      content["aux"]["flag"] = calltoaction_info["flag"];
      thumb_calltoactions.push(content);
    });
    return thumb_calltoactions;
  };

  $scope.nextCallToActionInCategory = function(direction) {
    $scope.calltoaction_info.hide_class = "fadeout_animation";
    $timeout(function() { 
      //$http.get("/next_calltoaction" , { params: { calltoaction_id: $scope.calltoaction_info.calltoaction.id, category_id: $scope.aux.calltoaction_category.id, direction: direction }})   
      $http.post("/next_calltoaction" , { calltoaction_id: $scope.parent_calltoaction_info.calltoaction.id, category_id: $scope.aux.calltoaction_category.id, direction: direction })  
        .success(function(data) { 

          $scope.initCallToActionInfoList(data.calltoaction);
          $scope.calltoaction_info.hide_class = "hide_content";
          
          $scope.aux["related_product"] = data.related_product;

          document.title = data.seo_info.title;
          $('meta[name=description]').attr('content', data.seo_info.meta_description);

          $scope.initAnonymousUser();

          if($scope.calltoaction_info) {
            $scope.linked_call_to_actions_count = $scope.calltoaction_info.calltoaction.extra_fields.linked_call_to_actions_count;
            if($scope.linked_call_to_actions_count) {
              $scope.linked_call_to_actions_index = 1;
            }
            prefix = window.location.pathname.split("/")[1]
            window.history.pushState(null, $scope.calltoaction_info.calltoaction.title, "/" + prefix + "/" + $scope.calltoaction_info.calltoaction.slug);
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

          $scope.goToLastLinkedCallToAction();

          $timeout(function() { 
            $scope.calltoaction_info.hide_class = "hide_content fadein_animation";
          }, 500);

        }).error(function() {
          // ERROR.
        });
    }, 500);
  };

  $scope.extraInit = function() {
    if($scope.calltoaction_info) {
      $scope.menu_field = $scope.calltoaction_info.miniformat.name;
      $scope.calltoaction_ids_shown = $scope.calltoaction_info["calltoaction"]["id"];
      // Move into main angular
      // $scope.goToLastLinkedCallToAction();
    } else {
      if($scope.aux.page_tag) {
        $scope.menu_field = $scope.aux.page_tag.miniformat.name;
      }
    }
    $scope.contentPreviews = $scope.fromCallToActionInfoToContentPreview();
  };

  $scope.orzoroUpdateAnswer = function(calltoaction_info, interaction_info, params, when_show_interaction) {
    $scope.updateAnswer(
        calltoaction_info, 
        interaction_info, 
        params, 
        when_show_interaction, 
        function() {
          if(interaction_info.interaction.resource_type == "test") {
            $scope.calltoaction_info.class = "trivia-interaction__update-answer--fade_out";
          }
        },
        500
      );
  }

  $scope.computeShareFreeCallToActionUrl = function(calltoaction_info) {
    url_to_share = $scope.aux.root_url + "" + $scope.menu_field + "/" + calltoaction_info.calltoaction.slug;
    if($scope.calltoaction_info.calltoaction.extra_fields.linked_result_title) {
      url_to_share = url_to_share + "/" + $scope.calltoaction_info.calltoaction.id;
      message = $scope.calltoaction_info.calltoaction.extra_fields.linked_result_title;
    }
    return url_to_share;
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