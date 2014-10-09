var ballandoStreamCalltoactionModule = angular.module('BallandoStreamCalltoactionModule', ['ngRoute']);

BallandoStreamCalltoactionCtrl.$inject = ['$scope', '$window', '$http', '$timeout', '$interval'];
ballandoStreamCalltoactionModule.controller('BallandoStreamCalltoactionCtrl', BallandoStreamCalltoactionCtrl);

function BallandoStreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval) {
  angular.extend(this, new StreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval));

  var COUNTDOWN_TIME = 3;

  $scope.initBallando = function(current_user, calltoactions, calltoactions_count, calltoactions_during_video_interactions_second, google_analytics_code, current_calltoaction, request_url) {
    $scope.init(current_user, calltoactions, calltoactions_count, calltoactions_during_video_interactions_second, google_analytics_code, current_calltoaction);
    $scope.interactions_showed = {};
    $scope.request_url = request_url;
  };

  $window.showRegistrateView = function() {
    document.cookie = "connect_from_page = " + top.location;
    top.location = PROFILE_URL;
  };
  
  $window.doFbShare = function (){
  	ctaUrl = encodeURI($scope.request_url + "facebook_share_page_with_meta/" + $scope.ctaShareId);
  	url = "https://www.facebook.com/sharer/sharer.php?m2w&s=100&p[url]=" + ctaUrl;
  	window.open(url);
	
	  $http.post("/update_basic_share.json", { interaction_id: $scope.interactionShareId, provider: "facebook" })
      .success(function(data) {
        afterShareAjax(data);
      });
	};
	
	$window.doTwShare = function (){
		ctaUrl = encodeURI($scope.request_url + "facebook_share_page_with_meta/" + $scope.ctaShareId);
		url = "https://twitter.com/intent/tweet?url=" + ctaUrl + "&text=" + $scope.ctaShareTitle;
		window.open(url);
		
		$http.post("/update_basic_share.json", { interaction_id: $scope.interactionShareId, provider: "twitter" })
      .success(function(data) {		
        afterShareAjax(data);
      });
	};

  $window.afterShareAjax = function(data) {
    if(data.ga) {
      update_ga_event(data.ga.category, data.ga.action, data.ga.label, 1);
      angular.forEach(data.outcome.attributes.reward_name_to_counter, function(value, name) {
        update_ga_event("Reward", "UserReward", name.toLowerCase(), parseInt(value));
      });
    }
    
    $('#facebook-share-modal').modal('toggle');
    positiontop = $('#facebook-share-modal').offset().top - 40;
    $('#facebook-share-modal-done').modal('show');
    $('#facebook-share-modal-done').css({ "top": positiontop + "px" });

    openShareDoneModal('openShareDoneModal', '#bottom-feedback-share-' + $scope.ctaShareId + ' #button-share-cta');
    $('#bottom-feedback-share-' + $scope.ctaShareId + ' #button-share-cta').attr('onclick','openShareDoneModal(\'facebook-share-modal-done\', this)');
    $('#bottom-feedback-share-' + $scope.ctaShareId + ' #feedback-label-share').html('Fatto <span class="glyphicon glyphicon-ok"></span>');
    $('#bottom-feedback-share-' + $scope.ctaShareId + ' #feedback-label-share').removeClass("label-warning").addClass("label-success");
  };
	
	$window.openCtaShareModal = function (modalId, elem, ctaId, ctaTitle, interactionId){
		if($scope.current_user) {

			var positionTop = $(elem).offset().top;
			var modalHeight, modalObj, innerModalObj;
			modalObj = $("#" + modalId);
			position = positionTop - 350;
			modalObj.modal('show');
			modalObj.css({
				"top": position + "px"
			});

			$scope.ctaShareId = ctaId;
			$scope.ctaShareTitle = ctaTitle;
			$scope.interactionShareId = interactionId;

		} else {

      		showRegistrateView();

    	}
	};
	
	$window.openShareDoneModal = function (modalId, elem){
		
			var positionTop = $(elem).offset().top;
			var modalHeight, modalObj, innerModalObj;
			modalObj = $("#" + modalId);
			position = positionTop - 400;
			modalObj.modal('show');
			modalObj.css({
				"top": position + "px"
			});

	};
  
  $window.adjustAppleMobileIframes = function() {
    $(".iframe-apple-mobile iframe").css("height", $(".iframe-apple-mobile").innerHeight());
    $(".iframe-apple-mobile iframe").css("width", $(".iframe-apple-mobile").innerWidth());
  };

  $window.showCallToAction = function(calltoaction_id, calltoaction_media_type) {

    $(".calltoaction-cover").removeClass("hidden");
    //$(".media-iframe").html("");
    $(".media-iframe iframe").each(function(i, obj) {
      $(obj).detach();
    });

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
            
            /* $("#iframe-calltoaction-" + calltoaction_id + " iframe").load(function() {
              appendAndStartCountdown(calltoaction_id); 
            }); */

          }

        } else {

          if(data.calltoaction_completed) {
            mountNextInteractionFromRequest(calltoaction_id, data.next_interaction);
          } else {
            $("#home-undervideo-calltoaction-" + calltoaction_id).html(data.render_calltoaction_cover);
            /* appendAndStartCountdown(calltoaction_id); */
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