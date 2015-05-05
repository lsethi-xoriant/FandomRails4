var streamCalltoactionModule = angular.module('StreamCalltoactionModule', ['ngRoute', 'ngSanitize', 'ngAnimate']);

StreamCalltoactionCtrl.$inject = ['$scope', '$window', '$http', '$timeout', '$interval', '$sce', '$upload'];
streamCalltoactionModule.controller('StreamCalltoactionCtrl', StreamCalltoactionCtrl);

// Gestione del csrf-token nelle chiamate ajax.
streamCalltoactionModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

streamCalltoactionModule.filter('unsafe', ['$sce', function($sce) { 
  return $sce.trustAsHtml; 
}]);

streamCalltoactionModule.filter('trustAsResourceUrl', ['$sce', function($sce) { 
  return $sce.trustAsResourceUrl; 
}]);

/* COIN */
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

/* COIN */
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

angular.module('ng').filter('cut', function () {
  return function (value, wordwise, max, tail) {
      if (!value) return '';

      max = parseInt(max, 10);
      if (!max) return value;
      if (value.length <= max) return value;

      value = value.substr(0, max);
      if (wordwise) {
          var lastspace = value.lastIndexOf(' ');
          if (lastspace != -1) {
              value = value.substr(0, lastspace);
          }
      }

      return value + (tail || '...');
  };
});

function StreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document, $upload) {

  $scope.zerosBeforeNumber = function(number, zero_length) {
    for (i = 0; i < zero_length; i++) { 
      number = "0" + number;
    }
    return number.slice(-(zero_length + 1));
  };

  /*
  <form>
    <fieldset><legend>Upload on form submit</legend>
      {{form_data.attachment[0].progress + '%'}}

      Title: <input type="text" name="title" ng-model="form_data.title">
      Immagine/video: <input type="file" ng-file-select="" ng-model="form_data.attachment" name="attachment">
      <span ng-if="form_data.attachment[0].result">Upload 1 {{form_data.attachment[0].result}}</span>

      Immagine2/video2: <input type="file" ng-file-select="" ng-model="form_data.release" name="release">

      <button ng-click="upload([form_data.attachment[0], form_data.release[0]])">Submit</button> 
    </fieldset>
  </form>
  */
  $scope.upload = function (files, url, extra_fields) {
    delete $scope.form_data.errors;
    $scope.form_data.errors = getFormUploadErrors(files, extra_fields);
    if(!$scope.form_data.errors) {
      $upload.upload({
          url: url,
          fields: { obj: $scope.form_data },
          file: files,
          fileFormDataName: ["attachment", "releasing"]
        }).progress(function (evt) {
            var progressPercentage = parseInt(100.0 * evt.loaded / evt.total);
            $scope.form_data.progress = progressPercentage; // evt.config.file[0].progress
        }).success(function (data, status, headers, config) {
            if(data.errors) {
              $scope.form_data.errors = data.errors;
            } else {
              $("#ugc-feedback").modal('show');
              $("#upload-form").addClass("hidden");
              $("#partecipa").show();
              $scope.form_data = {};
            }
            delete $scope.form_data.progress;
        }).error(function (data, status, headers, config) {
          if(status == "413") { //413 (Request Entity Too Large)
            $scope.form_data.errors = "Ricorda che il tuo file non deve pesare più di 100MB";
          } else {
            $scope.form_data.errors = status;
          }
          delete $scope.form_data.progress;
        });
      }
  };

  function getFormUploadErrors(files, extra_fields) {
    
    errors = [];

    angular.forEach(extra_fields, function(extra_field) {
      if(extra_field['required'] && !$scope.form_data[extra_field['name']]) {
        errors.push(extra_field['label']);
      }
    });

    if(!$scope.form_data['title']) { 
      errors.push("Titolo non può essere lasciato in bianco");
    }

    if(!files[0]) {
      errors.push("Il media deve essere caricato");
    }

    if(files[0] && files[0].type == "application/zip") {
      errors.push("Formato del media non valido");
    }

    if(!files[1]) {
      errors.push("La liberatoria deve essere caricata");
    }

    if(errors.length > 0) {
      return errors.join(",");
    } else {
      return null;
    }

  }

  $scope.generateThumb = function(file) { 
    // ng-file-change="generateThumb(picFile[0], $files)"
    // <img ng-if="picFile[0].dataUrl != null" ng-src="{{picFile[0].dataUrl}}" class="thumb">
    if (file != null) {
      if (fileReaderSupported() && file.type.indexOf('image') > -1) {
        $timeout(function() {
          var fileReader = new FileReader();
          fileReader.readAsDataURL(file);
          fileReader.onload = function(e) {
            $timeout(function() {
              file.dataUrl = e.target.result;
            });
          };
        });
      }
    }
  };

  function fileReaderSupported() {
    return window.FileReader != null && (window.FileAPI == null || FileAPI.html5 != false);
  }

  $scope.scrollTo = function(el_id) {
    $('html, body').animate({
        scrollTop: $("#"+ el_id).offset().top
    }, 500);
  };

  $scope.sanitizeText = function(text) {
    return String(text).replace(/<[^>]+>/gm, '');
  };

  angular.element(document).ready(function () {
    if(window.name != "iframe_canvas_fb_https") {
      document.cookie = "oauth_connect_from_page=; expires=Thu, 01 Jan 1970 00:00:00 UTC"; 
    }
    $scope.angularReady();
  });

  $scope.angularReady = function() {
  };

  $scope.initCallToActionInfoList = function(calltoaction_info_list) {
    $scope.calltoactions = calltoaction_info_list;

    if($scope.calltoactions.length == 1) {
      $scope.calltoaction_info = $scope.calltoactions[0];
    }
  };

  $scope.init = function(current_user, calltoaction_info_list, calltoactions_count, calltoactions_during_video_interactions_second, google_analytics_code, current_calltoaction, aux) {
    FastClick.attach(document.body);

    $scope.aux = aux;
    $scope.current_user = current_user;
    
    $scope.initCallToActionInfoList(calltoaction_info_list);

    if($scope.calltoaction_info) {
      $scope.linked_call_to_actions_count = $scope.calltoaction_info.calltoaction.extra_fields.linked_call_to_actions_count;
      if($scope.linked_call_to_actions_count) {
        $scope.linked_call_to_actions_index = 1;
      }
    }

    //clearAnonymousUserStorage();

    $scope.answer_in_progress = false;

    if($scope.aux.from_registration) {
      $("#registration-modal").modal("show");
      ga('send', 'event', "Registration", "Registration", "Registration", 1, true);
    }

    $scope.calltoaction_ordering = "recent";

    if($scope.aux.current_property_info) {
      $scope.current_tag_id = $scope.aux.current_property_info.id;
    }

    if($scope.aux.mobile) {
      $scope.coverCommentsLimit = 1;
    } else {
      $scope.coverCommentsLimit = 2;
    }

    // With one calltoaction I active comment interaction
    $scope.comments_polling = new Object();
    $scope.ajax_comment_append_in_progress = false;
    if($scope.calltoactions.length == 1 && $scope.aux['enable_comment_polling']) {
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
    $scope.calltoactions_during_video_interactions_second = []; // FIX THIS calltoactions_during_video_interactions_second;
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

    $scope.initAnonymousUser();
    $scope.extraInit();

  };

  $scope.extraInit = function() {
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
          $(".call-to-action__mobile-description").html(data.calltoaction_info_list[0].calltoaction.description);
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
                $scope.initCallToActionInfoList(data.calltoaction_info_list);
                $scope.animation_in_progress = false;
              });
       			}, 1500);
    			});
	    		$scope.initAnonymousUser();
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

  $scope.computeAvgForVoteInteraction = function(interaction_info) {
    numerator = 0; denominator = 0;
    if(interaction_info.anonymous_user_interaction_info) {
      vote_info_list = JSON.parse(interaction_info.anonymous_user_interaction_info.aux).vote_info_list;
      angular.forEach(vote_info_list, function(value, key) {
        denominator = denominator + value;
        numerator = numerator + (parseInt(key) * value);
      });
      return (numerator/denominator).toFixed(0);
    } else {
      return 0;
    }
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

  $scope.orderCallToActionStream = function(calltoaction_info) {
    //calltoaction_ordering
    if($scope.calltoaction_ordering == "recent") {
      return calltoaction_info.calltoaction.activated_at;
    } else {
      comment_info_interaction = getCommentInteraction(calltoaction_info.calltoaction.id);
      if(comment_info_interaction) {
        return comment_info_interaction.interaction.resource.comment_info.comments_total_count;
      } else {
        return 0;
      }
    }
  };
  
  $scope.getGalleryUploadInteraction = function(interaction_info_list) {
    comment_interaction = null;
    angular.forEach(interaction_info_list, function(interaction_info) {
      if(interaction_info.interaction.resource_type == "upload") {
        comment_interaction = interaction_info;
      }
    });
    return comment_interaction;
  };
  
  $scope.getNumber = function(num) {
    return new Array(num);   
  };

  $scope.isCommentEmpty = function(calltoaction_info) {
    interaction_info = getCommentInteraction(calltoaction_info.calltoaction.id);
    if(interaction_info) {
      return !(interaction_info.interaction.resource.comment_info.comments.length > 0);
    } else {
      return true;
    }
  };

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
          });
          comment_interactions.push(comment_interaction);
        }
      });
    });
    return comment_interactions;
  }

  $scope.getPlayInteraction = function(calltoaction_id) {
    return getInteraction(calltoaction_id, "play");
  };

  $scope.getDownloadInteraction = function(calltoaction_id) {
    return getInteraction(calltoaction_id, "download");
  };

  $scope.checkUndervideoInteractionTypes = function (interaction_info) {
    return (
      interaction_info.interaction.resource_type != 'like' 
      && interaction_info.interaction.resource_type != 'comment' 
      && interaction_info.interaction.resource_type != 'link'
      && interaction_info.interaction.resource_type != 'vote'
      && interaction_info.interaction.resource_type != 'download'
    );
  };


  // Build an array from min to max for AngularJS ng-repeat
  $scope.range = function(min, max) {
    result = [];
    for (var i = min; i <= max; i++) {
      result.push(i);
    }
    return result;
  };

  $scope.getVoteInteraction = function(calltoaction_id) {
    return getInteraction(calltoaction_id, "vote");
  };

  function getInteraction(calltoaction_id, interaction_type) {
    result = null;
    calltoaction_info = getCallToActionInfo(calltoaction_id);
    angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(interaction_info.interaction.resource_type == interaction_type) {
        result = interaction_info;
      }
    });
    return result;
  }

  $scope.getInteractions = function(calltoaction_id, interaction_type) {
    result = [];
    calltoaction_info = getCallToActionInfo(calltoaction_id);
    angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(interaction_info.interaction.resource_type == interaction_type) {
        result.push(interaction_info);
      }
    });
    return result;
  };

  $scope.filterShareInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type == "share");
  };

  $scope.filterLikeInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type == "like");
  };

  $scope.filterLinkInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type == "link");
  };

  $scope.filterVoteInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type == "vote");
  };

  $scope.filterCommentInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type == "comment");
  };

  $scope.filterDownloadInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type == "download");
  };

  $scope.evaluateVote = function(interaction_info) {
    if(interaction_info.user_interaction) {
      return JSON.parse(interaction_info.user_interaction.aux)["vote"];
    } else {
      return null;
    }
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

  $scope.isLastStepInLinkedCallToAction = function() {
    return ($scope.linked_call_to_actions_count && $scope.linked_call_to_actions_count == $scope.linked_call_to_actions_index);
  };

  $scope.filterRemoveShareInteractionsExceptLastStep = function(interaction_info) {
    is_last_step = $scope.isLastStepInLinkedCallToAction();
    return (interaction_info.interaction.resource_type != "share" || is_last_step);
  };

  $scope.filterRemovePlayInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type != "play");
  };

  $scope.filterRemoveLikeInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type != "like");
  };

  $scope.filterRemoveLinkInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type != "link");
  };

  $scope.filterRemoveDownloadInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type != "download");
  };

  $scope.filterRemoveVoteInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type != "vote");
  };

  $window.update_ga_event = function(category, action, label, value) {
    if($scope.aux && $scope.aux.current_property_info && $scope.aux.current_property_info.path) {
      category = $scope.aux.current_property_info.path + "_" + category;
    }

    if($scope.google_analytics_code.length > 0) {
      ga('send', 'event', category, action, label, value, true);
    }
  };

  $window.getAnonymousUserStorage = function() {
    return $scope.current_user ? null : JSON.parse(localStorage["anonymous_user_storage"]);
  };

  $window.setAnonymousUserStorageAttr = function(name, value) {
    anonymous_user = getAnonymousUserStorage();
    anonymous_user[name] = value; //eval("anonymous_user." + name + " = " + value);
    localStorage.setItem("anonymous_user_storage", JSON.stringify(anonymous_user));
  };

  $scope.updateAnonymousUserStorageUserInteractions = function(user_interaction) {
    anonymous_user_storage = getAnonymousUserStorage();

    if(!anonymous_user_storage.user_interaction_info_list) {
      anonymous_user_storage.user_interaction_info_list = new Object();
    }

    anonymous_user_storage.user_interaction_info_list[user_interaction.interaction_id] = user_interaction;
    localStorage.setItem("anonymous_user_storage", JSON.stringify(anonymous_user_storage));

  };

  function initAnonymousUserStorage() {
    anonymous_user_storage = new Object();
    localStorage.setItem("anonymous_user_storage", JSON.stringify(anonymous_user_storage));
  }

  $scope.initAnonymousUser = function() {

    if($scope.currentUserEmptyAndAnonymousInteractionEnable() && localStorage["anonymous_user_storage"] == null) {
      initAnonymousUserStorage();      
    } else if ($scope.current_user && localStorage["anonymous_user_storage"] != null) {
      clearAnonymousUserStorage();
    }

    if(!$scope.current_user && $scope.aux.anonymous_interaction) {
      $scope.updateCallToActionInfoWithAnonymousUserStorage();

      if($scope.calltoaction_info) {
        $scope.goToLastLinkedCallToAction();
      }
    }
  };


  function clearAnonymousUserStorage() {
    localStorage.removeItem("anonymous_user_storage");
  }

  $scope.updateCallToActionInfoWithAnonymousUserStorage = function() {
    anonymous_user = getAnonymousUserStorage();
    if(anonymous_user.user_interaction_info_list) {
      angular.forEach(anonymous_user.user_interaction_info_list, function(user_interaction_info) { 
        updateUserInteraction(user_interaction_info.calltoaction_id, user_interaction_info.interaction_id, user_interaction_info.user_interaction);
      });
    }
  };

  function updateUserInteraction(calltoaction_id, interaction_id, user_interaction) {
    calltoaction_info = getCallToActionInfo(calltoaction_id);
    if(calltoaction_info) {
      angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
        if(interaction_info.interaction.id == interaction_id) {
          interaction_info.user_interaction = user_interaction;
        }
      });
    }
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

        $scope.initCallToActionInfoList(data.calltoaction_info_list);
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

      vcode = calltoaction_info.calltoaction.media_data;
      if(vcode.indexOf(",") > -1) {
        $scope.$apply(function() {
          calltoaction_info.calltoaction.vcodes = vcode.split(",");
          calltoaction_info.calltoaction.vcode = calltoaction_info.calltoaction.vcodes[0];
        });
      } else {
        calltoaction_info.calltoaction.vcode = vcode;
      }

      player = new youtubePlayer('main-media-iframe-' + calltoaction_info.calltoaction.id, calltoaction_info.calltoaction.vcode);
      calltoaction_info.calltoaction["player"] = player;

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

  $scope.appendCallToActionOtherParams = function() {
    return null;
  };

  $scope.updateOrderingOtherParams = function() {
    return null;
  };

  $scope.updateOrdering = function(ordering) {

    other_params = $scope.updateOrderingOtherParams();

    ordering_ctas = "/ordering_ctas";
    if($scope.aux.current_property_info && $scope.aux.current_property_info.path) {
      ordering_ctas = "/" + $scope.aux.current_property_info.path + "" + ordering_ctas;
    }

    $scope.ordering_in_progress = true;

    $http.get(ordering_ctas, { params: { "ordering": ordering, "other_params": other_params } })
      .success(function(data) { 
        $scope.calltoaction_ordering = ordering;
        $scope.initCallToActionInfoList(data.calltoaction_info_list);

        if($scope.calltoactions.length >= $scope.calltoactions_count) {
          $("#append-other button").hide();
        } else {
          $("#append-other button").show();
        }

        $scope.ordering_in_progress = false;

      }).error(function() {
        $scope.ordering_in_progress = false;
      });
  };

  $scope.appendCallToAction = function(callback) {

    if($scope.calltoactions.length < $scope.calltoactions_count) {

      $("#append-other button").attr('disabled', true);
      $scope.append_ctas_in_progress = true;

      append_calltoaction_path = "/append_calltoaction";
      if($scope.aux.current_property_info && $scope.aux.current_property_info.path) {
        append_calltoaction_path = "/" + $scope.aux.current_property_info.path + "" + append_calltoaction_path;
      }

      calltoaction_ids_shown = [];
      angular.forEach($scope.calltoactions, function(_info) {
        calltoaction_ids_shown.push(_info.calltoaction.id);
      });

      other_params = $scope.appendCallToActionOtherParams();

      $http.post(append_calltoaction_path, { calltoaction_ids_shown: calltoaction_ids_shown, other_params: other_params, ordering: $scope.calltoaction_ordering })
      .success(function(data) {

        angular.forEach(data.calltoaction_info_list, function(calltoaction_info) {
          $scope.calltoactions.push(calltoaction_info);
          appendYTIframe(calltoaction_info);
        });

        if(!$scope.current_user && $scope.aux.anonymous_interaction) {
          $scope.updateCallToActionInfoWithAnonymousUserStorage();
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
        $scope.append_ctas_in_progress = false;

        if (!angular.isUndefined(callback)) {
          callback();
        }

      });
      
    } else {
      $("#append-other").remove();
    }
    
  };

  $scope.updateYTIframe = function(calltoaction_info, vcode, autoplay) {
    player = calltoaction_info.calltoaction.player;
    if($scope.youtube_api_ready && player) {
      calltoaction_info.calltoaction.vcode = vcode;
      $scope.play_event_tracked[calltoaction_info.calltoaction.id] = false;
      if(autoplay) {
        player.playerManager.loadVideoById(vcode);
      } else {
        player.playerManager.cueVideoById(vcode);
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
      }, 5000);
    }
    // remove getOvervideoInteraction
  }

  function removeOvervideoInteraction(player, calltoaction_id, overvideo_interaction) {

    if(overvideo_interaction.interaction.resource_type == "trivia") {
      overvideo_interaction.question_class = "trivia-interaction__question-fade-out";
      overvideo_interaction.reward_class = "trivia-interaction__reward-fade-out";
      angular.forEach(overvideo_interaction.interaction.resource.answers, function(answer) {
        $timeout(function() { 
          answer.class = "trivia-interaction__answer--visible trivia-interaction__answer-slide-out";
        }, time);
        time += 300;
      });
    } else if(overvideo_interaction.interaction.resource_type == "versus") {
      overvideo_interaction.question_class = "versus-interaction__question-fade-out";
      overvideo_interaction.reward_class = "versus-interaction__reward-fade-out";
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
          getCallToActionInfo(calltoaction_id).active_end_interaction = true;
        }

      }, 1000);
    }, 2000);

  }

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
  }; 
  
  //////////////////////// KALTURA CALLBACK ////////////////////////
  
  function kalturaPlayer(playerId, media_data) {
  	this.playerManager = null;
  	this.playerId = playerId;
  	this.media_data = media_data;

  	player = this;
    
    $scope.KalturaPlayerId = playerId;
    // Update: http://knowledge.kaltura.com/javascript-api-kaltura-media-players#EnablingtheJavascriptAPI
	  kWidget.embed({
  		'targetId': this.playerId,
  		'wid': '_' + $scope.aux.kaltura.partner_id,
  		'uiconf_id': $scope.aux.kaltura.uiconf_id,
  		'entry_id': media_data,
  		'flashvars':{
  			'autoPlay': false,
  			'doubleClick': { 
  				'adTagUrl': "http://analytics.disneyinternational.com/ads/tagsv2/video/?sdk=1&hub=disneychannel.it&site=community&slug1=" + $scope.calltoaction_info.calltoaction.slug + "&sdk=1&cmsid=13728&vid=" + media_data + "&output=xml_vast2&url=http://community.disneychannel.it/call_to_action/" + $scope.calltoaction_info.calltoaction.slug + "&description_url=http://community.disneychannel.it/call_to_action/" + $scope.calltoaction_info.calltoaction,
				'htmlCompanions': 'div-video-mpu:300:250;' 
			}
  		},
  		'params':{
  			'wmode': 'transparent' 
  		},
  		'readyCallback': function( playerId ){
  			kdp = $("#" + playerId).get(0);
  			kdp.addJsListener("playerReady", "onKalturaPlayerReady");
  			kdp.addJsListener("doPlay", "onKalturaPlayEvent");
  			kdp.addJsListener("preSequenceStart", "onKalturaAdvStart");
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

  function getCallToActionIdFromKalturaPlayer(idPlayer) {
    aux = idPlayer.split("-");
    return aux[aux.length - 1];
  }

  $window.onKalturaPlayEvent = function(idPlayer) {  
    calltoaction_id = getCallToActionIdFromKalturaPlayer(idPlayer);
    if(!$scope.play_event_tracked[calltoaction_info.calltoaction.id]) {
      $scope.$apply(function() {
  	    updateStartVideoInteraction(calltoaction_id);
      });
    }
  };
  
  $window.onKalturaAdvStart = function(idPlayer) {
  	calltoaction_id = $scope.calltoaction_info.calltoaction.id;
  	if(!$scope.play_event_tracked[calltoaction_id]) {
      $scope.$apply(function() {
  	    updateStartVideoInteraction(calltoaction_id);
      });
    }
  };
  
  $window.onKalturaVideoEnded = function(idPlayer){
  	calltoaction_id = getCallToActionIdFromKalturaPlayer(idPlayer);
    $scope.$apply(function() {
      updateEndVideoInteraction(calltoaction_id);
    });
  };
  
  $window.kalturaCheckInteraction = function(data, idPlayer) {
	  calltoaction_id = getCallToActionIdFromKalturaPlayer($scope.KalturaPlayerId);//getCallToActionIdFromKalturaPlayer(idPlayer);

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
          plugins: {
            controls: null
          }
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
        }).bind("finish", function(e, api) {
          $scope.$apply(function() {
            updateEndVideoInteraction(fplayer.calltoaction_id);
          }); 
        }).bind("cuepoint", function(e, api, cuepoint) {
          if(!$scope.overvideo_interaction_locked[fplayer.calltoaction_id]) {
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
    interaction_info = getOvervideoEndInteractionInfo(calltoaction_id);
    if(interaction_info) {
      interaction_info.interaction.overvideo_active = true;
      animateInInteraction(interaction_info.interaction);
      if(interaction_info.user_interaction) {
        $timeout(function() { 
          $scope.$apply(function() {
            removeOvervideoInteraction(null, calltoaction_id, interaction_info);
          });
        }, 3000);
      }
    } else {
      getCallToActionInfo(calltoaction_id).active_end_interaction = true;
    }
  };

  $window.updateStartVideoInteraction = function(calltoaction_id, interaction_id) {
    if(!$scope.play_event_tracked[calltoaction_id]) {

      $scope.play_event_tracked[calltoaction_id] = true;

      play_interaction_info = $scope.getPlayInteraction(calltoaction_id);
      if(play_interaction_info == null) {
        console.log("You must enable the play interaction for this calltoaction.");
        return;
      }

      play_interaction_info.hide = true; 

      update_interaction_path = "/update_interaction";
      if($scope.aux.current_property_info && $scope.aux.current_property_info.path) {
        update_interaction_path = "/" + $scope.aux.current_property_info.path + "" + update_interaction_path;
      }

      $http.post(update_interaction_path, { interaction_id: play_interaction_info.interaction.id })
        .success(function(data) {
    
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
            user_interaction_for_storage["user_interaction"] = data.user_interaction;
            user_interaction_for_storage["calltoaction_id"] = calltoaction_id;
            user_interaction_for_storage["interaction_id"] = interaction_id;
  
            $scope.updateAnonymousUserStorageUserInteractions(user_interaction_for_storage);
          } 

          // Interaction after user response.
          if($scope.current_user) {           
            updateUserInteraction(calltoaction_id, interaction_id, data.user_interaction);
            play_interaction_info.status = data.interaction_status;
            calltoaction_info.status = JSON.parse(data.calltoaction_status);
            $scope.current_user.main_reward_counter = data.main_reward_counter;
          }
          
        }).error(function() {
          // ERROR.
        });

    } else {
      // Button play already selected.
    }
  };

  //////////////////////// USER EVENTS METHODS ////////////////////////
  
  $scope.goToLogin = function(){
  	location.href = "/users/sign_up";
  };

  $scope.shareWith = function(calltoaction_info, interaction_info, provider) {
    if($scope.aux.free_provider_share && provider != "email") {
      $scope.shareFree(calltoaction_info, interaction_info, provider);
    } else {
      shareWithApp(calltoaction_info, interaction_info, provider);
    }
   
  };

  function stripTags(text) {
    return String(text).replace(/<[^>]+>/gm, '');
  }

  $scope.shareFree = function(calltoaction_info, interaction_info, provider) {
    if(provider == "direct_url") {
      $("#modal-interaction-" + interaction_info.interaction.id + "-direct_url").modal("show");
    } else {
      message = calltoaction_info.calltoaction.title;
      url_to_share = $scope.computeShareFreeCallToActionUrl(calltoaction_info);

      cta_url = encodeURI(url_to_share);

      switch(provider) {
        case "facebook":    
          share_url = "https://www.facebook.com/sharer/sharer.php?m2w&s=100&p[url]=" + cta_url;
          break;
        case "twitter":
          share_url = "https://twitter.com/intent/tweet?url=" + cta_url + "&text=" + encodeURIComponent(message);
          break;
        case "whatsapp":
          share_url = "whatsapp://send?text=" + encodeURIComponent(message) + " " + cta_url;
          break;
        case "gplus":
          share_url = "https://plus.google.com/share?url=" + cta_url;
          break;
        case "linkedin":
          share_url = "http://www.linkedin.com/shareArticle?mini=true&url=" + cta_url + "&title=" + encodeURIComponent(message) + "&summary=" + encodeURIComponent(stripTags(calltoaction_info.calltoaction.description || ""));
          break;
      }
    }

    if(typeof share_url !== 'undefined') {
      window.open(share_url);
    }
    
    $http.post("/update_basic_share.json", { interaction_id: interaction_info.interaction.id, provider: provider })
      .success(function(data) {
      });

  };

  $scope.computeShareFreeCallToActionUrl = function(calltoaction_info) {
    url_to_share = $scope.aux.root_url + "call_to_action/" + calltoaction_info.calltoaction.slug;
    if($scope.calltoaction_info.calltoaction.extra_fields.linked_result_title) {
      url_to_share = url_to_share + "/" + $scope.calltoaction_info.calltoaction.id;
      message = $scope.calltoaction_info.calltoaction.extra_fields.linked_result_title;
    }
    return url_to_share;
  };

  function shareWithApp(calltoaction_info, interaction_info, provider) {
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

    update_interaction_path = "/update_interaction";
    if($scope.aux.current_property_info && $scope.aux.current_property_info.path) {
      update_interaction_path = "/" + $scope.aux.current_property_info.path + "" + update_interaction_path;
    }

    $http.post(update_interaction_path, { interaction_id: interaction_id, share_with_email_address: share_with_email_address, provider: provider, facebook_message: facebook_message })
      .success(function(data) {

        button.attr('disabled', false);
        button.html(current_button_html);

        if(!data.share.result) { 
          interaction_info.user_interaction.errors = data.share.exception;
          return;
        }

        updateUserInteraction(calltoaction_id, interaction_id, data.user_interaction);
        $scope.current_user.main_reward_counter = data.main_reward_counter;  
        updateUserRewardInView(data.main_reward_counter.general);
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
  }

  $scope.updateAnswer = function(calltoaction_info, interaction_info, params, when_show_interaction, before_callback, before_callback_timeout) {
    if($scope.current_user || $scope.aux.anonymous_interaction) {

      if(!$scope.answer_in_progress) {
        $scope.answer_in_progress = true;

        enableWaitingAudio("stop");

        if(!angular.isUndefined(before_callback)) {
          before_callback();
        }

        if(interaction_info.interaction.resource_type == "download") {
          newWindow = window.open();
        }

        if (!angular.isUndefined(before_callback_timeout)) {
          $timeout(function() {
            $scope.updateAnswerAjax(calltoaction_info, interaction_info, params, when_show_interaction);
          }, before_callback_timeout);
        } else {
          $scope.updateAnswerAjax(calltoaction_info, interaction_info, params, when_show_interaction);
        }

      }
          
    } else {

      showRegistrateView();

    }
  };

  $scope.updateAnswerAjax = function(calltoaction_info, interaction_info, params, when_show_interaction) {
    interaction_id = interaction_info.interaction.id;

    update_interaction_path = "/update_interaction";
    if($scope.aux.current_property_info && $scope.aux.current_property_info.path) {
      update_interaction_path = "/" + $scope.aux.current_property_info.path + "" + update_interaction_path;
    }

    $http.post(update_interaction_path, { interaction_id: interaction_id, params: params, user_interactions_history: $scope.user_interactions_history, anonymous_user_storage: getAnonymousUserStorage() })
      .success(function(data) {
        $scope.updateAnswerAjaxSuccess(data, calltoaction_info, interaction_info, when_show_interaction);
      }).error(function() {
        $scope.answer_in_progress = false;
      });
  };

  $scope.updateAnswerAjaxSuccess = function(data, calltoaction_info, interaction_info, when_show_interaction) {
    calltoaction_id = calltoaction_info.calltoaction.id;
    interaction_id = interaction_info.interaction.id;

    // Google analytics.
    if(data.ga) {
      update_ga_event(data.ga.category, data.ga.action, data.ga.label, 1);
      angular.forEach(data.outcome.attributes.reward_name_to_counter, function(value, name) {
        update_ga_event("Reward", "UserReward", name.toLowerCase(), parseInt(value));
      });
    }

    if($scope.current_user) {

      $scope.current_user.main_reward_counter = data.main_reward_counter;
      updateUserRewardInView(data.main_reward_counter.general);

    } else if($scope.currentUserEmptyAndAnonymousInteractionEnable()) {

      // Update local storage for anonymous user.
      if(data.main_reward_counter) {
        setAnonymousUserStorageAttr($scope.aux.main_reward_name, data.main_reward_counter.general);
      }

      user_interaction_for_storage = new Object();
      user_interaction_for_storage["user_interaction"] = data.user_interaction;
      user_interaction_for_storage["calltoaction_id"] = calltoaction_id;
      user_interaction_for_storage["interaction_id"] = interaction_id;

      $scope.updateAnonymousUserStorageUserInteractions(user_interaction_for_storage);
    } else {
      // Nothing to do.
    }

    // Interaction after user response.
    updateUserInteraction(calltoaction_id, interaction_id, data.user_interaction);
    calltoaction_info.status = JSON.parse(data.calltoaction_status);
    
    if(data.answers) {
      updateAnswersInInteractionInfo(interaction_info, data.answers);
    }

    if(when_show_interaction == "OVERVIDEO_DURING" || when_show_interaction == "OVERVIDEO_END") {
      
      interaction_info.feedback = true;

      if(interaction_info.interaction.resource_type == "trivia") {
        getPlayer(calltoaction_id).play();
        if(interaction_info.interaction.when_show_interaction == "OVERVIDEO_DURING") {
        //       
        }

        $timeout(function() { 
          interaction_info.feedback = false;
          interaction_info.interaction.overvideo_active = false;
          $scope.answer_in_progress = false;
        }, 3000);                

        // Answer exit animation
        //angular.forEach(interaction_info.interaction.resource.answers, function(answer) {
        //  answer.class = "trivia-interaction__answer--visible";
        //});

      } else if(interaction_info.interaction.resource_type == "versus") {

        interaction_info.feedback = true;

        if(interaction_info.interaction.resource_type == "versus") {
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
          interaction_info.feedback = false;
          $timeout(function() { 
            $scope.answer_in_progress = false;
            removeOvervideoInteraction(getPlayer(calltoaction_id), calltoaction_id, interaction_info);
          }, 3000);
        }, 1000);

      } else {
        removeOvervideoInteraction(getPlayer(calltoaction_id), calltoaction_id, interaction_info);
        $scope.answer_in_progress = false;
      }

    } else {
      interaction_info.user_interaction.feedback = data.user_interaction.outcome;

      if(interaction_info.interaction.resource_type == "like") {
        if(JSON.parse(interaction_info.user_interaction.aux)["like"]) {
          interaction_info.interaction.resource.counter += 1;
        } else {
          interaction_info.interaction.resource.counter -= 1;
        } 
      }

      $scope.answer_in_progress = false;
    }
    
    if(interaction_info.interaction.resource_type == "download") {

      if(interaction_info.interaction.resource.ical && !angular.equals(interaction_info.interaction.resource.ical, {})) {
        newWindow.location = "/ical";
      } else {
        newWindow.location = data.download_interaction_attachment;
      }

    } else if(interaction_info.interaction.resource_type == "link") {
      window.location = interaction_info.interaction.resource.url;
    }

    if(interaction_info.interaction.resource_type == "vote") {
      if($scope.currentUserEmptyAndAnonymousInteractionEnable()) {
        interaction_info.anonymous_user_interaction_info = data.user_interaction;
      }
      //interaction_info.interaction.resource.vote_info = data.vote_info;
      interaction_info.interaction.resource.counter_aux = data.counter_aux; 
    }

    // Next calltoaction for test interaction.
    if(data.next_call_to_action_info_list) {
      $scope.linked_call_to_actions_index = $scope.linked_call_to_actions_index + 1;
      if($scope.currentUserEmptyAndAnonymousInteractionEnable()) {
        updateInteractionsHistory(data.user_interaction.interaction_id);
      } else {
        updateInteractionsHistory(data.user_interaction.id);
      }     

      $scope.initCallToActionInfoList(data.next_call_to_action_info_list);
      $scope.calltoaction_info.class = "trivia-interaction__update-answer--hide";
      $timeout(function() { 
        $scope.calltoaction_info.class = "trivia-interaction__update-answer--hide trivia-interaction__update-answer--fade_in";
      }, 200);

    }
  };

  $scope.calculateVoteTotal = function(interaction_info) {
    total = 0;
    angular.forEach(interaction_info.interaction.resource.counter_aux, function(value, key) {
      total = total + (key * value);
    });
    return total;
  };

  $scope.goToLastLinkedCallToAction = function() {
    $scope.parent_calltoaction_info = $scope.calltoaction_info;
    $scope.compute_in_progress = true;

    anonymous_user_storage = getAnonymousUserStorage()
    call_last_linked_calltoaction = false;
    angular.forEach(anonymous_user_storage.user_interaction_info_list, function(user_interaction_info) {
      if(user_interaction_info.calltoaction_id == $scope.calltoaction_info.calltoaction.id && user_interaction_info.user_interaction.aux) {
        aux = JSON.parse(user_interaction_info.user_interaction.aux)
        if(aux["next_calltoaction_id"]) {
          call_last_linked_calltoaction = true;
        }
      }
    });
    
    if(call_last_linked_calltoaction) {
      // Too long for get.
      $http.post("/last_linked_calltoaction", { "anonymous_user_interactions": getAnonymousUserStorage(), "calltoaction_id": $scope.calltoaction_info.calltoaction.id })
      .success(function(data) { 
        if(data.go_on) {
          $scope.initCallToActionInfoList(data.calltoaction_info_list);
          $scope.linked_call_to_actions_index = data.linked_call_to_actions_index;
          $scope.user_interactions_history = data.user_interactions_history;
          $scope.updateCallToActionInfoWithAnonymousUserStorage();
        }
        $scope.compute_in_progress = false;
      }).error(function() {
        $scope.compute_in_progress = false;
      });
    }

  }

  $scope.resetToRedo = function(interaction_info) {
    $scope.calltoaction_info.class = "trivia-interaction__update-answer--fade_out";

    $timeout(function() { 
      anonymous_user_interactions = getAnonymousUserStorage();
      angular.forEach($scope.user_interactions_history, function(index) {
        user_interaction_info = anonymous_user_interactions["user_interaction_info_list"][index];
        if(user_interaction_info) {
          aux_parse = JSON.parse(user_interaction_info.user_interaction.aux);
          aux_parse.to_redo = true;
          user_interaction_info.user_interaction.aux = JSON.stringify(aux_parse);
          $scope.updateAnonymousUserStorageUserInteractions(user_interaction_info);
        }
      });

      $scope.initCallToActionInfoList([$scope.parent_calltoaction_info]);
      $scope.calltoaction_info.hide_class = "";
      $scope.calltoaction_info.class = "trivia-interaction__update-answer--hide"
      $timeout(function() { 
        $scope.calltoaction_info.class = "trivia-interaction__update-answer--hide trivia-interaction__update-answer--fade_in";
      }, 500);

      $scope.linked_call_to_actions_index = 1;
      $scope.user_interactions_history = [];
      $scope.updateCallToActionInfoWithAnonymousUserStorage();
    }, 200);    
  };

  function updateInteractionsHistory(user_interaction_id) {
    if(angular.isUndefined($scope.user_interactions_history)) {
      $scope.user_interactions_history = [];
    } 
    $scope.user_interactions_history.push(user_interaction_id);
  }
  
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
  
  //////////////////////// COLUMN VIEW HELPER ////////////////////////////////////////
  $scope.getNumber = function(num){
		var numArray = [];
		for(i=1; i<= num; i++){
			numArray.push(i);
		}
		return numArray;
	};
	
  //////////////////////// POINTS AND CHECKS FEEDBACK METHODS ////////////////////////

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

    comment_info = new Object();
    comment_info.user_text = interaction_info.interaction.resource.comment_info.user_text;
    comment_info.user_captcha = interaction_info.interaction.resource.comment_info.user_captcha;

    $http.post("/add_comment", { interaction_id: interaction_id, comment_info: comment_info, session_storage_captcha: session_storage_captcha })
      .success(function(data) {
        if(data.errors) {
          alert("ERROR");
        } else if(!$scope.current_user && !data.captcha_evaluate) {
          $("#comment-captcha-error").modal("show");
          interaction_info.interaction.captcha = "data:image/jpeg;base64," + data.captcha.image;
          interaction_info.interaction.resource.comment_info.user_captcha = "";
          sessionStorage.setItem("captcha" + interaction_info.interaction.id, data.captcha.code);
        } else if(!data.approved) {
          $("#comment-feedback").modal("show");
          
          data.comment.id = new Date().getTime();
          interaction_info.interaction.resource.comment_info.comments.unshift(data.comment);

          interaction_info.interaction.resource.comment_info.user_text = "";
          interaction_info.interaction.resource.comment_info.user_captcha = "";
          if(!$scope.current_user) {
            interaction_info.interaction.captcha = "data:image/jpeg;base64," + data.captcha.image;
          }

          // GOOGLE ANALYTICS
          if(data.ga) {
            update_ga_event(data.ga.category, data.ga.action, data.ga.label, 1);
          }

        } else {
          interaction_info.interaction.resource.comment_info.comments.unshift(data.comment);

          interaction_info.interaction.resource.comment_info.user_text = "";
          interaction_info.interaction.resource.comment_info.user_captcha = "";
          if(!$scope.current_user) {
            interaction_info.interaction.captcha = "data:image/jpeg;base64," + data.captcha.image;
          }

          // GOOGLE ANALYTICS
          if(data.ga) {
            update_ga_event(data.ga.category, data.ga.action, data.ga.label, 1);
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
  
  $scope.buyReward = function(reward_id){
  	$http.post("/reward/buy" , { reward_id: reward_id })
	    .success(function(data) { 
	    	console.log(data);
	      $(".cta-preview__locked-layer--reward").html(data.html);
	    }).error(function() {
	      // ERROR.
	    });
  };

  $scope.computeMonthName = function(n, language) {
    if(language == "en") {
      monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 
        'July', 'August', 'September', 'October', 'November', 'December'];
    } else {
      monthNames = ['gennaio', 'febbraio', 'marzo', 'aprile', 'maggio', 'giugno', 
        'luglio', 'agosto', 'settembre', 'ottobre', 'novembre','dicembre'];
    }
    return monthNames[n];
  };
  
  $scope.computeDayName = function(n, language) {
    if(language == "en") {
      dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    } else {
      dayNames = ['domenica', 'lunedì', 'martedì', 'mercoledì', 'giovedì', 'venerdì', 'sabato'];
    }
    return dayNames[n];
  };

  $scope.formatDate = function(date, language) {
    date = new Date(date);
    return date.getDate() + " " + $scope.computeMonthName(date.getMonth(), language) + " " + date.getFullYear();
  };
  
  $scope.formatFullDate = function(date, language) {
    date = new Date(date);
    return $scope.computeDayName(date.getDay(), language) + " " + date.getDate() + " " + $scope.computeMonthName(date.getMonth(), language) + " " + date.getFullYear();
  };

  $scope.extractTimeFromDate = function(date) {
    date = new Date(date);
    return ("0" + date.getHours()).slice(-2) + ":" +("0" + date.getMinutes()).slice(-2);
  };

  //////////////////////// CAPTCHA ////////////////////////

  function initCaptcha() {
    interaction_info_list = getStreamCommentInteractions();
    if(interaction_info_list.length > 0) {
      $http.get("/captcha" , { params: { "interaction_info_list[]": interaction_info_list }})
        .success(function(data) { 
          initSessionStorageAndCaptchaImage(data);
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