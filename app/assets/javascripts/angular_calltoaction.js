// TODO - capire il ruolo di ngRoute
// Applicazione definita in ng-app="CalltoactionApp" all'interno di un nodo padre.
var calltoactionApp = angular.module('CalltoactionApp', ['ngRoute', 'CalltoactionControllers']);

// Gestione del csrf-token nelle chiamate ajax.
calltoactionApp.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

// Angular controller http://docs.angularjs.org/guide/controller.
var calltoactionControllers = angular.module('CalltoactionControllers', []);

// Controller definito in ng-controller="CalltoactionCtrl" all'interno di un nodo padre.
// Per poter inizializzare il controller utilizzare l'attributo ng-init="init(<lista di parametri>)" e definire uno
// $scope.init() [...]
function CalltoactionCtrl($scope, $window, $http, $timeout) {
//calltoactionApp.controller('CalltoactionCtrl', function($scope, $window, $http, $timeout) {
	
	var play_pressed = false; // Evita che l'evento play del video venga tracciato più volte a causa del polling.
	var lock_interaction = false; // Evita a causa del polling sul video una multipla riproduzione di una calltoaction.
	var ytplayer, ytduration;
	var timeout_overvideo_show, timeout_unlock_interaction; // Per la gestione del timeout.

	// Inizializzazione dello scope.
	$scope.init = function(vcode, calltoaction_id, property_id, overvideo_during_interaction_list, current_user, comment_published_count, comment_must_be_approved) {
  	$scope.vcode = vcode; $scope.calltoaction_id = calltoaction_id; $scope.property_id = property_id; $scope.current_user = current_user;
  	$scope.overvideo_during_interaction_list = overvideo_during_interaction_list;
  	$window.comment_published_count = comment_published_count;
  	$window.closed_comment_published_count = comment_published_count - 5;
  	$window.comment_must_be_approved = comment_must_be_approved;

    var tag = document.createElement('script');
		tag.src = "//www.youtube.com/iframe_api";
		var firstScriptTag = document.getElementsByTagName('script')[0];
		firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

		if($window.comment_published_count != -1 && !$window.comment_must_be_approved)
			$timeout(function() { updateCommentViewPolling(); }, 15000);
	}; // init

	$window.buildCommentHtml = function(c, k) {
		html_to_return = 
			"<div class=\"row comment\" id=\"comment-" + k + "\">" +
		        "<div class=\"col-xs-2 text-right\">" +
		          "<h5><img src=\"" + c.image + "\" alt=\"...\" class=\"img-circle img-responsive img-profile pull-right\" width=\"50%\"></h5>" +
		        "</div>" +
		        "<div class=\"col-xs-10 new-comment\">" +
		          "<h5>" + c.name + " <small>&bull; " + c.created_at + "</small></h5>" +
		          "<p class=\"text-muted\">" + c.text + "</p>" +
		          "<hr>" +
		        "</div>" + 
	      	"</div>";
		return html_to_return;	
	}; // buildCommentHtml

	$window.updateCommentViewPolling = function() {
		$http.post("/" + $scope.property_id + "/" + $scope.calltoaction_id + "/get_comment_published" , { offset: $window.comment_published_count })
			.success(function(data) {
				$window.comment_published_count += Object.keys(data).length;
				angular.forEach(data, function(c, k) {
					if($("#comment-" + k).length == 0) $("#comment-" + k).remove();					
					$("#div-comment").prepend($window.buildCommentHtml(c, k));
				});
				showNewCommentFeedback();
				$timeout(function() { updateCommentViewPolling(); }, 15000);
			});
	}; // updateCommentViewPolling

	$window.updateCommentViewOneTime = function() {
		$http.post("/" + $scope.property_id + "/" + $scope.calltoaction_id + "/get_comment_published" , { offset: $window.comment_published_count })
			.success(function(data) {
				$window.comment_published_count += Object.keys(data).length;
				angular.forEach(data, function(c, k) {
					if($("#comment-" + k).length == 0) $("#comment-" + k).remove();				
					$("#div-comment").prepend($window.buildCommentHtml(c, k));
				});
				showNewCommentFeedback();
			});
	}; // updateCommentViewOneTime

	$window.updateClosedCommentView = function() {
		if($window.closed_comment_published_count > 0) {
			$http.post("/" + $scope.property_id + "/" + $scope.calltoaction_id + "/get_closed_comment_published" , { offset: $window.closed_comment_published_count })
				.success(function(data) {
					$window.closed_comment_published_count -= 10;
					$("#comment-append-counter").html(Math.max($window.closed_comment_published_count, 0));

					html_to_append = new String();
					angular.forEach(data, function(c, k) {
						if($("#comment-" + k).length == 0) $("#comment-" + k).remove();
						html_to_append = $window.buildCommentHtml(c, k) + html_to_append;
					});
					$("#div-comment").append(html_to_append);
				});
		}
	};

	$window.updateDisqusCommentView = function() {
		$http.post("/" + $scope.property_id + "/" + $scope.calltoaction_id + "/next_disqus_page" , 
				{ disquscursor: $("#comment-append-counter").attr("disqus-next"), disqusurl: $("#comment-append-counter").attr("disqus-url") })
			.success(function(data) {
				$("#comment-append-counter").html();

				html_to_append = new String();
				angular.forEach(data, function(c, k) {
					html_to_append = html_to_append + $window.buildCommentHtml(c, k);
				});
				$("#div-comment").append(html_to_append);
			});
	};

	function showNewCommentFeedback() {
		$(".new-comment").animate({ backgroundColor: "#FFF5E5" }, 1000, function() {  
			$timeout(function() { 
				$(".new-comment").animate({ backgroundColor: "white" }, 1000);
				$(".new-comment").removeClass("new-comment");
			}, 2000);
		});
	}

	function appendLevelUpToView(level_up_list) {
		angular.forEach(level_up_list, function(level, l_key) {
			angular.forEach(level_up_list, function(level, b_key) {
				$('.bottom-left').notify({
			  		message: { html: ("Hai raggiunto il livello " + level) }
			  	}).show(); 
			});
		});
	} // appendLevelUpToView

	function appendBadgeUpToView(badge_up_list) {
		angular.forEach(badge_up_list, function(badge, b_key) {
			$('.bottom-left').notify({
		  		message: { html: ("Hai vinto il badge " + badge) }
		  	}).show(); 
		});
	} // appendLevelUpToView

	$window.updateLike = function(interaction_id) {
		if($scope.current_user) {
			$http.post("/user_event/update_like", { interaction_id: interaction_id })
				.success(function(data) {
					if(data.interaction_save)
						$("#button-like-inter-" + interaction_id).removeClass("btn-default").addClass("btn-primary");
					else
						$("#button-like-inter-" + interaction_id).removeClass("btn-primary").addClass("btn-default");
					check_level_and_badge_up();
				});
		} else {
			$("#registrate-modal").modal('show');
		}
	};

	$window.updateDownload = function(interaction_id, download_url) {
		if($scope.current_user) {
			$http.post("/user_event/update_download", { interaction_id: interaction_id })
				.success(function(data) {
					$("#button-download-inter-" + interaction_id).removeClass("btn-default").addClass("btn-primary");
					window.open(download_url, '_blank');
					check_level_and_badge_up();
				});
		} else {
			$("#registrate-modal").modal('show');
		}
	};

	$window.shareWith =function(provider, interaction_id) {
		$("#share-" + provider).attr('disabled', true); // Modifico lo stato del bottone.
		$http.post("/user_event/share/" + provider, { interaction_id: interaction_id })
				.success(function(data) {
					// Modifico lo stato del bottone e notifico la condivisione.
					$("#share-" + provider).attr('disabled', false);

					if(data != "current-user-no-provider")
						$('.bottom-left').notify({ message: { html: ("Hai condiviso un contenuto con " + provider) }}).show();
					else
						$('.bottom-left').notify({ 
							message: { html: ("Devi connettere il tuo account a " + provider + " per poter condividere il contenuto") }
						}).show();	 
				});
	};

	$window.updateCheck = function(interaction_id) {
		$("#button-inter-" + interaction_id).attr('disabled', true);
		if($scope.current_user) {
			$http.post("/user_event/update_check", { interaction_id: interaction_id })
				.success(function(data) {
					$("#button-inter-" + interaction_id).attr('disabled', false);
					$("#button-inter-" + interaction_id).removeClass("btn-info").addClass("btn-success").addClass("active");

					$("#button-inter-" + interaction_id).removeAttr('onclick');

					check_level_and_badge_up();
				});
		} else {
			$("#registrate-modal").modal('show');
		}
	}; // updateCheck

	function check_level_and_badge_up() {
		if($scope.current_user) {
			$http.post("/" + $scope.property_id + "/check_level_and_badge_up")
				.success(function(data) {
					if(data.level_up_to_show != null)
    					appendLevelUpToView(data.level_up_to_show);

    				if(data.badge_up_to_show != null)
    					appendBadgeUpToView(data.badge_up_to_show);
				});
		}
	} // check_level_and_badge_up

	$window.updateVersusAnswerOvervideo = function(interaction_id, answer_id) {
		$(".button-inter-" + interaction_id).attr('disabled', true); // Disabilito i pulsanti.
		$timeout.cancel(timeout_overvideo_show); $timeout.cancel(timeout_unlock_interaction);
		if($scope.current_user) {
			$http.post("/user_event/update_answer", { interaction_id: interaction_id, answer_id: answer_id })
    				.success(function(data) {
    					$(".button-inter-" + interaction_id).attr('disabled', false);
						$(".button-inter-" + interaction_id).removeClass("btn-info").removeClass("btn-danger").removeClass("btn-success").addClass("btn-danger");
	            		$("#button-answ-" + answer_id).removeClass("btn-danger").addClass("btn-success").addClass("active");

	            		angular.forEach(data, function(percent, key) {
							$("#data-answ-" + key).html(" " + percent + "%");
							$("#bar-answ-" + key).css("width", percent + "%");
						});

	            		$("#calltoaction-overvideo-during-info").html("Il video ripartirà tra 3 secondi...");

						timeout_overvideo_show = $timeout(function() {
					        ytplayer.playVideo(); 
					        timeout_unlock_interaction = $timeout(function() { lock_interaction = false; }, 2000); 
					        $(".overvideo").hide();
					    	check_level_and_badge_up();
					    }, 3000);

					}).error(function() {
						$(".button-inter-" + interaction_id).attr('disabled', false);
						// Errore nel salvataggio del dato.
    				});
        } else {
        	$("#registrate-modal").modal('show');
        }
	}; // updateVersusAnswerOvervideo

	$window.updateCheckAnswerOvervideo = function(interaction_id) {
		$("#button-inter-" + interaction_id).attr('disabled', true);
		$timeout.cancel(timeout_overvideo_show); $timeout.cancel(timeout_unlock_interaction);
		if($scope.current_user) {
			$http.post("/user_event/update_check", { interaction_id: interaction_id })
    				.success(function(data) {
    					$("#button-inter-" + interaction_id).attr('disabled', false);
						$("#button-inter-" + interaction_id).removeClass("btn-info").addClass("btn-success").addClass("active");

						$("#button-inter-" + interaction_id).removeAttr('onclick');

	            		$("#calltoaction-overvideo-during-info").html("Il video ripartirà tra 3 secondi...");

						timeout_overvideo_show = $timeout(function() {
					        ytplayer.playVideo(); 
					        timeout_unlock_interaction = $timeout(function() { lock_interaction = false; }, 2000);
					        $(".overvideo").hide();
					        check_level_and_badge_up();
					    }, 3000);

					}).error(function() {
						$(".button-inter-" + interaction_id).attr('disabled', false);
						// Errore nel salvataggio del dato.
    				});
        } else {
        	$("#registrate-modal").modal('show');
        }
	}; // updateTriviaAnswerOvervideo

	$window.updateTriviaAnswerOvervideo = function(interaction_id, answer_id) {
		$(".button-inter-" + interaction_id).attr('disabled', true);
		$timeout.cancel(timeout_overvideo_show); $timeout.cancel(timeout_unlock_interaction);
		if($scope.current_user) {
			$http.post("/user_event/update_answer", { interaction_id: interaction_id, answer_id: answer_id })
    				.success(function(data) {
    					$(".button-inter-" + interaction_id).attr('disabled', false);

    					// Identifico tramite il colore del buttone risposte errate e risposta corretta.
    					$(".button-inter-" + interaction_id).removeClass("btn-info").addClass("btn-danger");
						$("#button-answ-" + data.current_correct_answer).removeClass("btn-danger").addClass("btn-success");

						$("#button-answ-" + answer_id).addClass("active");
						$(".button-inter-" + interaction_id).removeAttr('onclick');

	            		$("#calltoaction-overvideo-during-info").html("Il video ripartirà tra 3 secondi...");

						timeout_overvideo_show = $timeout(function() {
					        ytplayer.playVideo(); 
					        timeout_unlock_interaction = $timeout(function() { lock_interaction = false; }, 2000); 					        
					        $(".overvideo").hide();
					        check_level_and_badge_up();   	
					    }, 3000);

					}).error(function() {
						$(".button-inter-" + interaction_id).attr('disabled', false);
						// Errore nel salvataggio del dato.
    				});
        } else {
        	$("#registrate-modal").modal('show');
        }
	}; // updateTriviaAnswerOvervideo

	$window.updateVersusAnswer = function(interaction_id, answer_id) {
		$(".button-inter-" + interaction_id).attr('disabled', true); // Disabilito i pulsanti.
		if($scope.current_user) {
			$http.post("/user_event/update_answer", { interaction_id: interaction_id, answer_id: answer_id })
    				.success(function(data) {
    					$(".button-inter-" + interaction_id).attr('disabled', false);
    					$(".button-inter-" + interaction_id).removeClass("btn-info").removeClass("btn-danger").removeClass("btn-success").addClass("btn-danger");
	            		$("#button-answ-" + answer_id).removeClass("btn-danger").addClass("btn-success").addClass("active");

	            		angular.forEach(data, function(percent, key) {
							$("#data-answ-" + key).html(percent + "%");
							$("#bar-answ-" + key).css("width", percent + "%");
						});

						check_level_and_badge_up();

					}).error(function() {
						$(".button-inter-" + interaction_id).attr('disabled', false);
						// Errore nel salvataggio del dato.
    				});
        } else {
        	$(".button-inter-" + interaction_id).attr('disabled', false);
        	$("#registrate-modal").modal('show');
        }
	}; // updateVersusAnswerOvervideo

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

						check_level_and_badge_up();

					}).error(function() {
						$(".button-inter-" + interaction_id).attr('disabled', false);
						// Errore nel salvataggio del dato.
    				});
        } else {
        	$("#registrate-modal").modal('show');
        	$(".button-inter-" + interaction_id).attr('disabled', false);
        }
	}; // updateTriviaAnswerOvervideo

	// Per includere una generica funzione nella pagina $window.nomefunzione = function().
	// Inizializzazione player YT.
	$window.onYouTubeIframeAPIReady = function() {
		ytplayer = new YT.Player('cta-video', {
			playerVars: { }, // controls: 0, disablekb: 1, rel: 0, wmode: "transparent", showinfo: 0
			height: "100%", width: "100%",
			allowfullscreen: false,
			videoId: $scope.vcode,
			events: { 'onReady': onYouTubePlayerReady, 'onStateChange': onPlayerStateChange }
		});
	}; // onYouTubeIframeAPIReady

	$window.jumpTo = function(second) {
		if(play_pressed) {
			$("#interaction-progress-bar").css("width", ((second/ytduration*100)+1) + "%");

			if($scope.current_user) {
				// Se modifico il tempo durante un overvideo devo sbloccare le interaction e nascondere la question.
				$timeout.cancel(timeout_overvideo_show); $timeout.cancel(timeout_unlock_interaction);
				lock_interaction = false; $(".overvideo").hide();
				ytplayer.seekTo(second); launchInteraction(second);
			} else {
				$("#registrate-modal").modal('show');
			}
		}
	}; // jumpTo

	// Callback chiamata quando il player e' pronto.
	$window.onYouTubePlayerReady = function(player_id) {
		ytduration = ytplayer.getDuration();

		interaction_progress_bar_html = new String(); //$("#interaction-progress-bar-point")
		interaction_progress_bar_html = 
			"<div class=\"progress-bar progress-bar-info\" style=\"width: 0%; background: none;\">" +
	          "<div style=\"margin: 3px 0; margin-left: auto; background: transparent; height: 18px; width: 18px; border-radius: 10px; font-size: 11px;\">" +
	          "</div>" +
	        "</div>";
		angular.forEach($scope.overvideo_during_interaction_list, function(interaction, i_key) {
			interaction_progress_bar_html +=
				"<div class=\"progress-bar progress-bar-info\" style=\"left:" + Math.round(interaction.seconds/ytduration*100) + "%; background: none; position: absolute;  box-shadow: none;\">" +
		        	"<span class=\"sr-only\"></span>" +
		          	"<div class=\"progress-bar-single-point\" onclick=\"jumpTo(" + interaction.seconds + ")\" style=\"margin-top: 3px; margin-left: auto; margin-right: -10px; background: gray; height: 18px; width: 18px; border-radius: 10px; font-size: 11px;\">" +
		          	"</div>" +
		        "</div>";
		});

		$("#interaction-progress-bar-point").html(interaction_progress_bar_html);
		
		/*
		<div class="progress-bar progress-bar-info" style="width: 20%; background: none; position: absolute">
          <span class="sr-only">20% Complete (warning)</span>
          <div style="margin: 3px 0; margin-left: auto; background: #444; height: 18px; width: 18px; border-radius: 10px; font-size: 11px;">
          </div>
        </div>
        */
	}; // onYouTubePlayerReady

	// Callback chiamata quando lo stato del video viene modificato.
	$window.onPlayerStateChange = function() {
	    player_state = ytplayer.getPlayerState();
	  	if(player_state == 1) { // Lo stato 1 corrisponde al video in riproduzione.
			// Identifico il play del video in modo da poter tracciare l'evento.  		    
	    	if(!play_pressed) {
    			$http.post("/update_play_interaction.json", { calltoaction_id: $scope.calltoaction_id })
    				.success(function(data) {
    					// Mostro i punti guadagnati ed evenuali livelli raggiunti.
    					check_level_and_badge_up();  						
					}).error(function() {
    					// Errore nel salvataggio dell'evento play.
    				});
		        play_pressed = true;
		        $(".progress-bar-single-point").css("background-color", "#f0ad4e");
		        setInterval(checkInteraction, 200); // Avvio il polling sul video.
	        }
	  	} else if(player_state == 0){
	  		play_pressed = false;
	  	}
	}; // onPlayerStateChange

	function generateCheckAnswerHtml(answer, interaction_id, done) { 
        answer_html = new String();
		if(!done) {
			answer_html += 
				"<button type=\"button\" id=\"button-inter-" + interaction_id + "\" class=\"btn-lg btn-block button-inter-" + interaction_id + " btn btn-info\" onclick=\"updateCheckAnswerOvervideo(" + interaction_id + ")\">" + 
					answer +
				"</button>";
		} else {	
			answer_html += 
				"<button type=\"button\" id=\"button-inter-" + interaction_id + "\" class=\"btn-lg btn-block button-inter-" + interaction_id + " btn btn-success\">" + 
					answer +
				"</button>";		
			timeout_overvideo_show = $timeout(function() {
		        ytplayer.playVideo();
		        timeout_unlock_interaction = $timeout(function() { lock_interaction = false; }, 2000); 
		        $(".overvideo").hide();
		    }, 3000);
		}
		return answer_html;
	} // generateCheckAnswerHtml

	// Genera l'html delle risposte nel formato <p><button></button><span></span></p>
	function generateVersusAnswerHtml(answer, interaction_id, done, user_answer_id) { 
		answer_length = Math.round(Object.keys(answer).length/2);
		answer_html = "<div class=\"col-md-5 col-xs-6\">";
		var i = 0;

		if(done) {
			timeout_overvideo_show = $timeout(function() {
		        ytplayer.playVideo(); 
		        timeout_unlock_interaction = $timeout(function() { lock_interaction = false; }, 2000); 
		        $(".overvideo").hide();
		    }, 3000);
		} 

		angular.forEach(answer, function(answer, a_key) {

			if(answer_length == i) {
				answer_html += 
					"</div>" +
					"<div class=\"col-md-2 hidden-xs hidden-sm\"><h5 class=\"v-center\">VS</h5></div>" +
		            "<div class=\"col-md-5 col-xs-6\">";
			} // answer_length == i

			if(answer_length > i) {
				if(done) {
					button_type = a_key == user_answer_id ? "btn-success active" : "btn-danger";
					answer_html += 
						"<div class=\"row\">" +
	                        "<div class=\"col-md-8 col-md-offset-4 col-sm-8 col-sm-offset-4 choice choosen\">" +
	                        	"<div class=\"status\">" +
	                            	"<h4 id=\"data-answ-" + a_key + "\">" + answer.info + "%</h4>" +
	                          	"</div>" +
	                          	"<a href=\"#\" class=\"thumbnail\"><img src=\"" + answer.image + " alt=\"...\"></a>" +
	                        "</div>" +
	                    "</div>" +
	                    "<div class=\"row\">" +
	                        "<div class=\"col-md-8 col-md-offset-4 col-sm-8 col-sm-offset-4\">" +
	                          	"<div class=\"vs-level-container\">" +
	                            	"<div id=\"bar-answ-" + a_key + "\" class=\"vs-level-inner-sx\" style=\"width: " + answer.info + "%\"></div>" +
	                          	"</div>" +
	                        "</div>" +
	                    "</div>" +
	                    "<div class=\"row\">" +
	                        "<div class=\"col-md-8 col-md-offset-4 col-sm-8 col-sm-offset-4\">" +
	                        	"<button id=\"button-answ-" + a_key + "\" type=\"button\" class=\"btn btn-block button-inter-" + interaction_id + " " + button_type + "\" onclick=\"updateVersusAnswerOvervideo(" + interaction_id+ ", " + a_key + ")\">" + answer.text + "</button>" +
	                        "</div>" +
	                    "</div>";
				} else { 
					answer_html += 
						"<div class=\"row\">" +
	                        "<div class=\"col-md-8 col-md-offset-4 col-sm-8 col-sm-offset-4 choice choosen\">" +
	                        	"<div class=\"status\">" +
	                        		"<h4 id=\"data-answ-" + a_key + "\"></h4>" +
	                        	"</div>" +
	                          	"<a href=\"#\" class=\"thumbnail\"><img src=\"" + answer.image + "\" alt=\"...\"></a>" +
	                        "</div>" +
	                    "</div>" +
                      	"<div class=\"row\">" +
                            "<div class=\"col-md-8 col-md-offset-4 col-sm-8 col-sm-offset-4\">" +
                            	"<div class=\"vs-level-container\">" +
                                	"<div id=\"bar-answ-" + a_key + "\" class=\"vs-level-inner-sx\" style=\"width: 0%\">" +
                                	"</div>" +
                              	"</div>" +
                            "</div>" +
                        "</div>" +
                        "<div class=\"row\">" +
                            "<div class=\"col-md-8 col-md-offset-4 col-sm-8 col-sm-offset-4\">" +
                            	"<button id=\"button-answ-" + a_key + "\" type=\"button\" class=\"btn btn-block button-inter-" + interaction_id + " btn-info\" onclick=\"updateVersusAnswerOvervideo(" + interaction_id+ ", " + a_key + ")\">" + answer.text + "</button>" +
                            "</div>" +
                        "</div>";
				} // done
			} else {
				if(done) { 
					button_type = a_key == user_answer_id ? "btn-success active" : "btn-danger";
					answer_html += 
						"<div class=\"row\">" +
                            "<div class=\"col-md-8 col-sm-8 choice not-choosen\">" +
                            	"<div class=\"status\">" +
                                	"<h4 id=\"data-answ-" + a_key + "\">" + answer.info + "%</h4>" +
                              	"</div>" +
                              	"<a href=\"#\" class=\"thumbnail\"><img src=\"" + answer.image + " alt=\"...\"></a>" +
                            "</div>" +                                    
                        "</div>" +
                        "<div class=\"row\">" +
                            "<div class=\"col-md-8 col-sm-8\">" +
                            	"<div class=\"vs-level-container\">" +
                                	"<div id=\"bar-answ-" + a_key + "\" class=\"vs-level-inner-sx\" style=\"width: " + answer.info + "%\"></div>" +
                              	"</div>" +
                            "</div>" +
                        "</div>" +
                        "<div class=\"row\">" +
                            "<div class=\"col-md-8 col-sm-8\">" +
                            	"<button id=\"button-answ-" + a_key + "\" type=\"button\" class=\"btn btn-block button-inter-" + interaction_id + " " + button_type + "\" onclick=\"updateVersusAnswerOvervideo(" + interaction_id+ ", " + a_key + ")\">" + answer.text + "</button>" +
                            "</div>" +
                        "</div>"; 
				} else {
					answer_html += 
						"<div class=\"row\">" +
                            "<div class=\"col-md-8 col-sm-8 choice not-choosen\">" +
                            	"<div class=\"status\">" +
                            		"<h4 id=\"data-answ-" + a_key + "\"></h4>" +
                            	"</div>" +
                              	"<a href=\"#\" class=\"thumbnail\"><img src=\"" + answer.image + " alt=\"...\"></a>" +
                            "</div>" +                                    
                        "</div>" +
                    	"<div class=\"row\">" +
                            "<div class=\"col-md-8 col-sm-8\">" +
                            	"<div class=\"vs-level-container\">" +
                                	"<div id=\"bar-answ-" + a_key + "\" class=\"vs-level-inner-dx\" style=\"width: 0%\"></div>" +
                              	"</div>" +
                            "</div>" +
                        "</div>" +
                        "<div class=\"row\">" +
                            "<div class=\"col-md-8 col-sm-8\">" +
                            	"<button id=\"button-answ-" + a_key + "\" type=\"button\" class=\"btn btn-block button-inter-" + interaction_id + " btn-info\" onclick=\"updateVersusAnswerOvervideo(" + interaction_id+ ", " + a_key + ")\">" + answer.text + "</button>" +
                            "</div>" +
                        "</div>"; 
				} // done				
			} // answer_length > i
			answer_html += "<p>&nbsp;</p>";
			i += 1;
		}); // angular.forEach(answer, function(answer, a_key)
		answer_html += "</div>";
		return answer_html;
	} // generateVersusAnswerHtml

	function generateTriviaAnswerHtml(answer, interaction_id, done, user_answer_id, correct_answer_id) { 

		/*
		<div class="col-md-6">
          <button type="button" class="btn btn-info btn-lg btn-block">Risposta 1</button>
          <button type="button" class="btn btn-info btn-lg btn-block">Risposta 2</button>
        </div>
        <div class="col-md-6">
          <!--<div class="hidden-md hidden-lg" style="height: 5px"></div>-->
          <button type="button" class="btn btn-info btn-lg btn-block">Risposta 3</button>
          <button type="button" class="btn btn-info btn-lg btn-block">Risposta 4</button>
        </div>
        */

        answer_length = Math.round(Object.keys(answer).length/2); var i = 0;
		answer_html = "<div class=\"col-md-6\">";
		if(!done) {
			angular.forEach(answer, function(answer, a_key) {
				if(answer_length == i)
					answer_html += "</div><div class=\"col-md-6\">";
				i += 1;

				answer_html += 
					"<button type=\"button\" id=\"button-answ-" + a_key + "\" class=\"btn-lg btn-block button-inter-" + interaction_id + " btn btn-info\" onclick=\"updateTriviaAnswerOvervideo(" + interaction_id + "," + a_key + ")\">" + 
						answer +
					"</button>";
			});
		} else {			
			angular.forEach(answer, function(answer, a_key) {
				if(answer_length == i)
					answer_html += "</div><div class=\"col-md-6\">";
				i += 1;

				button_type = a_key == correct_answer_id ? "btn-success" : "btn-danger";
				button_active = a_key == user_answer_id ? "active" : "";
				answer_html += 
					"<button type=\"button\" id=\"button-answ-" + a_key + "\" class=\"btn-lg btn-block button-inter-" + interaction_id + " btn " + button_type + " " + button_active + "\">" + 
						answer + 
					"</button>";			
			});
			timeout_overvideo_show = $timeout(function() {
		        ytplayer.playVideo();
		        timeout_unlock_interaction = $timeout(function() { lock_interaction = false; }, 2000); 
		        $(".overvideo").hide();
		    }, 3000);
		}
		answer_html += "</div>";
		return answer_html;
	} // generateTriviaAnswerHtml

	// Verifico se al secondo corrente e' presente un'interaction.
	$window.checkInteraction = function() {
		current_video_time = ytplayer.getCurrentTime(); 
		current_second = Math.floor(current_video_time);
		$("#interaction-progress-bar").css("width", ((current_video_time/ytduration*100)+1) + "%");
		launchInteraction(current_second);
	}; // checkInteraction

	$window.launchInteraction = function(s) {
		if(!lock_interaction) {
			// Verifico se e' presente un'interaction al secondo specificato.
			angular.forEach($scope.overvideo_during_interaction_list, function(interaction, i_key) {
				if(s == interaction.seconds) {
					lock_interaction = true; 
					ytplayer.pauseVideo();
	    			$http.post("/" + $scope.property_id + "/" + $scope.calltoaction_id + "/get_overvideo_interaction.json", { interaction_id: i_key })
	    				.success(function(data) {    								    					
	    					if(interaction.quiz_type == "VERSUS") {
	    						$("#overvideo-versus").show();
	    						$("#calltoaction-versus-overvideo-during-question").html(data.question);   		
	    						answer_html = generateVersusAnswerHtml(data.answers, i_key, data.done, data.user_answer);
	    						$("#calltoaction-versus-overvideo-during-answer").html(answer_html);
	    					} else if(interaction.quiz_type == "TRIVIA") {
	    						$("#overvideo-trivia").show();
	    						$("#calltoaction-trivia-overvideo-during-question").html(data.question);   		
	    						answer_html = generateTriviaAnswerHtml(data.answers, i_key, data.done, data.user_answer, data.correct_answer);
	    						$("#calltoaction-trivia-overvideo-during-answer").html(answer_html);
	    					} else if(interaction.quiz_type == "CHECK") {
	    						$("#overvideo-check").show();
	    						$("#calltoaction-check-overvideo-during-question").html(data.question);   		
	    						answer_html = generateCheckAnswerHtml(data.check, i_key, data.done);
	    						$("#calltoaction-check-overvideo-during-answer").html(answer_html);
	    					}

						}).error(function() {
	    					// Errore nella richiesta dell'interaction.
	    				});
				}
			});
		}
	}; // launchInteraction
	
//});
}

CalltoactionCtrl.$inject = ['$scope', '$window', '$http', '$timeout'];
calltoactionApp.controller('CalltoactionCtrl', CalltoactionCtrl);


