var ballandoStreamCalltoactionModule = angular.module('BallandoStreamCalltoactionModule', ['ngRoute']);

BallandoStreamCalltoactionCtrl.$inject = ['$scope', '$window', '$http', '$timeout', '$interval'];
ballandoStreamCalltoactionModule.controller('BallandoStreamCalltoactionCtrl', BallandoStreamCalltoactionCtrl);

function BallandoStreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval) {
  angular.extend(this, new StreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval));

  var COUNTDOWN_TIME = 3;

  $scope.initBallando = function(current_user, calltoactions, calltoactions_count, calltoactions_during_video_interactions_second, google_analytics_code, current_calltoaction, request_url, calltoactions_active_interaction, aux) {
    $scope.init(current_user, calltoactions, calltoactions_count, calltoactions_during_video_interactions_second, google_analytics_code, current_calltoaction, aux);
    $scope.request_url = request_url;
    
    initInteractionsShowed(calltoactions_active_interaction);

    adjustAppleMobileIframes(); // Iframe in page.
  };

  $window.initInteractionsShowed = function(calltoactions_active_interaction) {
    $scope.interactions_showed = {};
    if(calltoactions_active_interaction) {
      angular.forEach(calltoactions_active_interaction, function(value, key) {
        $scope.interactions_showed[key] = [value["next_interaction"]["interaction_id"]];
      });
    }
  };

  $window.showRegistrateView = function() {
    redirect_top_with_cookie = "/redirect_top_with_cookie?connect_from_page=" + top.location;
    if($scope.current_calltoaction) {
      redirect_top_with_cookie += "&calltoaction_id=" + $scope.current_calltoaction;  
    }
    window.location.href = redirect_top_with_cookie;
  };

  //////////////////////// SHARE WITH DEFAULT SOCIAL MODAL ////////////////////////
  
  $window.doFbShare = function (ctaId, interactionId){
  	ctaUrl = encodeURI($scope.request_url + "facebook_share_page_with_meta/" + ctaId);
  	url = "https://www.facebook.com/sharer/sharer.php?m2w&s=100&p[url]=" + ctaUrl;
  	window.open(url);
	
	  $http.post("/update_basic_share.json", { interaction_id: interactionId, provider: "facebook" })
      .success(function(data) {
        if(data.outcome.attributes.reward_name_to_counter.point == null){
      		afterShareAjaxWithoutPoint(data);
      	}else{
      		updateUserRewardInView(data.main_reward_counter.weekly);
      		afterShareAjax(data,ctaId);
      	}
      });
	};
	
  $window.doTwShare = function (ctaId, interactionId, calltoaction_title){
  	ctaUrl = encodeURI($scope.request_url + "facebook_share_page_with_meta/" + ctaId);
  	url = "https://twitter.com/intent/tweet?url=" + ctaUrl + "&text=" + encodeURIComponent(calltoaction_title);
  	window.open(url);
  		
  	$http.post("/update_basic_share.json", { interaction_id: interactionId, provider: "twitter" })
      .success(function(data) {
      	if(data.outcome.attributes.reward_name_to_counter.point == null) {
      		afterShareAjaxWithoutPoint(data);
      	} else {
      		updateUserRewardInView(data.main_reward_counter.weekly);
      		afterShareAjax(data,ctaId);
      	}	
      });
  };

  //////////////////////// AUDIO EFFECTS METHODS ////////////////////////

  $window.initQuizWaitingAudio = function() {
  };

  $window.enableWaitingAudio = function(status) {
  };

  //////////////////////// OTHER ////////////////////////

  $window.afterShareAjax = function(data, ctaId) {
    if(data.ga) {
      update_ga_event(data.ga.category, data.ga.action, data.ga.label, 1);
      angular.forEach(data.outcome.attributes.reward_name_to_counter, function(value, name) {
        update_ga_event("Reward", "UserReward", name.toLowerCase(), parseInt(value));
      });
    }
    
    positiontop = $('#bottom-feedback-share-'+ctaId).offset().top - 300;
    $('#facebook-share-modal-done').modal('show');
    $('#facebook-share-modal-done').css({ "top": positiontop + "px" });

    $('#bottom-feedback-share-' + ctaId + ' #feedback-label-share').html('Fatto <span class="glyphicon glyphicon-ok"></span>');
    $('#bottom-feedback-share-' + ctaId + ' #feedback-label-share').removeClass("label-warning").addClass("label-success");
  };
  
  $window.afterShareAjaxWithoutPoint = function(data) {
    if(data.ga) {
      update_ga_event(data.ga.category, data.ga.action, data.ga.label, 1);
      angular.forEach(data.outcome.attributes.reward_name_to_counter, function(value, name) {
        update_ga_event("Reward", "UserReward", name.toLowerCase(), parseInt(value));
      });
    }
    
    $('#bottom-feedback-share-' + $scope.ctaShareId + ' #feedback-label-share').html('Fatto <span class="glyphicon glyphicon-ok"></span>');
    $('#bottom-feedback-share-' + $scope.ctaShareId + ' #feedback-label-share').removeClass("label-warning").addClass("label-success");
  };
	
	$window.openCtaShareModal = function (modalId, elem, ctaId, interactionId, alreadyDone, calltoaction_title){
		if($scope.current_user) {
			var positionTop = $(elem).offset().top;
			var modalHeight, modalObj, innerModalObj;
			modalObj = $("#" + modalId);
			position = positionTop - 350;
			if(alreadyDone)
				$("#" + modalId + " .feedback-point").html('<span style="color: green;" class="glyphicon glyphicon-ok-sign"></span> BRAVO! Hai già ottenuto +3 punti');
			modalObj.modal('show');
			modalObj.css({
				"top": position + "px"
			});

			$scope.ctaShareId = ctaId;
			$scope.interactionShareId = interactionId;
      $scope.ctaShareTitle = calltoaction_title;

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

    $timeout.cancel($scope.feedback_timeout);

    $(".calltoaction-cover").removeClass("hidden");
    //$(".media-iframe").html("");
    $(".media-iframe iframe").each(function(i, obj) {
      $(obj).remove();
    });

    $(".home-undervideo-calltoaction").html("");

    $scope.interactions_showed[calltoaction_id] = [];

    $http.post("/generate_cover_for_calltoaction", { aux: $scope.aux, calltoaction_id: calltoaction_id, interactions_showed: $scope.interactions_showed[calltoaction_id] })
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
            }); */
          }

        } else {

          if(data.calltoaction_completed) {
            mountNextInteractionFromRequest(calltoaction_id, data.next_interaction);
          } else {
            $("#home-undervideo-calltoaction-" + calltoaction_id).html(data.render_calltoaction_cover);
          }

        }
      }).error(function() {
        // ERROR.
      });

  };

  $window.restartInteractions = function(calltoaction_id) {
    $scope.interactions_showed[calltoaction_id] = [];
    nextInteraction(calltoaction_id);
  };

  $window.nextInteraction = function(calltoaction_id) {
    $http.post("/next_interaction", { aux: $scope.aux, interactions_showed: $scope.interactions_showed[calltoaction_id], calltoaction_id: calltoaction_id })
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
    updateUserRewardInView(data.main_reward_counter.weekly);

    $("#undervideo-area-" + interaction_id).html(data.feedback); 
    $("#undervideo-interaction-" + interaction_id).css("display", "none"); 

    calltoaction_id = data.calltoaction_id;
    $http.post("/check_next_interaction", { interaction_id: interaction_id, calltoaction_id: data.calltoaction_id })
      .success(function(data) {
        
        if(data.next_interaction || $scope.interactions_showed[calltoaction_id].length > 1) {
          $("#interaction-" + interaction_id + "-next").removeClass("hidden");
        }

        $scope.feedback_timeout = $timeout(function() { 
          $("#undervideo-outcome-" + interaction_id).css("display", "none"); 
          $("#undervideo-interaction-" + interaction_id).css("display", "block"); 
        }, 1500);

      }).error(function() {
        // ERROR.
      });

  };

  $window.onEnterInteraction = function(interaction_id, answer_id) {
    if(answer_id) {
      var elem = $("#answer-" + answer_id).find(".interaction-baloon .baloon.unchosen img");
      elem.removeClass("hidden");
      elem.parent().addClass("baloon-no-pad");
    } else {
      $("#interaction-" + interaction_id).find(".interaction-baloon .baloon.unchosen img").removeClass("hidden");
    }
  };

  $window.onLeaveInteraction = function(interaction_id, answer_id) {
    if(answer_id) {
      var elem = $("#answer-" + answer_id).find(".interaction-baloon .baloon.unchosen img");
      elem.addClass("hidden");
      elem.parent().removeClass("baloon-no-pad");
    } else {
      $("#interaction-" + interaction_id).find(".interaction-baloon .baloon.unchosen img").addClass("hidden");
    }
  };

  $window.updateUserRewardInView = function(counter) {
    // Custom calltoaction user bar
    $(".user-reward-counter").html("+" + counter + " <span class=\"glyphicon glyphicon-star\"></span> punti");
    try {
      // Iframe user widget
      window.parent.updateIframeProfileWidget("+" + counter + "<span class=\"glyphicon glyphicon-star\"></span>");
    } catch(err) { }
  };

  $window.updateFiltersMenu = function(tag_id) {
  	$(".filter-home-menu .slide").removeClass("active");
  	$(".filter-home-menu .triangle").hide();
  	$(".extra-info").hide();
  	if(tag_id) {
   		$(".filter-home-menu .slide-" + tag_id).addClass("active");
   		$(".filter-home-menu .slide-" + tag_id).parent().find(".triangle").show();
   		$(".menu-info-extra .extra-info-" + tag_id).show();
    } else {
   		$(".filter-home-menu .filter-all").addClass("active");
   		$(".filter-home-menu .filter-all").parent().find(".triangle").show();
   		$(".menu-info-extra .extra-info-all").show();
    }
  };
  
}