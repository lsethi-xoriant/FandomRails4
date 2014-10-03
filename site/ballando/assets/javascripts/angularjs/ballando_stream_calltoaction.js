var ballandoStreamCalltoactionModule = angular.module('BallandoStreamCalltoactionModule', ['ngRoute']);

BallandoStreamCalltoactionCtrl.$inject = ['$scope', '$window', '$http', '$timeout', '$interval'];
ballandoStreamCalltoactionModule.controller('BallandoStreamCalltoactionCtrl', BallandoStreamCalltoactionCtrl);

function BallandoStreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval) {
  angular.extend(this, new StreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval));

  var COUNTDOWN_TIME = 3;

  $scope.initBallando = function(current_user, calltoactions, calltoactions_count, calltoactions_during_video_interactions_second, google_analytics_code) {
    $scope.init(current_user, calltoactions, calltoactions_count, calltoactions_during_video_interactions_second, google_analytics_code);
    $scope.interactions_showed = {};
  };

  $window.showRegistrateView = function() {
    document.cookie = "connect_from_page = " + top.location;
    top.location = PROFILE_URL;
  };

  $window.adjustAppleMobileIframes = function() {
    $(".iframe-apple-mobile iframe").css("height", $(".iframe-apple-mobile").innerHeight());
    $(".iframe-apple-mobile iframe").css("width", $(".iframe-apple-mobile").innerWidth());
  };

  $window.showCallToAction = function(calltoaction_id, calltoaction_media_type) {

    $(".calltoaction-cover").removeClass("hidden");
    $(".media-iframe").html("");
    $(".home-undervideo-calltoaction").html("");

    $scope.interactions_showed[calltoaction_id] = [];

    $http.post("/generate_cover_for_calltoaction", { calltoaction_id: calltoaction_id, interactions_showed: $scope.interactions_showed[calltoaction_id] })
      .success(function(data) {

        $("#calltoaction-" + calltoaction_id + "-cover").addClass("hidden");
        
        if(calltoaction_media_type == "iframe") {
          $("#iframe-calltoaction-" + calltoaction_id).html($scope.video_players[calltoaction_id]);
          adjustAppleMobileIframes();

          if(data.calltoaction_completed) {
            mountNextInteractionFromRequest(calltoaction_id, data.next_interaction);
          } else {
            $("#home-undervideo-calltoaction-" + calltoaction_id).html(data.render_calltoaction_cover);
            $("#iframe-calltoaction-" + calltoaction_id + " iframe").load(function() {
              appendAndStartCountdown(calltoaction_id); 
            });
          }

        } else {

          if(data.calltoaction_completed) {
            mountNextInteractionFromRequest(calltoaction_id, data.next_interaction);
          } else {
            $("#home-undervideo-calltoaction-" + calltoaction_id).html(data.render_calltoaction_cover);
            appendAndStartCountdown(calltoaction_id); 
          }

        }
      }).error(function() {
        // ERROR.
      });

  };

  $window.appendAndStartCountdown = function(calltoaction_id) {
    $("#calltoaction-" + calltoaction_id + "-countdown").prepend("<div class=\"wrapper hidden-xs\"><div class=\"pie spinner\"></div><div class=\"pie filler\"></div><div class=\"mask\"></div></div>");
    showCallToActionCountdown(calltoaction_id, COUNTDOWN_TIME);
  };

  $window.showCallToActionCountdown = function(calltoaction_id, time) {
    if(time > 0) {
      $("#calltoaction-" + calltoaction_id + "-countdown h3").html(time);
      $timeout(function() { showCallToActionCountdown(calltoaction_id, --time); }, 1000);
    } else {
      $("#calltoaction-" + calltoaction_id + "-countdown").html("");
      nextInteraction(calltoaction_id);
    }
  };

  $window.restartInteractions = function(calltoaction_id) {
    $scope.interactions_showed[calltoaction_id] = [];
    nextInteraction(calltoaction_id);
  };

  $window.nextInteraction = function(calltoaction_id) {
    $http.post("/next_interaction", { interactions_showed: $scope.interactions_showed[calltoaction_id], calltoaction_id: calltoaction_id })
      .success(function(data) {
        mountNextInteractionFromRequest(calltoaction_id, data);
      }).error(function() {
        // ERROR.
      });
  };

  $window.mountNextInteractionFromRequest = function(calltoaction_id, data) {
    $("#home-undervideo-calltoaction-" + calltoaction_id).html(data.render_interaction_str);
    if(data.interaction_id) {
      if($scope.interactions_showed[calltoaction_id]) {
        $scope.interactions_showed[calltoaction_id].push(data.interaction_id);
      } else {
        $scope.interactions_showed[calltoaction_id] = [data.interaction_id];
      }
    }

    if(data.next_quiz_interaction || $scope.interactions_showed[calltoaction_id].length > 1) {
      $("#interaction-" + data.interaction_id + "-next").removeClass("hidden");
    }
  };

  $window.userAnswerInAlwaysVisibleInteraction = function(interaction_id, data) {
    
    showMarkerNearInteraction(interaction_id);
    updateUserRewardInView(data.main_reward_counter);

    $("#undervideo-area-" + interaction_id).html(data.feedback); 
    $("#undervideo-interaction-" + interaction_id).css("display", "none"); 

    calltoaction_id = data.calltoaction_id;
    $http.post("/check_next_interaction", { interaction_id: interaction_id, calltoaction_id: data.calltoaction_id })
      .success(function(data) {
        
        if(data.next_interaction || $scope.interactions_showed[calltoaction_id].length > 1) {
          $("#interaction-" + interaction_id + "-next").removeClass("hidden");
        }

        $timeout(function() { 
          $("#undervideo-outcome-" + interaction_id).css("display", "none"); 
          $("#undervideo-interaction-" + interaction_id).css("display", "block"); 
        }, 3000);

      }).error(function() {
        // ERROR.
      });

  };

  $window.onEnterInteraction = function(interaction_id, answer_id) {
    if(answer_id) {
      $("#answer-" + answer_id).find(".interaction-baloon .baloon.unchosen img").removeClass("hidden");
      $("#answer-" + answer_id).find(".interaction-baloon .baloon.unchosen").removeClass("square");
    } else {
      $("#interaction-" + interaction_id).find(".interaction-baloon .baloon.unchosen img").removeClass("hidden");
      $("#interaction-" + interaction_id).find(".interaction-baloon .baloon.unchosen").removeClass("square");
    }
  };

  $window.onLeaveInteraction = function(interaction_id, answer_id) {
    if(answer_id) {
      $("#answer-" + answer_id).find(".interaction-baloon .baloon.unchosen img").addClass("hidden");
      $("#answer-" + answer_id).find(".interaction-baloon .baloon.unchosen").addClass("square");
    } else {
      $("#interaction-" + interaction_id).find(".interaction-baloon .baloon.unchosen img").addClass("hidden");
      $("#interaction-" + interaction_id).find(".interaction-baloon .baloon.unchosen").addClass("square");
    }
  };

  $window.updateUserRewardInView = function(counter) {
    try {
      window.parent.updateIframeProfileWidget("+" + counter + "<span class=\"glyphicon glyphicon-star\"></span>");
    } catch(err) { }
  };

  $window.updateFiltersMenu = function(tag_id){
  	$(".filter-home-menu .slide").removeClass("active");
  	$(".filter-home-menu .triangle").hide();
  	$(".extra-info").hide();
  	if(tag_id){
   		$(".filter-home-menu .slide-" + tag_id).addClass("active");
   		$(".filter-home-menu .slide-" + tag_id).parent().find(".triangle").show();
   		$(".menu-info-extra .extra-info-" + tag_id).show();
   }else{
   		$(".filter-home-menu .filter-all").addClass("active");
   		$(".filter-home-menu .filter-all").parent().find(".triangle").show();
   		$(".menu-info-extra .extra-info-all").show();
   }
  };
  
}