var streamCalltoactionApp = angular.module('StreamCalltoactionApp', ['ngRoute']);

StreamCalltoactionCtrl.$inject = ['$scope', '$window', '$http', '$timeout'];
streamCalltoactionApp.controller('StreamCalltoactionCtrl', StreamCalltoactionCtrl);

// Gestione del csrf-token nelle chiamate ajax.
streamCalltoactionApp.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

function StreamCalltoactionCtrl($scope, $window, $http, $timeout) {

  var ytplayer_hash = {};
  var playpressed_hash = {};
  var correctytplayer_hash = {};

  var overvideo_feedback_timeout;

  // Inizializzazione dello scope.
  $scope.init = function(current_user, calltoaction_video_code, calltoaction_id) {
    $scope.current_user = current_user;
    $scope.calltoaction_video_code = calltoaction_video_code;
    $scope.calltoaction_id = calltoaction_id;

    $scope.youtube_api_ready = false;

    var tag = document.createElement('script');
    tag.src = "//www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
  }; // init

  $window.onYouTubeIframeAPIReady = function() {
    $scope.youtube_api_ready = true;
    createYTIframe($scope.calltoaction_video_code, $scope.calltoaction_id, false);
  }; // onYouTubeIframeAPIReady

  $window.createYTIframe = function(calltoaction_video_code, calltoaction_id) {
    if($scope.youtube_api_ready) {
      key = 'home-video';
      ytplayer_hash[key] = new YT.Player(key, {
        playerVars: { controls: 0, disablekb: 1, rel: 0, wmode: "transparent", showinfo: 0 },
        width: "100%",
        videoId: calltoaction_video_code,
        events: { 'onReady': onYouTubePlayerReady, 'onStateChange': onPlayerStateChange }
      });
      playpressed_hash[key] = false;
      correctytplayer_hash[key] = false;
    }
  };

  $window.updateYTIframeAfterResponse = function(calltoaction_video_code) {
    key = 'home-video';
    if($scope.youtube_api_ready && ytplayer_hash[key]) {
      $("#home-overvideo").html("");
      playpressed_hash[key] = false;
      ytplayer_hash[key].loadVideoById(calltoaction_video_code); 
    }
  };

  $window.updateYTIframe = function(calltoaction_video_code, calltoaction_id, index, type, active) {
    key = 'home-video';
    if($scope.youtube_api_ready && ytplayer_hash[key] && active) {
      $http.post("/update_calltoaction_content", { id: calltoaction_id, index: index, type: type })
        .success(function(data) {
          $scope.calltoaction_id = calltoaction_id;
          $scope.calltoaction_video_code = calltoaction_video_code;

          $("#yt-hidden").css("display", "none");
          $("#home-video").attr("iid", "calltoaction-active-" + calltoaction_id);

          $("#share-footer").html(data.share_content);
          $("#home-overvideo-title").html(data.overvideo_title)

          $("#home-overvideo").html("");

          $(".home-carousel-li").removeClass("active");
          $("#home-carousel-li-" + calltoaction_id).addClass("active");

          if(type != "extra") {
            $(".home-carousel-circle-children").removeClass("active");
            $("#home-carousel-circle-children-" + calltoaction_id).addClass("active");
          }

          flushTimeoutFeedback(); // When I change video and a Timout is running.

          $(".panel-carousel").removeClass("panel-default").removeClass("panel-inactive").addClass("panel-inactive");
          $("#panel-carousel-" + calltoaction_id).removeClass("panel-inactive").addClass("panel-default");

          correctytplayer_hash[key] = false;
          playpressed_hash[key] = false;

          ytplayer_hash[key].cueVideoById(calltoaction_video_code);
          //ytplayer_hash[key].loadVideoById($scope.calltoaction_video_code);    

        }).error(function() {
          // Error.
        });
    }
  };

  $window.restartYTVideo = function() {          
    key = 'home-video';

    $("#home-video").attr("iid", "calltoaction-active-" + $scope.calltoaction_id );
    $("#home-overvideo").html("");

    flushTimeoutFeedback(); // When I change video and a Timout is running.

    correctytplayer_hash[key] = false;
    playpressed_hash[key] = false;

    ytplayer_hash[key].loadVideoById($scope.calltoaction_video_code );
  }

  $window.onYouTubePlayerReady = function(event) {
  }; // onYouTubePlayerReady

  $window.flushTimeoutFeedback = function() {

    $("#quiz-waiting-audio").jPlayer("stop");
    
    $timeout.cancel(overvideo_feedback_timeout);
    $("#home-overvideo-feedback-points").html("");
  }; // onYouTubePlayerReady

  
  $window.showFeedbackPoints = function(feedback) {
    $("#home-overvideo-feedback-points").hide();
    $("#home-overvideo-feedback-points").html(feedback);

    $("#home-overvideo-feedback-points").show('slide', { direction: 'left' }, 1000);
    overvideo_feedback_timeout = $timeout(function() {
      $("#home-overvideo-feedback-points").hide('slide', { direction: 'left' }, 1000, function() {
        $("#home-overvideo-feedback-points").html("");
      });
    }, 4000);  
  }; // onYouTubePlayerReady

  // Callback chiamata quando lo stato del video viene modificato.
  $window.onPlayerStateChange = function(newState) {  
    key = newState.target.getIframe().id;
    calltoactionactive = $("#" + key).attr("iid");

    ytplayer = ytplayer_hash[key];
      player_state = ytplayer.getPlayerState();
      if(player_state == 1) { // Lo stato 1 corrisponde al video in riproduzione.
      // Identifico il PLAY del video in modo da poter tracciare l'evento.          
        if(!playpressed_hash[key]) {
          $http.post("/update_play_interaction.json", { calltoaction_id: calltoactionactive.replace("calltoaction-active-", "") })
            .success(function(data) {

              // OVERVIDEO FEEDBACK POINTS.
              if(data.overvideo_feedback) {
                $(".current_user_points").html(data.points_updated);

                showFeedbackPoints(data.overvideo_feedback);
              } 

              // UPDATE CAROUSEL BADGE.
              if(data.calltoaction_complete) {
                $("#calltoaction-item-carousel-" + $scope.calltoaction_id).removeClass("hidden");
              }

              $("#yt-hidden").css("display", "block");
              $("#home-overvideo-title").html(""); // REMOVE TITLE LAYER.        
            }).error(function() {
              // ERROR.
            });
            playpressed_hash[key] = true;
          }
      } else if(player_state == 0){
        playpressed_hash[key] = false;
        $http.post("/calltoaction_overvideo_end", { id: $scope.calltoaction_id, end: correctytplayer_hash[key], type: $("#" + key).attr("type") })
          .success(function(data) {
            if(!correctytplayer_hash[key]) {
              $("#quiz-waiting-audio").jPlayer("play");
            }
            $("#home-overvideo").html(data);
          });
      }
  }; // onPlayerStateChange

  $window.shareWith = function(provider, interaction_id, calltoaction_id) {

    $("#share-" + provider + "-" + interaction_id).attr('disabled', true); // Modifico lo stato del bottone.
    $("#share-" + provider + "-" + interaction_id).html("<img src=\"/assets/loading.gif\" style=\"width: 15px;\">");

    $http.post("/user_event/share/" + provider, { interaction_id: interaction_id, share_email_address: $("#share-email-address-" + interaction_id).val() })
      .success(function(data) {
        $(".current_user_points").html(data.points_updated);

        // Modifico lo stato del bottone e notifico la condivisione.
        $("#share-" + provider + "-" + interaction_id).attr('disabled', false); // Modifico lo stato del bottone.
        $("#share-" + provider + "-" + interaction_id).html("CONDIVIDI CON " + provider.toUpperCase());

        $("#share-modal-" + calltoaction_id).modal("hide");

        $(".share-footer-feedback").removeClass("hidden").addClass("hidden");
        $("#share-footer-feedback-done").removeClass("hidden");

        if(data.points_for_user) {
          $("#share-footer-label").html("Hai guadagnato +" + data.points_for_user + " Gratta&Vinci");
        }

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
          $("#calltoaction-item-carousel-" + $scope.calltoaction_id).removeClass("hidden");
        }

      }).error(function() {
        // ERRORE
      });
  };

  $window.updateTriviaAnswer = function(interaction_id, answer_id) {
    $(".button-inter-" + interaction_id).attr('disabled', true);
    
    $("#quiz-waiting-audio").jPlayer("stop");
    $("#quiz-answer-selected-audio").jPlayer("play");

    if($scope.current_user) {
      $http.post("/user_event/update_answer.json", { interaction_id: interaction_id, answer_id: answer_id })
          .success(function(data) {
            // Non permetto di selezionare nuovamente la risposta.
            $(".button-inter-" + interaction_id).attr('disabled', false);
            $(".button-inter-" + interaction_id).removeAttr('onclick');

            if(data.next_calltoaction) {
              key = 'home-video'; $("#" + key).attr("iid", "calltoaction-active-" + data.next_calltoaction["id"]);
              updateYTIframeAfterResponse(data.next_calltoaction["video_url"], $scope.calltoaction_id);
              $("#home-overvideo").html("");
            }

            // OVERVIDEO FEEDBACK POINTS
            if(data.overvideo_feedback) {
              $(".current_user_points").html(data.points_updated);
              showFeedbackPoints(data.overvideo_feedback);
            } 

            if(data.calltoaction_complete) {
              $("#calltoaction-item-carousel-" + $scope.calltoaction_id).removeClass("hidden");
            }

            if(data.current_correct_answer == answer_id) {
              correctytplayer_hash[key] = true;
            } else {
              correctytplayer_hash[key] = false;
            }

          }).error(function() {
            // ERROR.
          });
    } else {
      $("#registrate-modal").modal('show');
      $(".button-inter-" + interaction_id).attr('disabled', false);
    }
  } // updateTriviaAnswerOvervideo

}


