var streamCalltoactionModule = angular.module('StreamCalltoactionModule', ['ngRoute', 'ngSanitize', 'ngAnimate']);

StreamCalltoactionCtrl.$inject = ['$scope', '$window', '$http', '$timeout', '$interval', '$sce'];
streamCalltoactionModule.controller('StreamCalltoactionCtrl', StreamCalltoactionCtrl);

// Gestione del csrf-token nelle chiamate ajax.
streamCalltoactionModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

streamCalltoactionModule.animation('.slide-left', function() {
  return {
    // you can also capture these animation events
    addClass : function(element, className, done) {
    	$(element).hide('slide', {direction: 'left'}, 1000);
    },
    removeClass : function(element, className, done) {
    	$(element).show('slide', {direction: 'left'}, 1000);
    }
  };
});

streamCalltoactionModule.animation('.slide-right', function() {
  return {
    // you can also capture these animation events
    addClass : function(element, className, done) {
    	$(element).effect( "fade", {}, 1000);
    },
    removeClass : function(element, className, done) {
    	$(element).effect( "fade", {}, 1000);
    }
  };
});

function StreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval) {

  $scope.unsafe = function(value) {
     return $sce.trustAsHtml(value);
  };

  $scope.sanitizeText = function(text) {
    return String(text).replace(/<[^>]+>/gm, '');
  };

  angular.element(document).ready(function () {
    if(window.name != "iframe_canvas_fb_https") {
      document.cookie = "oauth_connect_from_page=; expires=Thu, 01 Jan 1970 00:00:00 UTC"; 
    }
  });

  $scope.init = function(current_user, calltoaction_info_list, calltoactions_count, calltoactions_during_video_interactions_second, google_analytics_code, current_calltoaction, aux) {
    $scope.aux = aux;
    $scope.current_user = current_user;
    $scope.calltoactions = calltoaction_info_list;

    if($scope.aux.from_registration) {
      $("#registration-modal").modal("show");
      ga('send', 'event', "Registration", "Registration", "Registration", 1, true);
    }

    if($scope.aux.current_property_info) {
      $scope.current_tag_id = $scope.aux.current_property_info.id;
    }

    // With one calltoaction I active comment interaction
    $scope.comments_polling = new Object();
    $scope.ajax_comment_append_in_progress = false;
    if($scope.calltoactions.length == 1) {
      comment_info = getCommentInteraction($scope.calltoactions[0].calltoaction.id);
      if(comment_info) {
        comment_info.interaction.resource.comment_info.open = true;
        $scope.comments_polling.polling = $interval($scope.commentsPolling, 15000);
        $scope.comments_polling.interaction_info = comment_info;
      }
    }

    if($scope.aux.init_captcha && !$scope.current_user) {
      initCaptcha();
    }

    initAnonymousUser();

    $scope.form_data = {};
    $scope.animation_in_progress = false;
    
    $scope.BUY_PRODUCT_CLASS_ADD_ANIMATION = "slide-right";
    $scope.BUY_PRODUCT_CLASS_REMOVE_ANIMATION = "";
    $scope.TITLE_PRODUCT_CLASS_ADD_ANIMATION = "call-to-action__media__description hidden-xs slide-left";
    $scope.TITLE_PRODUCT_CLASS_REMOVE_ANIMATION = "call-to-action__media__description hidden-xs";

    $scope.interactions_timeout = new Object();
    $scope.overvideo_interaction_locked = {};
    $scope.secondary_video_players = {};
    $scope.play_event_tracked = {};
    $scope.current_user_answer_response_correct = {};
    $scope.calltoactions_during_video_interactions_second = calltoactions_during_video_interactions_second;
    $scope.current_calltoaction = current_calltoaction;
    $scope.calltoactions_count = calltoactions_count;
    $scope.google_analytics_code = google_analytics_code;
    $scope.polling = false;
    $scope.youtube_api_ready = false;
    $scope.buy_product_class = $scope.BUY_PRODUCT_CLASS_REMOVE_ANIMATION;
    $scope.title_product_class = $scope.TITLE_PRODUCT_CLASS_REMOVE_ANIMATION;
    
    var tag = document.createElement('script');
    tag.src = "//www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
    
    if($scope.aux.kaltura) {
      kaltura_api_link = "http://cdnapi.kaltura.com/p/" + $scope.aux.kaltura.partner_id + "/sp/" + $scope.aux.kaltura.partner_id + "00/embedIframeJs/uiconf_id/" + $scope.aux.kaltura.uiconf_id + "/partner_id/" + $scope.aux.kaltura.partner_id;
      var tag = document.createElement('script');
      tag.src = kaltura_api_link;
      var firstScriptTag = document.getElementsByTagName('script')[0];
      firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
      initKalturaApi();
    }
    
    $(function(){ flowplayerReady(); });

    //updateSecondaryVideoPlayers($scope.calltoactions);

    $("#append-other button").attr('disabled', false);
    if($scope.calltoactions.length >= $scope.calltoactions_count) {
      $("#append-other button").hide();
    } else {
      $("#append-other button").show();
    }
    
  };
  
  $window.playSound = function(element){
  	element.load();
  	element.play();
  };

  $scope.acceptCookies = function() {
    $http.post("/user_cookies")
      .success(function(data) { 
        $("#cookies-bar").fadeOut("slow");
      }).error(function() {
        // ERROR.
      });
  };

  $scope.nextRandomCallToAction = function(current_calltoaction_info) {
    update_ga_event("UpdateCallToAction", "nextRandom", "nextRandom", 1);

    except_calltoaction_id = calltoaction_info.calltoaction.id;
    $scope.animation_in_progress = true;

  	//playSound($(".click-sound")[0]);
	
    $http.post("/random_calltoaction", { except_calltoaction_id: except_calltoaction_id })
      .success(function(data) { 
    		$scope.buy_product_class = $scope.BUY_PRODUCT_CLASS_ADD_ANIMATION;
    		$scope.title_product_class = $scope.TITLE_PRODUCT_CLASS_ADD_ANIMATION;
  		
        $(".call-to-action__share-and-win-animation").fadeTo(1500,0);  			
  			$(".gift-image").fadeTo(1500,0);
  			setTimeout(function(){
  				$(".loader").removeClass("hidden");
  				playSound($(".roll-sound")[0]);
  			}, 1500);

  			setTimeout(function(){
          $(".call-to-action__mobile-description").html(data.calltoaction_info_list[0].calltoaction.description)
  				$(".cta-media img.hidden-xs").attr("src", data.calltoaction_info_list[0].calltoaction.media_image);
  				$(".cta-media img.mobile").attr("src", data.calltoaction_info_list[0].calltoaction.thumbnail_url);
  				$(".loader").addClass("hidden");
  				$(".gift-image").fadeTo(1500,1);
          $(".call-to-action__share-and-win-animation").fadeTo(1500,1);
  				playSound($(".blink-sound")[0]);
  			}, 4500);
			
        setTimeout(function() {
        	$scope.$apply(function() {
        		//console.log(data.calltoaction_info_list[0]);
        		$scope.calltoactions[0].calltoaction.description = data.calltoaction_info_list[0].calltoaction.description;
        		$scope.calltoactions[0].calltoaction.aux.shop_url = data.calltoaction_info_list[0].calltoaction.aux.shop_url;
    			  $scope.buy_product_class = $scope.BUY_PRODUCT_CLASS_REMOVE_ANIMATION;
  				  $scope.title_product_class = $scope.TITLE_PRODUCT_CLASS_REMOVE_ANIMATION;
				    setTimeout(function() {
              $scope.$apply(function() {
        			  $scope.calltoactions = data.calltoaction_info_list;
                $scope.animation_in_progress = false;
              });
       			}, 1500);
    			});
	    		initAnonymousUser();
        }, 6000);
        
      }).error(function() {
        // ERROR.
        $scope.animation_in_progress = false;
      });
  };

  $scope.playInstantWin = function() {
    update_ga_event("PlayInstantWin", "PlayInstantWin", "PlayInstantWin", 1);
    $scope.aux.instant_win_info.in_progress = true;
    delete $scope.aux.instant_win_info.win;
    $http.post("/play", { interaction_id: $scope.aux.instant_win_info.interaction_id })
      .success(function(data) { 
        $timeout(function() { 
          updateUserRewardInView(data.main_reward_counter.general);
          $scope.aux.instant_win_info.in_progress = false;
          $scope.aux.instant_win_info.message = data.message;
          $scope.aux.instant_win_info.win = data.win;
        }, 3000);
      }).error(function() {
        // ERROR.
      });
  };

  $scope.openInstantWinModal = function() {
  	$(".click-sound").trigger("play");
    $("#modal-interaction-instant-win").modal("show");
  };

  $scope.openRegistrationModalForInstantWin = function(user) {
  	$(".click-sound").trigger("play");
    $scope.form_data.current_user = user;
    $("#modal-interaction-instant-win-registration").modal("show");
  };

  $scope.processRegistrationForm = function() {
    delete $scope.form_data.current_user.errors;
    data = { user: $scope.form_data.current_user };
    $http({ method: 'POST', url: '/profile/complete_for_contest', data: data })
      .success(function(data) {
        if(data.errors) {
          $scope.form_data.current_user.errors = data.errors;
        } else {
          $('#modal-interaction-instant-win-registration').on('hidden.bs.modal', function () {
            $scope.openInstantWinModal();
          });
          $("#modal-interaction-instant-win-registration").modal("hide");
          $scope.current_user.registration_fully_completed = true;
        }
      });
  };

  function getOvervideoInteractionAtSeconds(calltoaction_id, seconds) {
    overvideo_interaction = null;
    calltoaction_info = getCallToActionInfo(calltoaction_id);
    angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(interaction_info.interaction.when_show_interaction == "OVERVIDEO_DURING" && interaction_info.interaction.seconds == seconds) {
        overvideo_interaction = interaction_info;
      }
    });
    return overvideo_interaction;
  }
  
  function getOvervideoInteractions(calltoaction_id) {
    overvideo_interactions = [];
    calltoaction_info = getCallToActionInfo(calltoaction_id);
    angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(interaction_info.interaction.when_show_interaction == "OVERVIDEO_DURING") {
        overvideo_interactions.push( { time: interaction_info.interaction.seconds, interaction: interaction_info});
      }
    });
    return overvideo_interactions;
  }

  $scope.currentUserEmptyAndAnonymousInteractionEnable = function() {
    return (!$scope.current_user && $scope.aux.anonymous_interaction);
  };

  function getPlayer(calltoaction_id) {
    calltoaction_info = getCallToActionInfo(calltoaction_id);
    return calltoaction_info.calltoaction.player;
  }

  function getCallToActionInfo(calltoaction_id) {
    calltoaction_info_result = null;
    angular.forEach($scope.calltoactions, function(calltoaction_info) {
      if(calltoaction_info.calltoaction.id == calltoaction_id) {
        calltoaction_info_result = calltoaction_info;
      }
    });
    return calltoaction_info_result;
  }

  $scope.shareInteractionsPresent = function(calltoaction_id) {
    share_interaction_present = false;
    calltoaction_info = getCallToActionInfo(calltoaction_id);
    angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(interaction_info.interaction.resource_type == "share") {
        share_interaction_present = true;
      }
    });
    return share_interaction_present;
  };

  $scope.openCommentInfo = function(interaction_info) {
    if($scope.comments_polling.interaction_info) {
      $scope.comments_polling.interaction_info.interaction.resource.comment_info.open = false;
      $scope.comments_polling.interaction_info.interaction.resource.comment_info.comments = $scope.comments_polling.interaction_info.interaction.resource.comment_info.comments.slice(0, 5);
    }
    interaction_info.interaction.resource.comment_info.open = true;
    $scope.comments_polling.polling = $interval($scope.commentsPolling, 15000);
    $scope.comments_polling.interaction_info = interaction_info;
  };

  $scope.closeCommentInfo = function(interaction_info) {
    if($scope.comments_polling.interaction_info) {
      $scope.comments_polling.interaction_info.interaction.resource.comment_info.open = false;
      $scope.comments_polling.interaction_info.interaction.resource.comment_info.comments = $scope.comments_polling.interaction_info.interaction.resource.comment_info.comments.slice(0, 5);
      $interval.cancel($scope.comments_polling.polling);
    }
  };

  $scope.overvideoInteractionsPresent = function(calltoaction_id) {
    overvideo_interaction_present = false;
    calltoaction_info = getCallToActionInfo(calltoaction_id);
    angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(interaction_info.interaction.when_show_interaction == "OVERVIDEO_DURING" || interaction_info.interaction.when_show_interaction == "OVERVIDEO_END") {
        overvideo_interaction_present = true;
      }
    });
    return overvideo_interaction_present;
  };

  function getOvervideoEndInteractionInfo(calltoaction_id) {
    overvideo_end_interaction = null;
    calltoaction_info = getCallToActionInfo(calltoaction_id);
    angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(interaction_info.interaction.when_show_interaction == "OVERVIDEO_END") {
        overvideo_end_interaction = interaction_info;
      }
    });
    return overvideo_end_interaction;
  }

  function getCommentInteraction(calltoaction_id) {
    comment_interaction = null;
    calltoaction_info = getCallToActionInfo(calltoaction_id);
    angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(interaction_info.interaction.resource_type == "comment") {
        comment_interaction = interaction_info;
      }
    });
    return comment_interaction;
  }

  function getStreamCommentInteractions() {
    comment_interactions = [];
    angular.forEach($scope.calltoactions, function(calltoaction_info) {
      angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
        if(interaction_info.interaction.resource_type == "comment") {
          comment_interaction = new Object({
            "interaction_id": interaction_info.interaction.id,
            "calltoaction_id": calltoaction_info.calltoaction.id
          })    
          comment_interactions.push(comment_interaction);
        }
      });
    });
    return comment_interactions;
  }

  function getPlayInteraction(calltoaction_id) {
    play_interaction = null;
    calltoaction_info = getCallToActionInfo(calltoaction_id);
    angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(interaction_info.interaction.resource_type == "play") {
        play_interaction = interaction_info.interaction;
      }
    });
    return play_interaction;
  }

  $scope.filterShareInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type == "share");
  };

  $scope.filterLikeInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type == "like");
  };

  $scope.filterCommentInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type == "comment");
  };

  $scope.likePressed = function(interaction_info) {
    if(interaction_info.user_interaction) {
      return (JSON.parse(interaction_info.user_interaction.aux)["like"]);
    } else {
      return false;
    }
  };

  $scope.filterLikeInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type == "like");
  };

  $scope.filterPlayInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type == "play");
  };

  $scope.filterOvervideoDuringInteractions = function(interaction_info) {
    return (interaction_info.interaction.when_show_interaction == "OVERVIDEO_DURING" || interaction_info.interaction.when_show_interaction == "OVERVIDEO_END");
  };

  $scope.filterAlwaysVisibleInteractions = function(interaction_info) {
    return (interaction_info.interaction.when_show_interaction == "SEMPRE_VISIBILE");
  };

  $scope.filterOvervideoDuringActiveInteraction = function(interaction_info) {
    return interaction_info.interaction.overvideo_active;
  };

  $scope.filterRemoveShareInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type != "share");
  };

  $scope.filterRemovePlayInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type != "play");
  };

  $window.update_ga_event = function(category, action, label, value) {
    if($scope.google_analytics_code.length > 0) {
      ga('send', 'event', category, action, label, value, true);
    }
  };

  $window.getAnonymousUserStorage = function() {
    return $scope.current_user ? null : JSON.parse(localStorage[$scope.aux.tenant]);
  };

  $window.setAnonymousUserStorageAttr = function(name, value) {
    anonymous_user = getAnonymousUserStorage();
    eval("anonymous_user." + name + " = " + value);
    localStorage.setItem($scope.aux.tenant, JSON.stringify(anonymous_user));
  };

  function updateAnonymousUserStorageUserInteractions(user_interaction) {
    anonymous_user = getAnonymousUserStorage();

    if(!anonymous_user.user_interaction_info_list) {
      anonymous_user.user_interaction_info_list = new Array(user_interaction);
    } else {
      anonymous_user.user_interaction_info_list.push(user_interaction);
    }

    localStorage.setItem($scope.aux.tenant, JSON.stringify(anonymous_user));
  }

  function initAnonymousUserStorage() {
    anonymous_user = new Object();
    localStorage.setItem($scope.aux.tenant, JSON.stringify(anonymous_user));
  }

  function initAnonymousUser() {
    if($scope.currentUserEmptyAndAnonymousInteractionEnable() && localStorage[$scope.aux.tenant] == null) {
      initAnonymousUserStorage();      
    } else if ($scope.current_user && localStorage[$scope.aux.tenant] != null) {
      clearAnonymousUserStorage();
    }

    if(!$scope.current_user && $scope.aux.anonymous_interaction) {
      updateCallToActionInfoWithAnonymousUserStorage();
    }
  }


  function clearAnonymousUserStorage() {
    localStorage.removeItem($scope.aux.tenant);
  }

  function updateCallToActionInfoWithAnonymousUserStorage() {
    anonymous_user = getAnonymousUserStorage();
    if(anonymous_user.user_interaction_info_list) {
      angular.forEach(anonymous_user.user_interaction_info_list, function(user_interaction_info) { 
        updateUserInteraction(user_interaction_info.calltoaction_id, user_interaction_info.interaction_id, user_interaction_info.user_interaction);
      });
    }
  }

  function updateUserInteraction(calltoaction_id, interaction_id, user_interaction) {
    calltoaction_info = getCallToActionInfo(calltoaction_id);
    angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(interaction_info.interaction.id == interaction_id) {
        interaction_info.user_interaction = user_interaction;
      }
    });
  }

  function updateAnswersInInteractionInfo(interaction_info, answers) {
    interaction_info.interaction.resource.answers = answers;
  }

  function getCallToActionMediaData(calltoaction_id) {
    calltoaction_info = getCallToActionInfo(calltoaction_id);
    media_data = null;
    if (calltoaction_info != null) {
      media_data = calltoaction_info.calltoaction.media_data;
    }
    return media_data;
  }

  //////////////////////// UPDATING AND ADDING PLAYERS AND CALLTOACTIONS METHODS ////////////////////////

  $window.updateSecondaryVideoPlayers = function(calltoactions) {
    angular.forEach(calltoactions, function(calltoaction) {
      $scope.secondary_video_players[calltoaction.id] = new Object();
    });
  };

  $window.updatePageWithTag = function(tag_id) {

    $http.post("/update_call_to_action_in_page_with_tag", { tag_id: tag_id })
      .success(function(data) {
        
        $scope.current_tag_id = tag_id; 

        $scope.calltoactions = data.calltoactions;
        $scope.calltoactions_count = data.calltoactions_count;

        $scope.calltoactions_during_video_interactions_second = data.calltoactions_during_video_interactions_second;
    
        $("#calltoaction-stream").html(data.calltoactions_render);

        angular.forEach($scope.calltoactions, function(sc) {
          appendYTIframe(sc);
        });

        updateSecondaryVideoPlayers($scope.calltoactions);

        $("#append-other button").attr('disabled', false);
        if($scope.calltoactions.length >= $scope.calltoactions_count) {
          $("#append-other button").hide();
        } else {
          $("#append-other button").show();
        }
		
		    updateFiltersMenu(tag_id);
        
      }).error(function() {
        // ERROR.
      });
  };

  $window.updateFiltersMenu = function(tag_id){
  	$(".home-filter").removeClass("active");
        if(tag_id) {
          $("#home-filter-" + tag_id).addClass("active");
        } else {
          $("#home-filter-all").addClass("active");
        }
  };

  $window.appendYTIframe = function(calltoaction_info) {
    if(calltoaction_info.calltoaction.media_type == "YOUTUBE" && $scope.youtube_api_ready) {
      
      player = new youtubePlayer('main-media-iframe-' + calltoaction_info.calltoaction.id, calltoaction_info.calltoaction.media_data);
      calltoaction_info.calltoaction["player"] =  player;

      $scope.play_event_tracked[calltoaction_info.calltoaction.id] = false;
      $scope.current_user_answer_response_correct[calltoaction_info.calltoaction.id] = false;

    }
  };

  $window.appendOrUpdateYTIframeSecondary = function(calltoaction_id, media_data) {
    if($scope.youtube_api_ready) {
      video_player_from_calltoaction = $scope.secondary_video_players[calltoaction_id]["player"];
      if(video_player_from_calltoaction) {
        video_player_from_calltoaction = $scope.secondary_video_players[calltoaction_id]["player"];
        video_player_from_calltoaction.loadVideoById(media_data);
      } else {
        appendYTIframeSecondary(calltoaction_id, media_data);
      }
    }
  };

  $window.appendYTIframeSecondary = function(calltoaction_id, media_data) { 
    $scope.secondary_video_players[calltoaction_id]["player"] = new YT.Player(('home-stream-video-secondary-' + calltoaction_id), {
        playerVars: { html5: 1, autoplay: 1 /* controls: 0, disablekb: 1, rel: 0, wmode: "transparent", showinfo: 0 */ },
        height: "100%", width: "100%",
        videoId: media_data,
        events: { 'onReady': onYouTubePlayerReady, 'onStateChange': onPlayerStateChange }
      });
  };

  $scope.appendCallToAction = function() {
    if($scope.calltoactions.length < $scope.calltoactions_count) {

      $("#append-other button").attr('disabled', true);

      $http.post("/append_calltoaction", { calltoactions_showed: $scope.calltoactions, tag_id: $scope.current_tag_id, current_calltoaction: $scope.current_calltoaction })
      .success(function(data) {

        angular.forEach(data.calltoaction_info_list, function(calltoaction_info) {
          $scope.calltoactions.push(calltoaction_info);
          appendYTIframe(calltoaction_info);
        });

        if(!$scope.current_user && $scope.aux.anonymous_interaction) {
          updateCallToActionInfoWithAnonymousUserStorage();
        }

        hash_to_append = data.calltoactions_during_video_interactions_second;
        hash_main = $scope.calltoactions_during_video_interactions_second;
        for(var name in hash_to_append) { 
          hash_main[name] = hash_to_append[name]; 
        }
        $scope.calltoactions_during_video_interactions_second = hash_main;

        if($scope.calltoactions.length >= $scope.calltoactions_count) {
          $("#append-other button").hide();
        }

        //updateSecondaryVideoPlayers(data.calltoactions);

        $("#append-other button").attr('disabled', false);

      });
      
    } else {
      $("#append-other").remove();
    }
    
  };

  $window.updateYTIframe = function(calltoaction_video_code, calltoaction_id, autoplay) {
    current_video_player = getPlayer(calltoaction_id);
    if($scope.youtube_api_ready && current_video_player) {
      $scope.play_event_tracked[calltoaction_id] = false;
      if(autoplay) {
        current_video_player.playerManager.loadVideoById(calltoaction_video_code);
      } else {
        current_video_player.playerManager.cueVideoById(calltoaction_video_code);
      }
    }
  };

  //////////////////////// SHOWING AND GETTING INTERACTION METHODS ////////////////////////

  $scope.showCallToAction = function(calltoaction_id, calltoaction_media_type) {
    if(calltoaction_media_type == "IFRAME") {

      $(".calltoaction-cover").removeClass("hidden");
      $(".media-iframe").addClass("hidden");

      $(".media-iframe iframe").each(function(i, obj) {
        $(obj).remove();
      });

      $("#iframe-calltoaction-" + calltoaction_id).html(getCallToActionMediaData(calltoaction_id));
      $("#iframe-calltoaction-" + calltoaction_id).removeClass("hidden");

      $("#calltoaction-" + calltoaction_id + "-cover").addClass("hidden");

    }

  };

  $window.showRegistrateView = function() {
    $("#registrate-modal").modal('show');
  };

  function animateInInteraction(interaction) {
    if(interaction.resource_type == "trivia") {
      time = 0;
      angular.forEach(interaction.resource.answers, function(answer) {
        $timeout(function() { 
          answer.class = "trivia-interaction__answer-slide-in";
        }, time);
        time += 300;
      });
    } else if(interaction.resource_type == "versus") {
      index = 0;
      angular.forEach(interaction.resource.answers, function(answer) {
        if(index % 2 == 0) {
          answer.class = "versus-interaction__answer-slide-in-left";
        } else {
          answer.class = "versus-interaction__answer-slide-in-right";
        }
        index += 1;
      });
    }
  }

  function executeInteraction(player, calltoaction_id, overvideo_interaction) { 
    $scope.overvideo_interaction_locked[calltoaction_id] = true;
    overvideo_interaction.interaction.overvideo_active = true;

    animateInInteraction(overvideo_interaction.interaction);

    player.pause();

    if(overvideo_interaction.user_interaction) {
      $timeout(function() { 
        removeOvervideoInteraction(player, calltoaction_id, overvideo_interaction);
      }, 3000);
    }
    // remove getOvervideoInteraction
  }

  function removeOvervideoInteraction(player, calltoaction_id, overvideo_interaction) {

    if(overvideo_interaction.interaction.resource_type == "trivia") {
      angular.forEach(overvideo_interaction.interaction.resource.answers, function(answer) {
        $timeout(function() { 
          answer.class = "trivia-interaction__answer--visible trivia-interaction__answer-slide-out";
        }, time);
        time += 300;
      });
    } else if(overvideo_interaction.interaction.resource_type == "versus") {
      index = 0;
      angular.forEach(overvideo_interaction.interaction.resource.answers, function(answer) {
        if(index % 2 == 0) {
          answer.class = "versus-interaction__answer--visible-left versus-interaction__answer-slide-out-left";
        } else {
          answer.class = "versus-interaction__answer--visible-right versus-interaction__answer-slide-out-right";
        }
        index += 1;
      });
    }

    $timeout(function() {
      if(overvideo_interaction.interaction.when_show_interaction == "OVERVIDEO_DURING") {
        player.play();
      }
      overvideo_interaction.interaction.overvideo_active = false;
      $timeout(function() { 

        $scope.overvideo_interaction_locked[calltoaction_id] = false; 
        angular.forEach(overvideo_interaction.interaction.resource.answers, function(answer) {
          answer.class = "";
        });

        if(overvideo_interaction.interaction.when_show_interaction == "OVERVIDEO_END") {
          getCallToActionInfo(calltoaction_id).active_end_interaction = true;//HERE
        }

      }, 1000);
    }, 2000);

  }

  // TODO: delete this, replaced in executeInteraction and removeOvervideoInteraction
  $window.getOvervideoInteraction = function(calltoaction_id, interaction_id, current_video_player, switch_to_main_video_after_ajax, when_show_interaction) { 
    $http.post("/get_overvideo_during_interaction", { interaction_id: interaction_id })
      .success(function(data) { 

        $("#home-overvideo-" + calltoaction_id).html(data.overvideo.toString());

        if(data.interaction_done_before && data.interaction_one_shot) {
          $timeout(function() { 

            if(when_show_interaction == "OVERVIDEO_DURING") {
              current_video_player.play(); 
              $("#home-overvideo-" + calltoaction_id).html("");
            }

            enableWaitingAudio("stop");

            // Unlock interaction
            $timeout(function() { $scope.overvideo_interaction_locked[calltoaction_id] = false; }, 2000);

          }, 5000);  
        } else {
          enableWaitingAudio("play");
        }                           

        if(switch_to_main_video_after_ajax) {
          $("#main-media-" + calltoaction_id).removeClass("hidden");
          $("#secondary-media-" + calltoaction_id).addClass("hidden");
        }

      }).error(function() {
        // ERROR.
      });
  };

  //////////////////////// YOUTUBE CALLBACK ////////////////////////
  
  function youtubePlayer(playerId, media_data) {
  	this.playerId = playerId;
  	this.media_data = media_data;
  	
	this.playerManager = new YT.Player( (this.playerId), {
        playerVars: { html5: 1, controls: 0, disablekb: 1, rel: 0, wmode: "transparent", showinfo: 0 },
        height: "100%", width: "100%",
        videoId: this.media_data,
        events: { 'onReady': onYouTubePlayerReady, 'onStateChange': onPlayerStateChange }
      });
  	
  	this.play = function(){
  		this.playerManager.playVideo();
  	};
  	
  	this.pause = function(){
  		this.playerManager.pauseVideo();
  	};
  	
  	this.seek = function(time){
  		this.playerManager.seekTo(time, true);
  	};
  };

  $window.onYouTubeIframeAPIReady = function() {
    $scope.youtube_api_ready = true;
    angular.forEach($scope.calltoactions, function(calltoaction_info) {
      appendYTIframe(calltoaction_info);
    });
  };

  $window.onYouTubePlayerReady = function(event) {
  };

  $window.onPlayerStateChange = function(newState) {  
    calltoaction_div_id = newState.target.getIframe().id;

    calltoaction_id = $("#" + calltoaction_div_id).attr("calltoaction-id");
    calltoaction_media_priority = $("#" + calltoaction_div_id).attr("main-media");

    if(calltoaction_media_priority == "main") {

      current_video_player = getPlayer(calltoaction_id);
      current_video_player_state = current_video_player.playerManager.getPlayerState();

      if(current_video_player_state == 1) {

        updateStartVideoInteraction(calltoaction_id);
        mayStartpolling(calltoaction_id);

      } else if(current_video_player_state == 0) {

        updateEndVideoInteraction(current_video_player, calltoaction_id);
        mayStopPolling();

      } else {
        // Other state.
      }
    } else {

      current_video_player = $scope.secondary_video_players[calltoaction_id]["player"];
      current_video_player_state = current_video_player.playerManager.getPlayerState();

      if(current_video_player_state == 0) {
        showCallToActionYTIframe(calltoaction_id);
      }
    }
  }; 
  
  //////////////////////// KALTURA CALLBACK ////////////////////////
  
  function kalturaPlayer(playerId, media_data) {
  	this.playerManager = null;
  	this.playerId = playerId;
  	this.media_data = media_data;

  	player = this;
	kWidget.embed({
		'targetId': this.playerId,
		'wid': '_'+$scope.aux.kaltura.partner_id,
		'uiconf_id' : $scope.aux.kaltura.uiconf_id,
		'entry_id' : media_data,
		'flashvars':{ // flashvars allows you to set runtime uiVar configuration overrides. 
			'autoPlay': false
		},
		'params':{ // params allows you to set flash embed params such as wmode, allowFullScreen etc
			'wmode': 'transparent' 
		},
		'readyCallback': function( playerId ){
			kdp = $("#"+playerId).get(0);
			kdp.addJsListener("playerReady", "onKalturaPlayerReady");
			kdp.addJsListener("doPlay", "onKalturaPlayEvent");
			kdp.addJsListener("playerUpdatePlayhead", "kalturaCheckInteraction");
			kdp.addJsListener("playerPlayEnd", "onKalturaVideoEnded");
			player.playerManager = kdp;
		}
   });
  	
  	this.play = function(){
  		this.playerManager.sendNotification('doPlay');
  	};
  	
  	this.pause = function(){
  		this.playerManager.sendNotification('doPause');
  	};
  	
  	this.seek = function(time){
  		this.playerManager.sendNotification('doSeek', time);
  	};
  };
  
  $window.initKalturaApi = function(){
  	if(typeof kWidget === 'undefined'){
  		setTimeout(initKalturaApi, 300);
  	}else{
		kalturaApiReady();
  	}
  };
 
  $window.kalturaApiReady = function() {
    $scope.kaltura_api_ready = true;
    angular.forEach($scope.calltoactions, function(calltoaction_info) {
      appendKalturaframe(calltoaction_info);
    });
  };

  $window.onKalturaPlayerReady = function(event) {
  };

  $window.onKalturaPlayEvent = function(idPlayer) {  
    aux = idPlayer.split("-");
    calltoaction_id = aux[aux.length - 1];
	
	// KALTURA replace div with calltoaction_media_priority info so 
	//secondary media dose not work with kaltura
	
    //if(calltoaction_media_priority == "main") {
	    updateStartVideoInteraction(calltoaction_id);

    //} else {
		//secondary media hendler
    //}
  };
  
  $window.onKalturaVideoEnded = function(idPlayer){
  	aux = idPlayer.split("-");
    calltoaction_id = aux[aux.length - 1];
    console.log($("#" + idPlayer));
    $scope.$apply(function() {
      updateEndVideoInteraction(calltoaction_id);
    });
  };
  
  $window.kalturaCheckInteraction = function(data, idPlayer) {
  	  //calltoaction_id = $("#" + idPlayer).attr("calltoaction-id");
  	  aux = idPlayer.split("-");
  	  calltoaction_id = aux[aux.length - 1];
      current_video_player = getPlayer(calltoaction_id);
      kaltura_player_current_time = Math.floor(data);
      
      overvideo_interaction = getOvervideoInteractionAtSeconds(calltoaction_id, kaltura_player_current_time);

      if(overvideo_interaction != null && !$scope.overvideo_interaction_locked[calltoaction_id]) {
        $scope.$apply(function(){
        	executeInteraction(current_video_player, calltoaction_id, overvideo_interaction);
        });
      }
  };
  
  $window.appendKalturaframe = function(calltoaction_info) {
    if(calltoaction_info.calltoaction.media_type == "KALTURA" && $scope.kaltura_api_ready) {
      
      player = new kalturaPlayer('main-media-iframe-' + calltoaction_info.calltoaction.id, calltoaction_info.calltoaction.media_data);
      calltoaction_info.calltoaction["player"] = player;

      $scope.play_event_tracked[calltoaction_info.calltoaction.id] = false;
      $scope.current_user_answer_response_correct[calltoaction_info.calltoaction.id] = false;

    }
  };
  
  //////////////////////// FLOWPLAYER API /////////////////////////////
  
  function flowplayerPlayer(playerId, media_data) {
  	this.playerManager = null;
  	this.playerId = playerId;
	  this.calltoaction_id = $("#" + playerId).attr("calltoaction-id");
  	this.media_data = media_data;
    if(this.calltoaction_id) {
      
  	  this.cuepoints = getOvervideoInteractions(this.calltoaction_id);
    	fplayer = this;
    	
  	  $("#"+playerId).flowplayer({
          playlist: [
             [
                { mp4: fplayer.media_data }
             ]
          ],
          swf: "/assets/flowplayer.swf",
          cuepoints: fplayer.cuepoints,
        }).bind("ready", function(e, api) {
       	  fplayer.playerManager = api; 	
        }).bind("resume", function(e, api) {
       	  calltoaction_id = $("#" + player.playerId).attr("calltoaction-id");
  	      calltoaction_media_priority = $("#" + player.playerId).attr("main-media");
    	    if(calltoaction_media_priority == "main") {
    	      updateStartVideoInteraction(calltoaction_id);
    	    } else {
    			  // SECONDARY MEDIA
    	    }    
        }).bind("cuepoint", function(e, api, cuepoint) {
          if(!$scope.overvideo_interaction_locked[calltoaction_id]) {
           	$scope.$apply(function() {
           		executeInteraction(fplayer, fplayer.calltoaction_id, cuepoint.interaction);
           	});
          }
      });
       
      this.play = function(){ this.playerManager.resume(); };
      this.pause = function(){ this.playerManager.pause(); };
    }
   
  }
  
  $window.flowplayerReady = function() {
    angular.forEach($scope.calltoactions, function(calltoaction_info) {
      appendFlowplayerframe(calltoaction_info);
    });
  };
  
  $window.appendFlowplayerframe = function(calltoaction_info) {
    if(calltoaction_info.calltoaction.media_type == "FLOWPLAYER") {
      
      player = new flowplayerPlayer('main-media-iframe-' + calltoaction_info.calltoaction.id, calltoaction_info.calltoaction.media_data);
      calltoaction_info.calltoaction["player"] = player;

      $scope.play_event_tracked[calltoaction_info.calltoaction.id] = false;
      $scope.current_user_answer_response_correct[calltoaction_info.calltoaction.id] = false;

    }
  };
  
  //////////////////////// METHODS FOR SETTINGS INTERACTIONS BEFORE AND END IN VIDEO ////////////////////////

  $window.updateEndVideoInteraction = function(calltoaction_id) {
    $scope.play_event_tracked[calltoaction_id] = false;
    interaction_info = getOvervideoEndInteractionInfo(calltoaction_id);//HERE
    if(interaction_info) {
      interaction_info.interaction.overvideo_active = true;
      animateInInteraction(interaction_info.interaction);
      if(interaction_info.user_interaction) {
        $timeout(function() { 
          removeOvervideoInteraction(null, calltoaction_id, interaction_info);
        }, 3000);
      }
    } else {
      getCallToActionInfo(calltoaction_id).active_end_interaction = true;
    }
  };

  $window.updateStartVideoInteraction = function(calltoaction_id, interaction_id) {
    if(!$scope.play_event_tracked[calltoaction_id]) {
      $("#home-overvideo-title-" + calltoaction_id).addClass("hidden");
      $scope.play_event_tracked[calltoaction_id] = true;

      play_interaction = getPlayInteraction(calltoaction_id);
      if(play_interaction == null) {
        console.log("You must enable the play interaction for this calltoaction.");
        return;
      }

      update_interaction_path = "/update_interaction"
      if($scope.aux.current_property_info && $scope.aux.current_property_info.title) {
        update_interaction_path = "/" + $scope.aux.current_property_info.title + "" + update_interaction_path;
      }

      $http.post(update_interaction_path, { interaction_id: play_interaction.id, main_reward_name: MAIN_REWARD_NAME })
        .success(function(data) {

          updateUserRewardInView(data.main_reward_counter.general);
    
          // GOOGLE ANALYTICS
          if(data.ga) {
            update_ga_event(data.ga.category, data.ga.action, data.ga.label, 1);
            angular.forEach(data.outcome.attributes.reward_name_to_counter, function(value, name) {
              update_ga_event("Reward", "UserReward", name.toLowerCase(), parseInt(value));
            });
          }

          // Update local storage for anonymous user.
          if(!$scope.current_user && $scope.aux.anonymous_interaction) {
            setAnonymousUserStorageAttr($scope.aux.main_reward_name, data.main_reward_counter.general);
            
            user_interaction_for_storage = new Object();
            user_interaction_for_storage.calltoaction_id = calltoaction_id;
            user_interaction_for_storage.interaction_id = interaction_id;
            user_interaction_for_storage.user_interaction = data.user_interaction;
  
            updateAnonymousUserStorageUserInteractions(user_interaction_for_storage);
          } 

          // Interaction after user response.
          updateUserInteraction(calltoaction_id, interaction_id, data.user_interaction);
          $scope.current_user.main_reward_counter = data.main_reward_counter;  
          interaction_info.status = data.interaction_status;

          /*

          interaction_point = data.outcome.attributes.reward_name_to_counter[MAIN_REWARD_NAME];
          if(interaction_point) {
            showAnimateFeedback(data.feedback, calltoaction_id);
            updateUserRewardInView(data.main_reward_counter.general);
          }

          if(data.call_to_action_completed) {
            showCallToActionCompletedFeedback(calltoaction_id);
          } else {
            updateCallToActionRewardCounter(calltoaction_id, data.winnable_reward_count);
          }

          */
          
        }).error(function() {
          // ERROR.
        });

    } else {
      // Button play already selected.
    }
  };

  //////////////////////// USER EVENTS METHODS ////////////////////////

  $scope.shareWith = function(calltoaction_info, interaction_info, provider) {

    if(interaction_info.user_interaction) {
      share_with_email_address = interaction_info.user_interaction.share_to_email;
      facebook_message = interaction_info.user_interaction.facebook_message;
    } else {
      share_with_email_address = null;
      facebook_message = null;
    }

    interaction_id = interaction_info.interaction.id;
    calltoaction_id = calltoaction_info.calltoaction.id;

    button = $("#" + provider + "-interaction-" + interaction_id);
    button.attr('disabled', true);
    current_button_html = button.html();
    button.html("condivisione in corso");

    $http.post("/update_interaction", { interaction_id: interaction_id, share_with_email_address: share_with_email_address, provider: provider, facebook_message: facebook_message })
      .success(function(data) {

        button.attr('disabled', false);
        button.html(current_button_html);

        if(!data.share.result) { 
          interaction_info.user_interaction.errors = data.share.exception;
          return;
        }

        updateUserInteraction(calltoaction_id, interaction_id, data.user_interaction);
        $scope.current_user.main_reward_counter = data.main_reward_counter;  
        interaction_info.status = data.interaction_status;

        $scope.aux.share_interaction_daily_done = true;

        $("#modal-interaction-" + interaction_id + "-" + provider).modal("hide");

        if(data.ga) {
          update_ga_event(data.ga.category, data.ga.action, data.ga.label);
          angular.forEach(data.outcome.attributes.reward_name_to_counter, function(value, name) {
            update_ga_event("Reward", "UserReward", name.toLowerCase(), parseInt(value));
          });
        }

      }).error(function() {
        // ERRORE
      });
  };

  $scope.updateAnswer = function(calltoaction_info, interaction_info, params, when_show_interaction) {

    if($scope.current_user || $scope.aux.anonymous_interaction) {

      calltoaction_id = calltoaction_info.calltoaction.id;
      interaction_id = interaction_info.interaction.id;

      enableWaitingAudio("stop");

      update_interaction_path = "/update_interaction"
      if($scope.aux.current_property_info && $scope.aux.current_property_info.title) {
        update_interaction_path = "/" + $scope.aux.current_property_info.title.toLowerCase() + "" + update_interaction_path;
      }
  	  
      $http.post(update_interaction_path, { interaction_id: interaction_id, params: params, aux: $scope.aux, anonymous_user: getAnonymousUserStorage() })
          .success(function(data) {

            updateUserRewardInView(data.main_reward_counter.general);
			
            // GOOGLE ANALYTICS
            if(data.ga) {
              update_ga_event(data.ga.category, data.ga.action, data.ga.label, 1);
              angular.forEach(data.outcome.attributes.reward_name_to_counter, function(value, name) {
                update_ga_event("Reward", "UserReward", name.toLowerCase(), parseInt(value));
              });
            }

            // HERE removeOvervideoInteraction

            // Update local storage for anonymous user.
            if(!$scope.current_user && $scope.aux.anonymous_interaction) {
              setAnonymousUserStorageAttr($scope.aux.main_reward_name, data.main_reward_counter.general);
              
              user_interaction_for_storage = new Object();
              user_interaction_for_storage.calltoaction_id = calltoaction_id;
              user_interaction_for_storage.interaction_id = interaction_id;
              user_interaction_for_storage.user_interaction = data.user_interaction;
    
              updateAnonymousUserStorageUserInteractions(user_interaction_for_storage);
            } 

            if(when_show_interaction == "OVERVIDEO_DURING" || when_show_interaction == "OVERVIDEO_END") {
              
              interaction_info.feedback = true;

              $timeout(function() { 
                interaction_info.feedback = false;

                if(interaction_info.interaction.resource_type == "trivia") {
                  angular.forEach(interaction_info.interaction.resource.answers, function(answer) {
                    answer.class = "trivia-interaction__answer--visible";
                  });
                } else if(interaction_info.interaction.resource_type == "versus") {
                  index = 0;
                  angular.forEach(interaction_info.interaction.resource.answers, function(answer) {
                    if(index % 2 == 0) {
                      answer.class = "versus-interaction__answer--visible-left";
                    } else {
                      answer.class = "versus-interaction__answer--visible-right";
                    }
                    index += 1;
                  });
                }

                $timeout(function() { 
                  removeOvervideoInteraction(getPlayer(calltoaction_id), calltoaction_id, interaction_info);
                }, 3000);
              }, 300000000000);

            } else {
              if(interaction_info.interaction.resource_type == "like") {
                if(JSON.parse(interaction_info.user_interaction.aux)["like"]) {
                  interaction_info.interaction.resource.like_info += 1;
                } else {
                  interaction_info.interaction.resource.like_info -= 1;
                } 
              }
            }

            // Interaction after user response.
            updateUserInteraction(calltoaction_id, interaction_id, data.user_interaction);
            calltoaction_info.status = JSON.parse(data.calltoaction_status);
            $scope.current_user.main_reward_counter = data.main_reward_counter;   

            if(data.answers) {
              updateAnswersInInteractionInfo(interaction_info, data.answers);
            }
            

            /*
            if(data.download_interaction_attachment) {
              window.open(data.download_interaction_attachment, '_blank');
            }

            if(data.answer) {
              $scope.current_user_answer_response_correct[calltoaction_id] = data.answer.correct;
            }
            
            if(when_show_interaction == "SEMPRE_VISIBILE") {

              userAnswerInAlwaysVisibleInteraction(interaction_id, data);
              if(data.have_answer_media) {
                userAnswerWithMedia(data.answer, calltoaction_id, interaction_id, when_show_interaction);
              }

            } else {

              if(data.have_answer_media) {
                userAnswerWithMedia(data.answer, calltoaction_id, interaction_id, when_show_interaction);
              } else {
                userAnswerWithoutMedia(data.answer, calltoaction_id, interaction_id, when_show_interaction);
              }

              if(when_show_interaction == "OVERVIDEO_DURING") {
                interaction_point = data.outcome.attributes.reward_name_to_counter[MAIN_REWARD_NAME];
                if(interaction_point) {
                  showAnimateFeedback(data.feedback, calltoaction_id);
                }
              }

            }

            if(data.call_to_action_completed) {
              showCallToActionCompletedFeedback(calltoaction_id);
            } else {
              updateCallToActionRewardCounter(calltoaction_id, data.winnable_reward_count);
            }
            */

          }).error(function() {
            // ERROR.
          });
          
    } else {

      showRegistrateView();

      $(".button-inter-" + interaction_id).attr('disabled', false);

    }
  };
  
  $window.updateVote = function(call_to_action_id, interaction_id, when_show_interaction){
  	var vote = $("#interaction-" + interaction_id + "-vote-value").val();
  	updateAnswer(call_to_action_id, interaction_id, vote, when_show_interaction);
  };

  //////////////////////// UPDATING VIEW METHODS AFTER USER INTERACTION ////////////////////////

  $window.userAnswerInAlwaysVisibleInteraction = function(interaction_id, data) {
    showMarkerNearInteraction(interaction_id);

    if(!$scope.current_user && $scope.aux.anonymous_interaction) {
      updateUserRewardInView(data.main_reward_counter);
    } else {
      updateUserRewardInView(data.main_reward_counter.general);
    }

    $("#home-undervideo-interaction-" + interaction_id).html(data.feedback); 
  };

  $window.userAnswerWithMedia = function(answer, calltoaction_id, interaction_id, when_show_interaction) {
    if(when_show_interaction == "OVERVIDEO_DURING") {
      $("#home-overvideo-" + calltoaction_id).html(""); 
    }

    $(".secondary-media").hide();

    $scope.secondary_video_players[calltoaction_id]["answer_selected_blocking"] = answer.blocking;
    $scope.secondary_video_players[calltoaction_id]["interaction_shown_in"] = when_show_interaction;
    $scope.secondary_video_players[calltoaction_id]["interaction_shown_id"] = interaction_id;

    if(answer.media_type == "YOUTUBE") {
      $("#secondary-media-video-" + calltoaction_id).show();

      appendOrUpdateYTIframeSecondary(calltoaction_id, answer.media_data);
      hideCallToActionYTIframe(calltoaction_id);
    } else if(answer.media_type == "IMAGE") {

      $("#secondary-media-image-" + calltoaction_id).attr("src", answer.media_image);
      $("#secondary-media-image-" + calltoaction_id).show();
      hideCallToActionYTIframe(calltoaction_id);

      $timeout(function() { showCallToActionYTIframe(calltoaction_id); }, 5000);

    }
  };

  $window.userAnswerWithoutMedia = function(answer, calltoaction_id, interaction_id, when_show_interaction) {
    current_video_player = getPlayer(calltoaction_id);
    getOvervideoInteraction(calltoaction_id, interaction_id, current_video_player, false, when_show_interaction);
    /*
    if(answer.blocking) {
      current_video_player = $scope.video_players[calltoaction_id];
      getOvervideoInteraction(calltoaction_id, interaction_id, current_video_player, false);
    } else {
      if(when_show_interaction == "OVERVIDEO_DURING") {
        $scope.video_players[calltoaction_id].playVideo(); 
        $("#home-overvideo-" + calltoaction_id).html(""); 
        $timeout(function() { $scope.overvideo_interaction_locked[calltoaction_id] = false; }, 2000);
      }
    }
    */
  };

  //////////////////////// SWITCHING MAIN MEDIA WITH SECONDARY MEDIA METHODS ////////////////////////

  $window.hideCallToActionYTIframe = function(calltoaction_id) {
    $("#main-media-" + calltoaction_id).addClass("hidden");
    $("#secondary-media-" + calltoaction_id).removeClass("hidden");
  };

  $window.showCallToActionYTIframe = function(calltoaction_id) {
    answer_selected_blocking = $scope.secondary_video_players[calltoaction_id]["answer_selected_blocking"];
    interaction_shown_in = $scope.secondary_video_players[calltoaction_id]["interaction_shown_in"];

    if(!answer_selected_blocking) { 
      $("#main-media-" + calltoaction_id).removeClass("hidden");
      $("#secondary-media-" + calltoaction_id).addClass("hidden");

      if(interaction_shown_in == "OVERVIDEO_DURING") {
        getPlayer(calltoaction_id).play();
      }

      $timeout(function() { $scope.overvideo_interaction_locked[calltoaction_id] = false; }, 2000);
    } else {
      interaction_shown_id = $scope.secondary_video_players[calltoaction_id]["interaction_shown_id"];
      current_video_player = getPlayer(calltoaction_id);
      getOvervideoInteraction(calltoaction_id, interaction_shown_id, current_video_player, true, interaction_shown_in);
    }
  };

  //////////////////////// POLLING METHODS ////////////////////////

  $window.mayStartpolling = function(calltoaction_id) {
    if(!$scope.polling && $scope.calltoactions_during_video_interactions_second[calltoaction_id]) {
      $scope.polling = $interval(videoPolling, 800);
    }
  };

  $window.mayStopPolling = function() { 
    if($scope.polling) {
      
      video_with_polling_counter = false;
      
      angular.forEach($scope.play_event_tracked, function(video_started, calltoaction_id) {
        if(video_started && $scope.calltoactions_during_video_interactions_second[calltoaction_id]) {
          video_with_polling_counter = true;
        } else {
          // This video has not polling.
        }
      });

      if(!video_with_polling_counter) {
        $interval.cancel($scope.polling);
        $scope.polling = false;
      } else {
        // There is almost one video with polling.
      }

    }
  };

  $window.videoPolling = function() {
    angular.forEach($scope.play_event_tracked, function(video_started, calltoaction_id) {
      if(getCallToActionInfo(calltoaction_id).calltoaction.media_type == "YOUTUBE"){
      	youtube_player = getPlayer(calltoaction_id);
      	youtube_player_current_time = Math.floor(youtube_player.playerManager.getCurrentTime()); 
      	overvideo_interaction = getOvervideoInteractionAtSeconds(calltoaction_id, youtube_player_current_time);

      	if(video_started && overvideo_interaction != null && !$scope.overvideo_interaction_locked[calltoaction_id]) {
        	executeInteraction(youtube_player, calltoaction_id, overvideo_interaction);
      	}
      }
    });
  };

  //////////////////////// AUDIO EFFECTS METHODS ////////////////////////
  
  $window.initClickAudio = function() {
    $("#click-audio").jPlayer({
      ready: function (event) {
        $(this).jPlayer("setMedia", {
          mp3: "/assets/click.mp3"
        });
      },
      ended: function() {
      },
      supplied: "mp3",
      volume: 0.4,
      smoothPlayBar: false,
      keyEnabled: false
    });
  };
  
  $window.enableClickAudio = function(status) {
    $("#click-audio").jPlayer(status);
  };
  
  $window.initRollAudio = function() {
    $("#roll-audio").jPlayer({
      ready: function (event) {
        $(this).jPlayer("setMedia", {
          mp3: "/assets/roll.mp3"
        });
      },
      ended: function() {
      	$(this).jPlayer("play");
      },
      supplied: "mp3",
      volume: 0.4,
      smoothPlayBar: false,
      keyEnabled: false
    });
  };
  
  $window.enableRollAudio = function(status) {
    $("#roll-audio").jPlayer(status);
  };
  
  $window.initBlinkAudio = function() {
    $("#blink-audio").jPlayer({
      ready: function (event) {
        $(this).jPlayer("setMedia", {
          mp3: "/assets/blink.mp3"
        });
      },
      ended: function() {
      },
      supplied: "mp3",
      volume: 0.4,
      smoothPlayBar: false,
      keyEnabled: false
    });
  };
  
  $window.enableBlinkAudio = function(status) {
    $("#blink-audio").jPlayer(status);
  };
  
  $window.initQuizWaitingAudio = function() {
    $("#quiz-waiting-audio").jPlayer({
      ready: function (event) {
        $(this).jPlayer("setMedia", {
          wav: WAITING_WAV_PATH
        });
      },
      ended: function() {
        $(this).jPlayer("play"); // Repeat the media.
      },
      supplied: "wav",
      volume: 0.4,
      smoothPlayBar: false,
      keyEnabled: false
    });
  };

  $window.enableWaitingAudio = function(status) {
    $("#quiz-waiting-audio").jPlayer(status);
  };

  //////////////////////// POINTS AND CHECKS FEEDBACK METHODS ////////////////////////

  $window.showAnimateFeedback = function(feedback, calltoaction_id) {
    $(".home-overvideo-feedback-" + calltoaction_id)
      .hide().html(feedback).show('slide', { direction: 'left' }, 2000);

    overvideo_feedback_timeout = $timeout(function() {
      $(".home-overvideo-feedback-" + calltoaction_id).hide('slide', { direction: 'left' }, 2000, function() {
        // TODO: after animation $(".home-overvideo-feedback-" + calltoaction_id).html("");
      });
    }, 4000);  
  };

  $window.showCallToActionCompletedFeedback = function(calltoaction_id) { 
    $("#head-feedback-calltoaction-" + calltoaction_id)
      .html("FATTO <span class=\"glyphicon glyphicon-ok\"></span>")
      .removeClass("label-warning").addClass("label-success");
  };

  $window.updateCallToActionRewardCounter = function(calltoaction_id, reward_counter) { 
    $("#head-feedback-calltoaction-" + calltoaction_id)
      .html("+" + reward_counter + " <span class=\"glyphicon glyphicon-star\"></span>");
  };

  $window.showMarkerNearInteraction = function(interaction_id) {
    $("#marker-" + interaction_id)
      .addClass("active")
      .html("<span class=\"glyphicon glyphicon-ok\"></span>");
  };

  $window.updateUserRewardInView = function(counter) {
    $scope.current_user.main_reward_counter.general = counter;
    //$(".user-reward-counter").html("+" + counter + " <span class=\"glyphicon glyphicon-star\"></span> punti");
  };

  //////////////////////// POINTS AND CHECKS FEEDBACK METHODS ////////////////////////

  function unevidenceComments(interaction_info) {
    /*
    $timeout.cancel($scope.interactions_timeout[interaction_info.interaction.id]);
    angular.forEach(interaction_info.interaction.resource.comment_info.comments, function(comment) {
      alert(JSON.stringify(comment));
      comment.evidence = false;
    });
    */
  }

  $scope.emptyUserComment = function(interaction_info) {
    user_text_from_interaction_info = interaction_info.interaction.resource.comment_info.user_text;
    return (!user_text_from_interaction_info || user_text_from_interaction_info.length < 1);
  };

  $scope.submitComment = function(interaction_info) {

    if($scope.emptyUserComment(interaction_info)) {
      return;
    }

    interaction_id = interaction_info.interaction.id;
    session_storage_captcha = sessionStorage["captcha" + interaction_id];

    $http.post("/add_comment", { interaction_id: interaction_id, comment_info: interaction_info.interaction.resource.comment_info, session_storage_captcha: session_storage_captcha })
      .success(function(data) {

        if(data.errors) {
          alert("ERROR");
        } else if(!$scope.current_user && !data.captcha_evaluate) {
          alert("CAPTCHA NON VALIDO");
          interaction_info.interaction.captcha = "data:image/jpeg;base64," + data.captcha.image;
          interaction_info.interaction.resource.comment_info.user_captcha = "";
          sessionStorage.setItem("captcha" + interaction_info.interaction.id, data.captcha.code);
        } else if(!data.approved) {
          alert("In attesa di approvazione!");
        } else {
          interaction_info.interaction.resource.comment_info.comments.unshift(data.comment);

          interaction_info.interaction.resource.comment_info.user_text = "";
          interaction_info.interaction.resource.comment_info.user_captcha = "";
          if(!$scope.current_user) {
            interaction_info.interaction.captcha = "data:image/jpeg;base64," + data.captcha.image;
          }
        }

      }).error(function() {
      });
  };

  // TODO: ajax_comment_append_in_progress

  $scope.appendComments = function(interaction_info) {
    if(!$scope.ajax_comment_append_in_progress) {
      interaction_id = interaction_info.interaction.id;
      comment_info = interaction_info.interaction.resource.comment_info;
      $scope.ajax_comment_append_in_progress = true;
      try {
        $http.post("/append_comments", { interaction_id: interaction_id, comment_info: comment_info })
          .success(function(data) {

            comment_info.comments = comment_info.comments.concat(data.comments);
            
            /*
            $scope.comments_shown = $scope.comments_shown.concat(data.comments_to_append_ids);

            $scope.comment.last_comment_shown_date = data.last_comment_shown_date;
            $("#comments-" + $scope.comment.interaction_id).append(data.comments_to_append);

            if($scope.comments_shown.length >= $scope.comment.comments_counter) {
              $("#comment-append-button-" + $scope.comment.interaction_id).hide();
            } 

            showNewCommentFeedback();    
            */
            
          }).error(function() {
          });
      } finally {
        $scope.ajax_comment_append_in_progress = false;
      }

    }
  };

  $scope.commentsPolling = function() {
    if(!$scope.ajax_comment_append_in_progress) {
      $scope.ajax_comment_append_in_progress = true;
      comment_info = $scope.comments_polling.interaction_info.interaction.resource.comment_info;
      interaction_info = $scope.comments_polling.interaction_info;
      interaction_id = $scope.comments_polling.interaction_info.interaction.id;
      try {
        $http.post("/comments_polling", { interaction_id: interaction_id, comment_info: comment_info })
          .success(function(data) {
            comment_info.comments = data.comments.concat(comment_info.comments);
            comment_info.comments_total_count = comment_info.comments_total_count + data.comments.length;
          }).error(function() {
          });
      } finally {
        $scope.ajax_comment_append_in_progress = false;
      }

    }
  };

  function initCaptcha() {
    interaction_info_list = getStreamCommentInteractions();
    if(interaction_info_list.length > 0) {
      $http.post("/captcha" , { interaction_info_list: getStreamCommentInteractions() })
        .success(function(data) { 
          initSessionStorageAndCaptchaImage(data)
        }).error(function() {
          // ERROR.
        });
    }
  }

  function initSessionStorageAndCaptchaImage(data_info_list) {
    angular.forEach(data_info_list, function(data) {
      data = JSON.parse(data);
      calltoaction_info = getCallToActionInfo(data.calltoaction_id);
      angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
        if(interaction_info.interaction.id == data.interaction_id) {
          interaction_info.interaction.captcha = "data:image/jpeg;base64," + data.captcha.image;
          sessionStorage.setItem("captcha" + interaction_info.interaction.id, data.captcha.code);
        }
      });
    });


  }

}