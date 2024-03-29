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

	// Inizializzazione dello scope.
	$scope.init = function(current_user) {
    $scope.current_user = current_user;

    $scope.youtube_api_ready = false;

    var tag = document.createElement('script');
		tag.src = "//www.youtube.com/iframe_api";
		var firstScriptTag = document.getElementsByTagName('script')[0];
		firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
	}; // init

	$window.onYouTubeIframeAPIReady = function() {
		$scope.youtube_api_ready = true;
	}; // onYouTubeIframeAPIReady

	$window.updateYTIframe = function(calltoaction_video_code, calltoaction_id) {
		$scope.calltoaction_id = calltoaction_id;
		if($scope.youtube_api_ready) {
			$("#col-home-video").removeClass("hidden"); $(".home-carousel").addClass("hidden");
			key = 'home-video';
			ytplayer_hash[key] = new YT.Player(key, {
				playerVars: { controls: 0, disablekb: 1, rel: 0, wmode: "transparent", showinfo: 0 },
				height: "100%", width: "100%",
				allowfullscreen: false,
				videoId: calltoaction_video_code,
				events: { 'onReady': onYouTubePlayerReady, 'onStateChange': onPlayerStateChange }
			});
			playpressed_hash[key] = false;
		}
	};

	$window.onYouTubePlayerReady = function(event) {
	}; // onYouTubePlayerReady

	$window.closeShareAndOpenDenied = function(provider) {
		$("#share-modal").modal("hide");
		$("#share-" + provider + "-disable-modal").modal("show");
	}; // closeShareAndOpenDenied

	// Callback chiamata quando lo stato del video viene modificato.
	$window.onPlayerStateChange = function(newState) {	
		key = newState.target.getIframe().id;
		ytplayer = ytplayer_hash[key];
	    player_state = ytplayer.getPlayerState();
	  	if(player_state == 1) { // Lo stato 1 corrisponde al video in riproduzione.
			// Identifico il PLAY del video in modo da poter tracciare l'evento.  		    
	    	if(!playpressed_hash[key]) {
    			$http.post("/update_play_interaction.json", { calltoaction_id: key.replace("stream-video-", "") })
    				.success(function(data) {
    					// Evento salvato correttamente.						
					}).error(function() {
    					// Errore nel salvataggio dell'evento.
    				});
		        playpressed_hash[key] = true;
	        }
	  	} else if(player_state == 0){
	  		playpressed_hash[key] = false;
	  		$http.post("/calltoaction_overvideo_end", { id: $scope.calltoaction_id })
					.success(function(data) {
						$("#home-overvideo").html(data);
					});
	  	}
	}; // onPlayerStateChange

	$window.openShareWith = function(property_id, calltoaction_id) {
		$http.post("/" + property_id + "/" + calltoaction_id + "/generate_share_modal")
				.success(function(data) {
					$("#share-modal-container").html(data);
					$("#share-modal").modal("show");

				}).error(function() {
					// ERRORE
    		});
	};

	$window.shareWith = function(provider, interaction_id, calltoaction_id) {

		$("#share-" + provider + "-" + interaction_id).attr('disabled', true); // Modifico lo stato del bottone.
		$("#share-" + provider + "-" + interaction_id).html("<img src=\"/assets/loading.gif\" style=\"width: 15px;\">");

		$http.post("/user_event/share/" + provider, { interaction_id: interaction_id, share_email_address: $("#share-email-address-" + interaction_id).val() })
				.success(function(data) {
					// Modifico lo stato del bottone e notifico la condivisione.
					$("#share-" + provider + "-" + interaction_id).attr('disabled', true); // Modifico lo stato del bottone.
					$("#share-" + provider + "-" + interaction_id).html("SHARE WITH " + provider);

					$("#share-modal").modal("hide");

					if(provider == "email") {
						$("#share-email-address-" + interaction_id).val("");
						$("#share-" + provider + "-" + interaction_id).html("SHARE WITH EMAIL");
						if(data == "false") {
							$("#invalid-email-modal").modal("show");	
						} else {
							$("#share-" + calltoaction_id).addClass("btn-success");
							$("#share-" + calltoaction_id).html("<span class=\"glyphicon glyphicon-ok\"></span>");
						}

					} else {
						$("#share-" + calltoaction_id).addClass("btn-success");
						$("#share-" + calltoaction_id).html("<span class=\"glyphicon glyphicon-ok\"></span>");
					}

				}).error(function() {
    			// ERRORE
    		});
	};

	$window.closeShareAndOpenWarningModal = function(calltoaction_id, share_type) {
		$("#share-modal").modal("hide");
		$("#first-share-modal-" + share_type).modal("show");
	}; // closeShareAndOpenWarningModal

	$window.updateTriviaAnswer = function(interaction_id, answer_id) {
		$(".button-inter-" + interaction_id).attr('disabled', true);
		if($scope.current_user) {
			$http.post("/user_event/update_answer.json", { interaction_id: interaction_id, answer_id: answer_id })
    			.success(function(data) {
    				$(".button-inter-" + interaction_id).attr('disabled', false);
    				// Non permetto di selezionare nuovamente la risposta.

    				// Identifico tramite il colore del buttone risposte errate e risposta corretta.
    				$(".button-inter-" + interaction_id).removeClass("btn-info").addClass("btn-danger");
						$("#button-answ-" + data.current_correct_answer).removeClass("btn-danger").addClass("btn-success");

						$("#button-answ-" + answer_id).addClass("active");
						$(".button-inter-" + interaction_id).removeAttr('onclick');

					}).error(function() {
						// ERROR.
    			});
    } else {
      $("#registrate-modal").modal('show');
      $(".button-inter-" + interaction_id).attr('disabled', false);
    }
	} // updateTriviaAnswerOvervideo

}


