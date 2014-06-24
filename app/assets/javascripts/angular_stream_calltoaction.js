var streamCalltoactionApp = angular.module('StreamCalltoactionApp', ['ngRoute']);

StreamCalltoactionCtrl.$inject = ['$scope', '$window', '$http', '$timeout', '$interval'];
streamCalltoactionApp.controller('StreamCalltoactionCtrl', StreamCalltoactionCtrl);

// Gestione del csrf-token nelle chiamate ajax.
streamCalltoactionApp.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

function StreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval) {

  var video_player = {};
  var video_player_during_video_interaction_locked = {};
  var play_event_tracked = {};
  var user_response_right = {};

  var polling = false;

  // Inizializzazione dello scope.
  $scope.init = function(current_user, calltoactions, calltoactions_count, calltoactions_during_video_interactions_second) {

    $scope.current_user = current_user;
    $scope.calltoactions = calltoactions;

    $scope.calltoaction_offset = calltoactions.length;
    $scope.calltoactions_count = calltoactions_count;

    $scope.calltoactions_during_video_interactions_second = calltoactions_during_video_interactions_second;

    $scope.youtube_api_ready = false;

    var tag = document.createElement('script');
    tag.src = "//www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
  }; // init

  $window.onYouTubeIframeAPIReady = function() {
    $scope.youtube_api_ready = true;
    angular.forEach($scope.calltoactions, function(sc) {
      appendYTIframe(sc);
    });
  }; // onYouTubeIframeAPIReady

  $window.appendYTIframe = function(calltoaction) {
    if(calltoaction.media_type == "VIDEO" && $scope.youtube_api_ready) {
      video_player[calltoaction.id] = new YT.Player(('home-stream-video-' + calltoaction.id), {
        playerVars: { }, // controls: 0, disablekb: 1, rel: 0, wmode: "transparent", showinfo: 0
        height: "100%", width: "100%",
        allowfullscreen: false,
        videoId: calltoaction.video_url,
        events: { 'onReady': onYouTubePlayerReady, 'onStateChange': onPlayerStateChange }
      });
      play_event_tracked[calltoaction.id] = false;
      user_response_right[calltoaction.id] = false;
    }
  };

  $window.appendCalltoaction = function(type) {
    if($scope.calltoactions_count > $scope.calltoaction_offset) {
      $("#append-other button").attr('disabled', true);
      $http.post("/append_calltoaction", { offset: $scope.calltoaction_offset, type: type })
      .success(function(data) {
        $scope.calltoaction_offset = $scope.calltoaction_offset + data.calltoactions.length
        $scope.calltoactions.push(data.calltoactions);
        $("#calltoaction-stream").append(data.html_to_append);

        if(!($scope.calltoactions_count > $scope.calltoaction_offset))
          $("#append-other").remove();

        angular.forEach(data.calltoactions, function(sc) {
          appendYTIframe(sc);
        });

        $("#append-other button").attr('disabled', false);
      });
    } else {
      $("#append-other").remove();
    }
  };

  $window.updateYTIframe = function(calltoaction_video_code, calltoaction_id, autoplay) {
    current_video_player = getVideoPlayerFromCallToAction(calltoaction_id);
    if($scope.youtube_api_ready && current_video_player) {
      if(autoplay) {
        current_video_player.loadVideoById(calltoaction_video_code);
      } else {
        current_video_player.cueVideoById(calltoaction_video_code);
        play_event_tracked[calltoaction_id] = false;
      }
    }
  }

  $window.onYouTubePlayerReady = function(event) {
  };

  $window.onPlayerStateChange = function(newState) {  
    key = newState.target.getIframe().id;
    calltoaction_id = $("#" + key).attr("main-calltoaction-id");

    var current_video_player = getVideoPlayerFromCallToAction(calltoaction_id);
    var current_video_player_state = current_video_player.getPlayerState();

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
  }; 

  $window.mayStartPooling = function(calltoaction_id) {
    if(!polling && $scope.calltoactions_during_video_interactions_second[calltoaction_id]) {
      polling = $interval(videoPolling, 800);
    }
  }

  $window.mayStopPolling = function() { 
    if(polling) {
      
      video_with_polling_counter = false;
      
      angular.forEach(play_event_tracked, function(video_started, calltoaction_id) {
        if(video_started && $scope.calltoactions_during_video_interactions_second[calltoaction_id]) {
          video_with_polling_counter = true;
        } else {
          // This video has not pooling.
        }
      });

      if(!video_with_polling_counter) {
        $interval.cancel(polling);
        polling = false;
      } else {
        // There is almost one video with polling.
      }

    }
  }

  $window.videoPolling = function() {
    console.log("POLLING");
    angular.forEach(play_event_tracked, function(video_started, calltoaction_id) {
      if(video_started && $scope.calltoactions_during_video_interactions_second[calltoaction_id]) {
        current_video_player = getVideoPlayerFromCallToAction(calltoaction_id);
        current_video_player_time = current_video_player.getCurrentTime(); 
        current_video_player_second = Math.floor(current_video_player_time);
        if(!video_player_during_video_interaction_locked[calltoaction_id]) {
          executeInteraction(calltoaction_id, current_video_player_second, $scope.calltoactions_during_video_interactions_second[calltoaction_id]);
        }
      }
    });
  };

  $window.executeInteraction = function(calltoaction_id, second, calltoaction_interacations) { 
    angular.forEach(calltoaction_interacations, function(interaction_second, interaction_id) {
      if(second == interaction_second) {
        video_player_during_video_interaction_locked[calltoaction_id] = true;
        current_video_player = getVideoPlayerFromCallToAction(calltoaction_id);
        current_video_player.pauseVideo();
        $http.post("/get_overvideo_during_interaction", { interaction_id: interaction_id })
          .success(function(data) {  
            $("#home-overvideo-" + calltoaction_id).html(data.overvideo); 
            if(data.interaction_done_before) {
              $timeout(function() { 
                current_video_player.playVideo(); 
                $("#home-overvideo-" + calltoaction_id).html("");
              }, 3000);  
            } else {
              // Waiting for current user response.
            }                           
          }).error(function() {
            // Errore nella richiesta dell'interaction.
          });
      }
    });
  }; // launchInteraction

  $window.updateEndVideoInteraction = function(calltoaction_id) {
    play_event_tracked[calltoaction_id] = false;
    $http.post("/calltoaction_overvideo_end", { calltoaction_id: calltoaction_id, right_answer_response: user_response_right[key] })
      .success(function(data) {
        $("#home-overvideo-" + calltoaction_id).html(data);
      }).error(function() {
        // ERROR.
      });
  }

  $window.updateStartVideoInteraction = function(calltoaction_id, interaction_id) {
    if(!play_event_tracked[calltoaction_id]) {
      $("#home-overvideo-title-" + calltoaction_id).addClass("hidden");
      play_event_tracked[calltoaction_id] = true;

      $http.post("/update_interaction", { interaction_id: interaction_id })
        .success(function(data) {
          // TODO: interaction feedback.
        }).error(function() {
          // ERROR.
        });

    } else {
      // Button play already selected.
    }
  }

  $window.shareWith = function(provider, interaction_id, calltoaction_id) {

    $("#share-" + provider + "-" + interaction_id).attr('disabled', true); // Modifico lo stato del bottone.
    $("#share-" + provider + "-" + interaction_id).html("<img src=\"/assets/loading.gif\" style=\"width: 15px;\">");

    $http.post("/user_event/share/" + provider, { interaction_id: interaction_id, share_email_address: $("#share-email-address-" + interaction_id).val() })
      .success(function(data) {
        // Modifico lo stato del bottone e notifico la condivisione.
        $("#share-" + provider + "-" + interaction_id).attr('disabled', false); // Modifico lo stato del bottone.
        $("#share-" + provider + "-" + interaction_id).html("CONDIVIDI CON " + provider.toUpperCase());

        $(".current_user_points").html(data.points_updated);

        $("#share-modal-" + calltoaction_id).modal("hide");

        if(provider == "email") {
          $("#share-email-address-" + interaction_id).val("");
          $("#share-" + provider + "-" + interaction_id).html("CONDIVIDI");

          if(data.email_correct) {
            $("#share-" + calltoaction_id).addClass("btn-success");
            $("#share-" + calltoaction_id).html("<span class=\"glyphicon glyphicon-ok\"></span>");
          } else {
            $("#invalid-email-modal").modal("show"); 
          }

        } else {
          $("#share-" + calltoaction_id).addClass("btn-success");
          $("#share-" + calltoaction_id).html("<span class=\"glyphicon glyphicon-ok\"></span>");
        }

        if(data.calltoaction_complete) {
          $("#circle-calltoaction-done-" + calltoaction_id).removeClass("hidden");
        }

        if(data.undervideo_share_feedback) {
          $("#share-mobile-feedback-" + calltoaction_id).html(data.undervideo_share_feedback);
        } 

      }).error(function() {
        // ERRORE
      });
  };

  $window.updateTriviaAnswer = function(calltoaction_id, interaction_id, answer_id, overvideo_during = false) {
    if($scope.current_user) {
      $(".button-inter-" + interaction_id).attr('disabled', true);
      $http.post("/update_interaction", { interaction_id: interaction_id, answer_id: answer_id })
          .success(function(data) {

            $(".button-inter-" + interaction_id).attr('disabled', false);
            $(".button-inter-" + interaction_id).removeAttr('onclick');

            if(data.next_call_to_action) {
              updateNextCallToAction(data.next_call_to_action, calltoaction_id)
            } else {
              // Simple calltoaction without next calltoaction.
            }

            user_response_right[key] = data.right_answer_response;

            if(overvideo_during) {
              getVideoPlayerFromCallToAction(calltoaction_id).playVideo(); 
              $("#home-overvideo-" + calltoaction_id).html(""); 
              $timeout(function() { video_player_during_video_interaction_locked[calltoaction_id] = false; }, 2000);
            }

          }).error(function() {
            // ERROR.
          });
    } else {
      $("#registrate-modal").modal('show');
      $(".button-inter-" + interaction_id).attr('disabled', false);
    }
  };

  $window.getVideoPlayerFromCallToAction = function(calltoaction_id) {
    return video_player[calltoaction_id];
  }

  $window.updateHtmlYoutubePlayerInfo = function(youtube_html_element, calltoaction_id, interaction_play_id) {
    youtube_html_element
      .attr("secondary-calltoaction-id", calltoaction_id)
      .attr("interaction-play-id", interaction_play_id);
  };

  $window.updateNextCallToAction = function(next_call_to_action, calltoaction_id) {
    key = 'home-stream-video-' + calltoaction_id;

    updateHtmlYoutubePlayerInfo($("#" + key), next_call_to_action.call_to_action_id, next_call_to_action.interaction_play_id);
    updateYTIframe(next_call_to_action.video_url, calltoaction_id, true);

    $("#home-overvideo-" + calltoaction_id).html("");
  }

}