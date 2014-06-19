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

  // Inizializzazione dello scope.
  $scope.init = function(current_user, streamcalltoaction, calltoaction_length) {
    $scope.current_user = current_user;
    $scope.streamcalltoaction = streamcalltoaction;
    $scope.calltoaction_offset = streamcalltoaction.length;
    $scope.calltoaction_length = calltoaction_length;

    $scope.youtube_api_ready = false;

    var tag = document.createElement('script');
    tag.src = "//www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
  }; // init

  $window.onYouTubeIframeAPIReady = function() {
    $scope.youtube_api_ready = true;
    angular.forEach($scope.streamcalltoaction, function(sc) {
      appendYTIframe(sc);
    });
  }; // onYouTubeIframeAPIReady

  $window.appendYTIframe = function(sc) {
    if(sc.media_type == "VIDEO" && $scope.youtube_api_ready) {
      key = 'home-stream-video-' + sc.id;
      ytplayer_hash[key] = new YT.Player(key, {
        playerVars: { controls: 0, disablekb: 1, rel: 0, wmode: "transparent", showinfo: 0 },
        height: "100%", width: "100%",
        allowfullscreen: false,
        videoId: sc.video_url,
        events: { 'onReady': onYouTubePlayerReady, 'onStateChange': onPlayerStateChange }
      });
      playpressed_hash[key] = false;
      correctytplayer_hash[key] = false;
    }
  };

  $window.appendCalltoaction = function(type) {
    if($scope.calltoaction_length > $scope.calltoaction_offset) {
      $("#append-other button").attr('disabled', true);
      $http.post("/append_calltoaction", { offset: $scope.calltoaction_offset, type: type })
      .success(function(data) {
        $scope.calltoaction_offset = $scope.calltoaction_offset + data.streamcalltoaction.length
        $scope.streamcalltoaction.push(data.streamcalltoaction);
        $("#calltoaction-stream").append(data.html_to_append);

        if(!($scope.calltoaction_length > $scope.calltoaction_offset))
          $("#append-other").remove();

        angular.forEach(data.streamcalltoaction, function(sc) {
          appendYTIframe(sc);
        });

        $("#append-other button").attr('disabled', false);
      });
    } else {
      $("#append-other").remove();
    }
  };

  $window.updateYTIframe = function(calltoaction_video_code, calltoaction_id, autoplay) {
    key = 'home-stream-video-' + calltoaction_id;
    if($scope.youtube_api_ready && ytplayer_hash[key]) {
      if(!autoplay) {
        ytplayer_hash[key].cueVideoById(calltoaction_video_code);
        playpressed_hash[key] = false;
      } else {
        ytplayer_hash[key].loadVideoById(calltoaction_video_code);
      }
    }
  }

  $window.onYouTubePlayerReady = function(event) {
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
          calltoaction_id = calltoactionactive.replace("calltoaction-active-", "");
          $http.post("/update_play_interaction.json", { calltoaction_id: calltoaction_id })
            .success(function(data) {

              if(data.undervideo_feedback) {
                $(".current_user_points").html(data.points_updated);
                $("#home-undervideo-" + calltoaction_id).html(data.undervideo_feedback);
              }   

              if(data.calltoaction_complete) {
                $("#circle-calltoaction-done-" + calltoaction_id).removeClass("hidden");
              }         
          }).error(function() {
              // ERROR.
            });
            playpressed_hash[key] = true;
          }
      } else if(player_state == 0){
        playpressed_hash[key] = false;
        $http.post("/calltoaction_overvideo_end", { id: calltoactionactive.replace("calltoaction-active-", ""), end: correctytplayer_hash[key], type: $("#" + key).attr("type") })
          .success(function(data) {
            $("#home-overvideo-" + calltoactionactive.replace("calltoaction-active-", "")).html(data);
          });
      }
  }; // onPlayerStateChange

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

  $window.updateTriviaAnswer = function(calltoaction_id, interaction_id, answer_id) {
    $(".button-inter-" + interaction_id).attr('disabled', true);
    if($scope.current_user) {
      $http.post("/user_event/update_answer.json", { interaction_id: interaction_id, answer_id: answer_id })
          .success(function(data) {

            // Non permetto di selezionare nuovamente la risposta.
            $(".button-inter-" + interaction_id).attr('disabled', false);
            $(".button-inter-" + interaction_id).removeAttr('onclick');

            if(data.next_calltoaction) {
              key = 'home-video'; $("#" + key).attr("iid", "calltoaction-active-" + data.next_calltoaction["id"]);
              updateYTIframe(data.next_calltoaction["video_url"], calltoaction_id, true);
              $("#home-overvideo-" + calltoaction_id).html("");
            }

            if(data.undervideo_feedback) {
              $(".current_user_points").html(data.points_updated);
              $("#home-undervideo-" + calltoaction_id).html(data.undervideo_feedback);
            } 

            if(data.calltoaction_complete) {
              $("#circle-calltoaction-done-" + calltoaction_id).removeClass("hidden");
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