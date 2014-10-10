var streamCalltoactionModule = angular.module('StreamCalltoactionModule', ['ngRoute']);

StreamCalltoactionCtrl.$inject = ['$scope', '$window', '$http', '$timeout', '$interval'];
streamCalltoactionModule.controller('StreamCalltoactionCtrl', StreamCalltoactionCtrl);

// Gestione del csrf-token nelle chiamate ajax.
streamCalltoactionModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

function StreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval) {

  $scope.init = function(current_user, calltoactions, calltoactions_count, calltoactions_during_video_interactions_second, google_analytics_code, current_calltoaction) {

    $scope.video_players = {};
    $scope.video_player_during_video_interaction_locked = {};

    $scope.secondary_video_players = {};

    $scope.play_event_tracked = {};
    $scope.current_user_answer_response_correct = {};

    $scope.current_user = current_user;
    $scope.calltoactions = calltoactions;
    $scope.calltoactions_during_video_interactions_second = calltoactions_during_video_interactions_second;
    $scope.current_calltoaction = current_calltoaction;
    $scope.calltoactions_count = calltoactions_count;

    $scope.google_analytics_code = google_analytics_code;
    $scope.polling = false;
    $scope.youtube_api_ready = false;

    var tag = document.createElement('script');
    tag.src = "//www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

    initQuizWaitingAudio();

    updateSecondaryVideoPlayers($scope.calltoactions);

    $("#append-other button").attr('disabled', false);
    if($scope.calltoactions.length >= $scope.calltoactions_count) {
      $("#append-other button").hide();
    } else {
      $("#append-other button").show();
    }

  };

  $window.update_ga_event = function(category, action, label, value) {
    if($scope.google_analytics_code.length > 0) {
      ga('send', 'event', category, action, label, 100, true);
    }
  };

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

  $window.appendYTIframe = function(calltoaction) {
    if(calltoaction.media_type == "YOUTUBE" && $scope.youtube_api_ready) {
      $scope.video_players[calltoaction.id] = new YT.Player(('home-stream-video-' + calltoaction.id), {
        playerVars: { html5: 1 /* controls: 0, disablekb: 1, rel: 0, wmode: "transparent", showinfo: 0 */ },
        height: "100%", width: "100%",
        videoId: calltoaction.media_data,
        events: { 'onReady': onYouTubePlayerReady, 'onStateChange': onPlayerStateChange }
      });
      $scope.play_event_tracked[calltoaction.id] = false;
      $scope.current_user_answer_response_correct[calltoaction.id] = false;
    } else if(calltoaction.media_type == "IFRAME") {
      $scope.video_players[calltoaction.id] = calltoaction.media_data;
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

  $window.appendCallToAction = function() {
    if($scope.calltoactions.length < $scope.calltoactions_count) {

      $("#append-other button").attr('disabled', true);

      $http.post("/append_calltoaction", { calltoactions_showed: $scope.calltoactions, tag_id: $scope.current_tag_id, current_calltoaction: $scope.current_calltoaction  })
      .success(function(data) {

        hash_to_append = data.calltoactions_during_video_interactions_second;
        hash_main = $scope.calltoactions_during_video_interactions_second;
        for(var name in hash_to_append) { 
          hash_main[name] = hash_to_append[name]; 
        }
        $scope.calltoactions_during_video_interactions_second = hash_main;

        updateSecondaryVideoPlayers(data.calltoactions);

        angular.forEach(data.calltoactions, function(calltoaction) {
          $scope.calltoactions.push(calltoaction);
          appendYTIframe(calltoaction);
        });

        $scope.last_calltoaction_shown_activated_at = $scope.calltoactions[$scope.calltoactions.length - 1].activated_at;

        $("#calltoaction-stream").append(data.html_to_append);

        if($scope.calltoactions.length >= $scope.calltoactions_count) {
          $("#append-other button").hide();
        }

        $("#append-other button").attr('disabled', false);

      });
      
    } else {
      $("#append-other").remove();
    }
    
  };

  $window.updateYTIframe = function(calltoaction_video_code, calltoaction_id, autoplay) {
    current_video_player = $scope.video_players[calltoaction_id];
    if($scope.youtube_api_ready && current_video_player) {
      $scope.play_event_tracked[calltoaction_id] = false;
      if(autoplay) {
        current_video_player.loadVideoById(calltoaction_video_code);
      } else {
        current_video_player.cueVideoById(calltoaction_video_code);
      }
    }
  };

  //////////////////////// SHOWING AND GETTING INTERACTION METHODS ////////////////////////

  $window.showRegistrateView = function() {
    $("#registrate-modal").modal('show');
  };

  $window.executeInteraction = function(calltoaction_id, second, calltoaction_interacations) { 
    angular.forEach(calltoaction_interacations, function(interaction_second, interaction_id) {
      if(second == interaction_second) {
        $scope.video_player_during_video_interaction_locked[calltoaction_id] = true;
        current_video_player = $scope.video_players[calltoaction_id];
        current_video_player.pauseVideo();
        getOvervideoInteraction(calltoaction_id, interaction_id, current_video_player, false, "OVERVIDEO_DURING");
      }
    });
  };

  $window.getOvervideoInteraction = function(calltoaction_id, interaction_id, current_video_player, switch_to_main_video_after_ajax, when_show_interaction) { 
    $http.post("/get_overvideo_during_interaction", { interaction_id: interaction_id })
      .success(function(data) { 

        $("#home-overvideo-" + calltoaction_id).html(data.overvideo.toString());

        if(data.interaction_done_before && data.interaction_one_shot) {
          $timeout(function() { 

            if(when_show_interaction == "OVERVIDEO_DURING") {
              current_video_player.playVideo(); 
              $("#home-overvideo-" + calltoaction_id).html("");
            }

            enableWaitingAudio("stop");

            // Unlock interaction
            $timeout(function() { $scope.video_player_during_video_interaction_locked[calltoaction_id] = false; }, 2000);

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

  $window.onYouTubeIframeAPIReady = function() {
    $scope.youtube_api_ready = true;
    angular.forEach($scope.calltoactions, function(sc) {
      appendYTIframe(sc);
    });
  };

  $window.onYouTubePlayerReady = function(event) {
  };

  $window.onPlayerStateChange = function(newState) {  
    key = newState.target.getIframe().id;

    calltoaction_id = $("#" + key).attr("calltoaction-id");
    main_calltoaction_media = ($("#" + key).attr("main-calltoaction-media") == "true");

    if(main_calltoaction_media) {

      current_video_player = $scope.video_players[calltoaction_id];
      current_video_player_state = current_video_player.getPlayerState();

      if(current_video_player_state == 1) {

        interaction_id = $("#" + key).attr("interaction-play-id");
        updateStartVideoInteraction(calltoaction_id, interaction_id);

        mayStartPooling(calltoaction_id);

      } else if(current_video_player_state == 0) {

        updateEndVideoInteraction(calltoaction_id);
        mayStopPolling();

      } else {
        // Other state.
      }
    } else {

      current_video_player = $scope.secondary_video_players[calltoaction_id]["player"];
      current_video_player_state = current_video_player.getPlayerState();

      if(current_video_player_state == 0) {
        showCallToActionYTIframe(calltoaction_id);
      }
    }
  }; 

  //////////////////////// METHODS FOR SETTINGS INTERACTIONS BEFORE AND END IN VIDEO ////////////////////////

  $window.updateEndVideoInteraction = function(calltoaction_id) {
    $scope.play_event_tracked[calltoaction_id] = false;
    $http.post("/calltoaction_overvideo_end", { calltoaction_id: calltoaction_id, right_answer_response: $scope.current_user_answer_response_correct[key] })
      .success(function(data) {
        $("#home-overvideo-" + calltoaction_id).html(data.overvideo);
      }).error(function() {
        // ERROR.
      });
  };

  $window.updateStartVideoInteraction = function(calltoaction_id, interaction_id) {
    if(!$scope.play_event_tracked[calltoaction_id]) {
      $("#home-overvideo-title-" + calltoaction_id).addClass("hidden");
      $scope.play_event_tracked[calltoaction_id] = true;

      $http.post("/update_interaction", { interaction_id: interaction_id, main_reward_name: MAIN_REWARD_NAME })
        .success(function(data) {

          if(data.ga) {
            update_ga_event(data.ga.category, data.ga.action, data.ga.label);
            angular.forEach(data.outcome.attributes.reward_name_to_counter, function(value, name) {
              update_ga_event("Reward", "UserReward", name.toLowerCase(), parseInt(value));
            });
          }

          interaction_point = data.outcome.attributes.reward_name_to_counter[MAIN_REWARD_NAME];
          if(interaction_point) {
            showAnimateFeedback(data.feedback, calltoaction_id);
            updateUserRewardInView(data.main_reward_counter);
          }

          if(data.call_to_action_completed) {
            showCallToActionCompletedFeedback(calltoaction_id);
          } else {
            updateCallToActionRewardCounter(calltoaction_id, data.winnable_reward_count);
          }
          
        }).error(function() {
          // ERROR.
        });

    } else {
      // Button play already selected.
    }
  };

  //////////////////////// USER EVENTS METHODS ////////////////////////

  $window.shareWith = function(interaction_id, provider) {

    button = $("#" + provider + "-interaction-" + interaction_id);

    button.attr('disabled', true);
    button_main_content = button.html();
    button.html("<img src=\"/assets/loading.gif\" style=\"width: 15px;\">");

    share_with_email_address = $("#address-interaction-" + interaction_id).val();

    $http.post("/update_interaction", { interaction_id: interaction_id, main_reward_name: MAIN_REWARD_NAME, share_with_email_address: share_with_email_address, provider: provider })
          .success(function(data) {

          button.attr('disabled', false);
          button.html(button_main_content);

          if(provider == "email") {
            $("#address-interaction-" + interaction_id).val();
          } 

          if(!data.share.result) {
            alert(data.share.exception);
          } else {
            if(data.ga) {
              update_ga_event(data.ga.category, data.ga.action, data.ga.label);
              angular.forEach(data.outcome.attributes.reward_name_to_counter, function(value, name) {
                update_ga_event("Reward", "UserReward", name.toLowerCase(), parseInt(value));
              });
            }
          }

      }).error(function() {
        // ERRORE
      });
  };

  $window.updateAnswer = function(calltoaction_id, interaction_id, params, when_show_interaction) {
    if($scope.current_user) {

      $(".button-inter-" + interaction_id).attr('disabled', true);
      $(".button-inter-" + interaction_id).attr('onclick', "");

      enableWaitingAudio("stop");
	  //$("#waiting-registration-layer").removeClass("hidden");
	  $("#fountainG").removeClass("hidden");
	  
      $http.post("/update_interaction", { interaction_id: interaction_id, params: params, main_reward_name: MAIN_REWARD_NAME })
          .success(function(data) {
			
            if(data.ga) {
              update_ga_event(data.ga.category, data.ga.action, data.ga.label, 1);
              angular.forEach(data.outcome.attributes.reward_name_to_counter, function(value, name) {
                update_ga_event("Reward", "UserReward", name.toLowerCase(), parseInt(value));
              });
            }

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

          }).error(function() {
            // ERROR.
          });
          
    } else {

      showRegistrateView();

      $(".button-inter-" + interaction_id).attr('disabled', false);

    }
  };
  
  $window.updateVote = function(call_to_action_id, interaction_id, when_show_interaction){
  	var vote = $("#interaction-"+interaction_id+"-vote-value").val();
  	updateAnswer(call_to_action_id, interaction_id, vote, when_show_interaction);
  };

  //////////////////////// UPDATING VIEW METHODS AFTER USER INTERACTION ////////////////////////

  $window.userAnswerInAlwaysVisibleInteraction = function(interaction_id, data) {
    showMarkerNearInteraction(interaction_id);
    updateUserRewardInView(data.main_reward_counter);

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
    current_video_player = $scope.video_players[calltoaction_id];
    getOvervideoInteraction(calltoaction_id, interaction_id, current_video_player, false, when_show_interaction);
    /*
    if(answer.blocking) {
      current_video_player = $scope.video_players[calltoaction_id];
      getOvervideoInteraction(calltoaction_id, interaction_id, current_video_player, false);
    } else {
      if(when_show_interaction == "OVERVIDEO_DURING") {
        $scope.video_players[calltoaction_id].playVideo(); 
        $("#home-overvideo-" + calltoaction_id).html(""); 
        $timeout(function() { $scope.video_player_during_video_interaction_locked[calltoaction_id] = false; }, 2000);
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
        $scope.video_players[calltoaction_id].playVideo();
      }

      $timeout(function() { $scope.video_player_during_video_interaction_locked[calltoaction_id] = false; }, 2000);
    } else {
      interaction_shown_id = $scope.secondary_video_players[calltoaction_id]["interaction_shown_id"];
      current_video_player = $scope.video_players[calltoaction_id];
      getOvervideoInteraction(calltoaction_id, interaction_shown_id, current_video_player, true, interaction_shown_in);
    }
  };

  //////////////////////// POLLING METHODS ////////////////////////

  $window.mayStartPooling = function(calltoaction_id) {
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
      if(video_started && $scope.calltoactions_during_video_interactions_second[calltoaction_id]) {
        current_video_player = $scope.video_players[calltoaction_id];
        current_video_player_time = current_video_player.getCurrentTime(); 
        current_video_player_second = Math.floor(current_video_player_time);
        if(!$scope.video_player_during_video_interaction_locked[calltoaction_id]) {
          executeInteraction(calltoaction_id, current_video_player_second, $scope.calltoactions_during_video_interactions_second[calltoaction_id]);
        }
      }
    });
  };

  //////////////////////// AUDIO EFFECTS METHODS ////////////////////////

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
    $(".user-reward-counter").html("+" + counter + " PUNTI");
  };

}