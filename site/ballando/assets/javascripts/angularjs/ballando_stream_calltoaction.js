var ballandoStreamCalltoactionModule = angular.module('BallandoStreamCalltoactionModule', ['ngRoute']);

BallandoStreamCalltoactionCtrl.$inject = ['$scope', '$window', '$http', '$timeout', '$interval'];
ballandoStreamCalltoactionModule.controller('BallandoStreamCalltoactionCtrl', BallandoStreamCalltoactionCtrl);

function BallandoStreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval) {
  angular.extend(this, new StreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval));

  var interactions_showed = {};

  $scope.initBallando = function(current_user, calltoactions, calltoactions_count, calltoactions_during_video_interactions_second, google_analytics_code) {
    $scope.init(current_user, calltoactions, calltoactions_count, calltoactions_during_video_interactions_second, google_analytics_code);
    checkDocumentHeight("fandom"); 
  };

  $window.checkDocumentHeight = function(myIframeId){
    var lastHeight = 0;
    (function run(){
      newHeight = $("body").innerHeight();
      if(lastHeight != newHeight) {
        window.parent.containerHeight(newHeight, myIframeId);
      }
      lastHeight = newHeight;
      timer = setTimeout(run, 300);
    })();
  };

  $window.showCallToAction = function(calltoaction_id) {
    $("#calltoaction-" + calltoaction_id + "-cover").addClass("hidden");
    showCallToActionCountdown(calltoaction_id, 3);

    $("#calltoaction-" + calltoaction_id + "-countdown").prepend("<div class=\"wrapper hidden-xs\"><div class=\"pie spinner\"></div><div class=\"pie filler\"></div><div class=\"mask\"></div></div>");
  };

  $window.showCallToActionCountdown = function(calltoaction_id, time) {
    if(time > 0) {
      $("#calltoaction-" + calltoaction_id + "-countdown h3").html(time);
      $timeout(function() { showCallToActionCountdown(calltoaction_id, --time) }, 1000);
    } else {
      $("#calltoaction-" + calltoaction_id + "-countdown").html("");
      nextInteraction(calltoaction_id);
    }
  };

  $window.restartInteractions = function(calltoaction_id) {
    interactions_showed[calltoaction_id] = [];
    nextInteraction(calltoaction_id);
  };

  $window.nextInteraction = function(calltoaction_id) {
    $http.post("/next_interaction", { interactions_showed: interactions_showed[calltoaction_id], calltoaction_id: calltoaction_id })
      .success(function(data) {

        $("#home-undervideo-calltoaction-" + calltoaction_id).html(data.render_interaction_str);
        if(data.interaction_id) {
          if(interactions_showed[calltoaction_id]) {
            interactions_showed[calltoaction_id].push(data.interaction_id);
          } else {
            interactions_showed[calltoaction_id] = [data.interaction_id];
          }
        }

        if(data.next_quiz_interaction || interactions_showed[calltoaction_id].length > 1) {
          $("#interaction-" + data.interaction_id + "-next").removeClass("hidden");
        }

      }).error(function() {
        // ERROR.
      });
  };

  $window.userAnswerInAlwaysVisibleInteraction = function(interaction_id, data) {
    
    showMarkerNearInteraction(interaction_id);
    updateUserRewardInView(data.main_reward_counter);

    $("#undervideo-area-" + interaction_id).html(data.feedback); 
    $("#undervideo-interaction-" + interaction_id).css("display", "none"); 

    calltoaction_id = data.calltoaction_id
    $http.post("/check_next_interaction", { interactions_showed: interactions_showed[calltoaction_id], calltoaction_id: data.calltoaction_id })
      .success(function(data) {
        
        if(data.next_quiz_interaction || interactions_showed[calltoaction_id].length > 1) {
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
      $("#answer-" + answer_id).find(".interaction-baloon .baloon.unchosen img").removeClass("hidden")
      $("#answer-" + answer_id).find(".interaction-baloon .baloon.unchosen").removeClass("square");
    } else {
      $("#interaction-" + interaction_id).find(".interaction-baloon .baloon.unchosen img").removeClass("hidden")
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

}