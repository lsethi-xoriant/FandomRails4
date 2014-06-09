var streamCalltoactionYoutubeApp = angular.module('StreamCalltoactionYoutubeApp', ['ngRoute']);

StreamCalltoactionYoutubeCtrl.$inject = ['$scope', '$window', '$http', '$timeout'];
streamCalltoactionYoutubeApp.controller('StreamCalltoactionYoutubeCtrl', StreamCalltoactionYoutubeCtrl);

// Gestione del csrf-token nelle chiamate ajax.
streamCalltoactionYoutubeApp.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

function StreamCalltoactionYoutubeCtrl($scope, $window, $http, $timeout) {

  var ytplayer_hash = {};
  var playpressed_hash = {};
  var correctytplayer_hash = {};

  var default_share_value = "https://www.youtube.com/watch?v=2DikYYmgWcY&list=UUuhxqTrgqPs2eijdeiDQgBQ";

  var overvideo_feedback_timeout;

  // Inizializzazione dello scope.
  $scope.init = function(calltoaction_video_code, calltoaction_id) {
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

          $("#home-video").attr("iid", "calltoaction-active-" + calltoaction_id);

          $("#home-overvideo-title").html(data.overvideo_title)
          $("#home-overvideo").html("");

          $(".home-carousel-li").removeClass("active");
          $("#home-carousel-li-" + calltoaction_id).addClass("active");

          $(".home-carousel-circle-children").removeClass("active");
          $("#home-carousel-circle-children-" + calltoaction_id).addClass("active");

          $("#share-footer").html(data.share_content);

          flushTimeoutFeedback(); // When I change video and a Timout is running.

          $(".panel-carousel").removeClass("panel-default").removeClass("panel-inactive").addClass("panel-inactive");
          $("#panel-carousel-" + calltoaction_id).removeClass("panel-inactive").addClass("panel-default");

          correctytplayer_hash[key] = false;
          playpressed_hash[key] = false;

          ytplayer_hash[key].cueVideoById(calltoaction_video_code);
        }).error(function() {
          // Error.
        });
    }
  };

  $window.shareWithFB = function(href, interaction_id) {
    
    href_to_share = default_share_value;
    if(href) {
      href_to_share = href;
    }

    FB.ui(
      {
        method: 'share',
        href: href_to_share
      },
      function(response) {
        if (response && !response.error_code) {
          $http.post("/user_event/share_free/facebook", { interaction_id: interaction_id })
            .success(function(data) {
            }).error(function() {
              // ERROR.
            });
        } else {
          // NOT SHARE.
        }
      }
    );

  }

  $window.onYouTubePlayerReady = function(event) {
  }; // onYouTubePlayerReady

  $window.flushTimeoutFeedback = function() {
    $timeout.cancel(overvideo_feedback_timeout);
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
              $("#home-overvideo-title").html(""); // REMOVE TITLE LAYER.        
            }).error(function() {
              // ERROR.
            });
            playpressed_hash[key] = true;
          }
      } else if(player_state == 0){
        playpressed_hash[key] = false;
      }
  }; // onPlayerStateChange

}


