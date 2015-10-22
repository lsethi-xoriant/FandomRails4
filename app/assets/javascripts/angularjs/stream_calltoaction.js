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

var OVERVIDEO_COUNTDOWN_ANIMATION_TIME = 3;

function StreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document, $upload) {

  $scope.getUploadExtraFieldProcessor = function(field, processor) {
    if(field) {
      var parts = field.url.split('/');
      parts[parts.length-2] = processor;
      console.log(parts.join('/'));
      return parts.join('/');
    } 
  };

  $scope.isIE = function() {
    var myNav = navigator.userAgent.toLowerCase();
    return (myNav.indexOf('msie') != -1) ? parseInt(myNav.split('msie')[1]) : false;
  };

  $scope.isOdd = function(index) {
    return (index % 2 == 1);
  };

  $scope.groupingArr = function(name, arr, group_size) {
    if(angular.isUndefined($scope.groupingArrs[name])) {
      groupingArr = []; tmpArr = [];
      index = 1;
      angular.forEach(arr, function(el) {
        tmpArr.push(el);
        if(index % group_size == 0 || index == arr.length) {
          groupingArr.push(tmpArr);
          tmpArr = [];
        }
        index++;
      });
      $scope.groupingArrs[name] = groupingArr;
    }
    return $scope.groupingArrs[name];
  };

  $scope.getGroupingGalleries = function(arr) {
    if(angular.isUndefined($scope.groupingGalleryArrs)) {
      setGroupingGalleries(arr);
    }
    return $scope.groupingGalleryArrs;
  };

  function setGroupingGalleries(arr) {
    $scope.groupingGalleryArrs = [];
    lArr = []; rArr = [];
    index = 0;
    angular.forEach(arr, function(el) {
      if(index % 2 == 0) {
        lArr.push(el);
      } else {
        rArr.push(el);
      }
      index++;
    });

    $scope.groupingGalleryArrs.push(lArr);
    $scope.groupingGalleryArrs.push(rArr); 
  }


  $scope.iwWin = function() {
    return ($scope.aux.instant_win_info.win == true);
  };

  $scope.iwNotWin = function() {
    return ($scope.aux.instant_win_info.win == false);
  };

  $scope.ticketsEmpty = function() {
    return ($scope.aux.instant_win_info.win == null && $scope.current_user && $scope.current_user.instantwin_tickets_counter < 1);
  };

  function unsetPins(cta_info) {
    angular.forEach(cta_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(interaction_info.interaction.resource_type == "pin") {
        interaction_info.active = false;
      }
    });
    $(".cta-" + calltoaction_info.calltoaction.id + "-pin").popover("destroy");
  }

  $scope.updatePin = function(calltoaction_info, interaction_info, params, when_show_interaction) {
    if($scope.aux.mobile) {
      $("#pin-" + interaction_info.interaction.id).modal("show");
    } else {
      if(interaction_info.active) {
        unsetPins(calltoaction_info);
      } else {
        unsetPins(calltoaction_info);
        $("#pin-btn-" + interaction_info.interaction.id).popover("show");
        $scope.updateAnswer(calltoaction_info, interaction_info, params, when_show_interaction);
        interaction_info.active = true;
      }
    }    
  };

  $scope.fromCodeToHtml = function(code) {
    return "&#" + code + ";";
  };

  $scope.addEmoticonToComment = function(emoticon, comment_info) {
    if(angular.isUndefined(comment_info.user_text)) {
      comment_info.user_text = String.fromCodePoint(emoticon);
    } else {
      comment_info.user_text = comment_info.user_text + "" + String.fromCodePoint(emoticon);
    }
  };

  function adjustPercentageAnimation(times, percentage, cta_info) {
    $("#percentage_circle_value_" + cta_info.calltoaction.id).html(times);
    percentage_circle_name = "#percentage_circle_" + cta_info.calltoaction.id;

    if(percentage < 100) {
      $(percentage_circle_name).removeClass("p" + percentage);
      percentage = percentage + 1;
      $(percentage_circle_name).addClass("p" + percentage);
      setTimeout(function(){
        adjustPercentageAnimation(times, percentage, cta_info);
      }, 10);
    } else if(times > 1) {
      preinteractionAnimationSound();
      $(percentage_circle_name).removeClass("p" + percentage);
      adjustPercentageAnimation((times - 1), 0, cta_info);
    } else {
      preinteractionAnimationSound();
      cta_info.percentage_animation = false;
    }
  }

  $scope.zerosBeforeNumber = function(number, zero_length) {
    for (i = 0; i < zero_length; i++) { 
      number = "0" + number;
    }
    return number.slice(-(zero_length + 1));
  };

  $scope.updateUserWithAvatar = function () {
    delete $scope.form_data.r_current_user.errors;

    ajax_url = "/profile/update_user";

    if($scope.form_data.r_current_user._avatar) {
      $upload.upload({
          url: ajax_url,
          fields: { obj: $scope.form_data.r_current_user },
          file: $scope.form_data.r_current_user._avatar[0],
          fileFormDataName: ["avatar"]
        }).progress(function (evt) {
            var progressPercentage = parseInt(100.0 * evt.loaded / evt.total);
            if(!$scope.form_data['vcode'])
              $scope.form_data.progress = progressPercentage; // evt.config.file[0].progress
        }).success(function (data, status, headers, config) {
            if(data.errors) {
              $scope.form_data.r_current_user.errors = data.errors;
            } else {
              updateUserWithAvatarSuccess(data);
            }
            delete $scope.form_data.progress;
        }).error(function (data, status, headers, config) {
          if(status == "413") { //413 (Request Entity Too Large)
            $scope.form_data.r_current_user.errors = "Ricorda che il tuo file non deve pesare più di 100MB";
          } else {
            $scope.form_data.r_current_user.errors = status;
          }
          delete $scope.form_data.progress;
        });
    } else {
      $http({ method: 'POST', url: ajax_url, data: { obj: $scope.form_data.r_current_user } })
        .success(function(data) {
          if(data.errors) {
            $scope.form_data.r_current_user.errors = data.errors;
          } else {
            updateUserWithAvatarSuccess(data);
          }
        });
    }
  };

  function updateUserWithAvatarSuccess(data) {
    $scope.current_user = data.current_user;

    if($scope.aux.instant_win_info.user) {
      $scope.aux.instant_win_info.user.first_name = $scope.current_user.first_name;
      $scope.aux.instant_win_info.user.last_name = $scope.current_user.last_name;
    }

    $("#modal-update-user").modal("hide");
    $("#modal-update-user-pt2").modal("show");
  }

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
  $scope.upload = function (files, url, extra_fields, upload_interaction) {
    delete $scope.form_data.errors;
    $scope.form_data.errors = getFormUploadErrors(files, extra_fields, upload_interaction);
    if(!$scope.form_data.errors) {

      if(!upload_interaction.interaction.resource.upload_info.releasing.required) {
        file_param = files[0];
        file_form_data_params = ["attachment"];
      } else {
        file_param = files;
        file_form_data_params = ["attachment", "releasing"];
      }

      $upload.upload({
          url: url,
          fields: { obj: $scope.form_data },
          file: file_param,
          fileFormDataName: file_form_data_params
        }).progress(function (evt) {
            var progressPercentage = parseInt(100.0 * evt.loaded / evt.total);
            if(!$scope.form_data['vcode'])
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

  function getFormUploadErrors(files, extra_fields, upload_interaction) {
    
    errors = [];

    if(!angular.equals(extra_fields, {})) {
      angular.forEach(extra_fields, function(extra_field) {
        if(extra_field['required'] && !$scope.form_data[extra_field['name']]) {
          errors.push(extra_field['label']);
        }
      });
    }

    if(!$scope.form_data['title']) { 
      errors.push("Titolo non può essere lasciato in bianco");
    }

    if(!files[0] && !$scope.form_data['vcode']) {
      errors.push("Il media deve essere caricato");
    }

    if(files[0] && files[0].type == "application/zip") {
      errors.push("Formato del media non valido");
    }

    if(!files[1] && upload_interaction.interaction.resource.upload_info.releasing.required) {
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
      if(fileReaderSupported() && file.type.indexOf('image') > -1) {
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

  $scope.isAnchor = function(url) {
    return (url.charAt(0) == "#");
  };

  $scope.scrollTo = function(id) {
    if(id.charAt(0) == "#") {
      id = id.substring(1);
    }

    $('html, body').animate({
      scrollTop: $("#" + id).offset().top
    }, 500);
  };

  $scope.getUserInteractionsHistory = function(cta_info) {
    if(cta_info.optional_history) {
      return cta_info.optional_history.user_interactions;
    } else {
      return null;
    }
  };

  $scope.getParentCtaId = function(cta_info) {
    return $scope.getParentCtaInfo(cta_info).calltoaction.id;
  };

  $scope.getParentCtaInfo = function(cta_info) {
    if(cta_info.optional_history && cta_info.optional_history.parent_cta_info) {
      return cta_info.optional_history.parent_cta_info;
    } else {
      return cta_info;
    }
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

  $scope.replaceCallToActionInCallToActionInfoList = function(old_calltoaction_info, new_calltoaction_info) {
    calltoaction_info_list = [];
    angular.forEach($scope.calltoactions, function(cta_info) {
      if(cta_info.calltoaction.id == old_calltoaction_info.calltoaction.id) {
        calltoaction_info_list.push(new_calltoaction_info);
      } else {
        calltoaction_info_list.push(cta_info);
      }
    });
    $scope.initCallToActionInfoList(calltoaction_info_list);
  };

  $scope.initCallToActionInfoList = function(calltoaction_info_list) {
    $scope.calltoactions = calltoaction_info_list;
    if($scope.calltoactions.length == 1) {
      $scope.calltoaction_info = $scope.calltoactions[0];

      if($scope.calltoaction_info.calltoaction.disqus) {  
        $window.disqus_shortname = $scope.calltoaction_info.calltoaction.disqus.shortname; 

        var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
        dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js?https';
        (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
      }
    }
  };

  function getOrigResourceType(resource_type) {
    if(resource_type == "versus" || resource_type == "quiz" || resource_type == "test" || resource_type == "trivia") {
      return "quiz";
    } else {
      return resource_type;
    }
  }

  function interactionAllowed(interaction_info) {
    if(!$scope.isAnonymousUser()) {
      return true;
    } else {
      resource_type = getOrigResourceType(interaction_info.interaction.resource_type);
      interaction_enabled_for_anonymous = isAnonymousNavigationEnabled() && $scope.aux.site.attributes.interactions_for_anonymous.indexOf(resource_type) > -1;
      registration_needed = interaction_info.interaction.registration_needed;
      return interaction_enabled_for_anonymous && !registration_needed;
    }
  }

  function isAnonymousNavigationEnabled() {
    return ($scope.aux.site.attributes.interactions_for_anonymous != null);
  }

  function isEmpty(str) {
    return (!str || 0 === str.length);
  }

  function loadYTApi() {
    var tag = document.createElement('script');
    tag.src = "//www.youtube.com/iframe_api";
    var firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
  }

  function isStoredAnonymousUser() {
    return ($scope.current_user && $scope.current_user.anonymous_id);
  }

  $scope.isAnonymousUser = function() {
    return (!$scope.current_user || !isEmpty($scope.current_user.anonymous_id));
  };

  $scope.init = function(current_user, calltoaction_info_list, has_more, calltoactions_during_video_interactions_second, google_analytics_code, current_calltoaction, aux) {
    FastClick.attach(document.body);

    $scope.aux = aux;
    $scope.current_user = current_user;

    $scope.initCallToActionInfoList(calltoaction_info_list);

    $scope.answer_in_progress = false;

    $scope.groupingArrs = {};

    $scope.calltoaction_ordering = "recent";

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

    if($scope.aux.init_captcha) {
      initCaptcha();
    }

    $scope.form_data = {};

    $scope.animation_in_progress = false;

    $scope.interactions_timeout = {};
    $scope.overvideo_interaction_locked = {};
    $scope.secondary_video_players = {};
    $scope.play_event_tracked = {};
    $scope.current_user_answer_response_correct = {};
    $scope.current_calltoaction = current_calltoaction;
    $scope.google_analytics_code = google_analytics_code;
    $scope.polling = false;
    $scope.youtube_api_ready = false;

    if($scope.aux.from_registration) {
      $scope.welcomeFeedback();
      $scope.update_ga_event("Registration", "Registration", "Registration", 1);
    }
    
    loadYTApi();
    if($scope.aux.kaltura && $scope.calltoaction_info != undefined && $scope.calltoaction_info.calltoaction.media_type == "KALTURA") {
      kaltura_api_link = "http://cdnapi.kaltura.com/p/" + $scope.aux.kaltura.partner_id + "/sp/" + $scope.aux.kaltura.partner_id + "00/embedIframeJs/uiconf_id/" + $scope.aux.kaltura.uiconf_id + "/partner_id/" + $scope.aux.kaltura.partner_id;
      var tag = document.createElement('script');
      tag.src = kaltura_api_link;
      var firstScriptTag = document.getElementsByTagName('script')[0];
      firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
      initKalturaApi();
    }
    
    $(function(){ flowplayerReady(); });

    $scope.has_more = has_more;

    $scope.extraInit();

  };

  $scope.welcomeFeedback = function() {
    $("#registration-modal").modal("show");
  };

  $scope.extraInit = function() {
  };
  
  $window.playSound = function(element){
  	element.load();
  	element.play();
  };

  $scope.acceptCookies = function() {
    $http.post($scope.updatePathWithProperty("/user_cookies"))
      .success(function(data) { 
        $("#cookies-bar").fadeOut("slow");
      }).error(function() {
        // ERROR.
      });
  };

  $scope.linkTo = function(url) {
    default_property = $scope.aux.site.attributes.default_property;

    if(url == "/" + default_property) {
      return "/";
    } else if($scope.aux.context_root && url.indexOf("/" + $scope.aux.context_root + "/") < 0) {
      url = "/" + $scope.aux.context_root + "" + url;
    }
    
    return url;
  };

  $scope.updatePathWithProperty = function(path) {
    if($scope.aux.property_path_name) {
      path = "/" + $scope.aux.property_path_name + "" + path;
    }
    return path;
  };

  $scope.playInstantWin = function() {
    $scope.update_ga_event("PlayInstantWin", "PlayInstantWin", "PlayInstantWin", 1);
    $scope.aux.instant_win_info.in_progress = true;
    delete $scope.aux.instant_win_info.win;
    $http.post("/play", { interaction_id: $scope.aux.instant_win_info.interaction_id })
      .success(function(data) { 

        if(data.active == false) {
          $scope.aux.instant_win_info.active = data.active;
          return;
        }
        
        if(data.win == true) {
          image = $scope.aux.assets.extra_fields.iw_win;
          time = parseInt($scope.aux.assets.extra_fields["iw_win_time"]);
        } else {
          iw_wrong_index = Math.floor((Math.random() * 2) + 1);
          image = $scope.aux.assets.extra_fields["iw_wrong" + iw_wrong_index];
          time = parseInt($scope.aux.assets.extra_fields["iw_wrong" + iw_wrong_index + "_time"]);
        }

        $("#iw_slot").attr("src", image);

        if($scope.aux.assets.extra_fields.iw_running_sound) {
          runningSound("iw-running-sound", "play");
        }

        $scope.current_user.instantwin_tickets_counter = data.instantwin_tickets_counter;

        $timeout(function() { 
          $scope.aux.instant_win_info.in_progress = false;
          $scope.aux.instant_win_info.message = data.message;
          $scope.aux.instant_win_info.win = data.win;

          if($scope.aux.assets.extra_fields.iw_running_sound) {
            runningSound("iw-running-sound", "pause");
          }

          if($scope.aux.assets.extra_fields.iw_ending_sound_win && $scope.aux.assets.extra_fields.iw_ending_sound_wrong) {
            if(data.win == true) {
              runningSound("iw-ending-sound-win", "play");
            } else {
              runningSound("iw-ending-sound-wrong", "play");
            }
          }

        }, time);
      }).error(function() {
        // ERROR.
      });
  };

  function preinteractionAnimationSound() {
    runningSound("preinteraction-sound", "play");
  }

  function interactionButtonSound() {
    runningSound("interaction-button-sound", "play");
  }

  function runningSound(sound_class, status) {
    $("." + sound_class).trigger(status);
  }

  $scope.openInstantWinModal = function() {
    if($scope.aux.instant_win_info.win == false) {
      delete $scope.aux.instant_win_info.win;
    }

    if($scope.aux.instant_win_info.win == true) {
      $("#iw_slot").attr("src", $scope.aux.assets.extra_fields.iw_cover_winner.url);
    } else {
      $("#iw_slot").attr("src", $scope.aux.assets.extra_fields.iw_cover.url);
    }

  	//$(".click-sound").trigger("play");
    $("#modal-interaction-instant-win").modal("show");
  };

  $scope.propagateClickOnFileUploadInput = function() {
    $("#upload-input").click();
  }

  $scope.openRegistrationModalForInstantWin = function() {
    $scope.form_data.current_user = $scope.aux.instant_win_info.user;
    $("#modal-interaction-instant-win-registration").modal("show");
  };

  $scope.processRegistrationForm = function() {
    delete $scope.form_data.current_user.errors;
    if(!$scope.ajax_in_progress) {
      $scope.ajax_in_progress = true;
      data = { user: $scope.form_data.current_user, interaction_id: $scope.aux.instant_win_info.interaction_id };
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
            $scope.current_user.first_name = $scope.form_data.current_user.first_name;
            $scope.current_user.last_name = $scope.form_data.current_user.last_name;
          }
          $scope.ajax_in_progress = false;
        }).error(function() {
          $scope.ajax_in_progress = false;
        });
    }
  };

  function isOvervideoDuring(when_show_interaction) {
    return (when_show_interaction == "OVERVIDEO_DURING" || when_show_interaction == "OVERVIDEO_DURING_WITH_CHAPTERING");
  }

  function setOvervideoInteractionsAsInactive(calltoaction_info) {
    angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(isOvervideoDuring(interaction_info.interaction.when_show_interaction)) {
        interaction_info.interaction.overvideo_active = false;
      }
    });
    calltoaction_info.percentage_animation = false;
    $scope.overvideo_interaction_locked[calltoaction_info.calltoaction.id] = false;
    if(cta_info.overvideo_interaction_timeout) {
      $timeout.cancel(cta_info.overvideo_interaction_timeout);
    }
  }

  function getOvervideoInteractionAtSeconds(calltoaction_id, seconds) {
    var overvideo_interaction = null;
    calltoaction_info = getCallToActionInfo(calltoaction_id);
    angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(isOvervideoDuring(interaction_info.interaction.when_show_interaction) && interaction_info.interaction.seconds == seconds) {
        overvideo_interaction = interaction_info;
      }
    });
    return overvideo_interaction;
  }
  
  function getOvervideoInteractions(calltoaction_id) {
    overvideo_interactions = [];
    calltoaction_info = getCallToActionInfo(calltoaction_id);
    angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(isOvervideoDuring(interaction_info.interaction.when_show_interaction)) {
        overvideo_interactions.push( { time: interaction_info.interaction.seconds, interaction: interaction_info});
      }
    });
    return overvideo_interactions;
  }

  $scope.computeAvgForVote = function(interaction_info) {
    numerator = 0; denominator = 0;
    counter_aux = interaction_info.interaction.resource.counter_aux;
    if(counter_aux && !angular.equals(counter_aux, {})) {
      angular.forEach(counter_aux, function(value, key) {
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

  $scope.shareInteractionPresent = function(calltoaction_info) {
    interaction_present = false;
    angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(interaction_info.interaction.resource_type == "share") {
        calltoaction_info.share_interaction_info = interaction_info;
        interaction_present = true;
      }
    });
    return interaction_present;
  };

  $scope.pinInteractionPresent = function(calltoaction_info) {
    interaction_present = false;
    angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(interaction_info.interaction.resource_type == "pin") {
        calltoaction_info.share_interaction_info = interaction_info;
        interaction_present = true;
      }
    });
    return interaction_present;
  };

  $scope.voteInteractionPresent = function(calltoaction_info) {
    interaction_present = false;
    angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(interaction_info.interaction.resource_type == "vote") {
        calltoaction_info.vote_interaction_info = interaction_info;
        interaction_present = true;
      }
    });
    return interaction_present;
  };

  $scope.likeInteractions = function(cta_info) {
    if($scope.likeInteractionPresent(cta_info)) {
      return [cta_info.like_interaction_info];
    } else {
      return [];
    }
  };

  $scope.likeInteractionPresent = function(calltoaction_info) {
    parent_cta_info = $scope.getParentCtaInfo(calltoaction_info);
    angular.forEach(parent_cta_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(interaction_info.interaction.resource_type == "like") {
        calltoaction_info.like_interaction_info = interaction_info;
      }
    });
    return angular.isDefined(calltoaction_info.like_interaction_info);
  };

  $scope.commentInteractions = function(cta_info) {
    if($scope.commentInteractionPresent(cta_info)) {
      return [cta_info.comment_interaction_info];
    } else {
      return [];
    }
  };

  $scope.commentInteractionPresent = function(calltoaction_info) {
    parent_cta_info = $scope.getParentCtaInfo(calltoaction_info);
    angular.forEach(parent_cta_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(interaction_info.interaction.resource_type == "comment") {
        calltoaction_info.comment_interaction_info = interaction_info;
      }
    });
    return angular.isDefined(calltoaction_info.comment_interaction_info);
  };

  $scope.overvideoInteractionsPresent = function(calltoaction_id) {
    overvideo_interaction_present = false;
    calltoaction_info = getCallToActionInfo(calltoaction_id);
    angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(isOvervideoDuring(interaction_info.interaction.when_show_interaction) || interaction_info.interaction.when_show_interaction == "OVERVIDEO_END") {
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

  $scope.goToRankingPage = function(page) {
    if(page != "...") {
      $http.get("/update_ranking_pagination", { params: { "page": page }})
        .success(function(data) { 
          $scope.aux.ranking_info = data.ranking_info;
        }).error(function() {
        });
    }
  };

  $scope.getPaginationPagesBefore = function(page, num_pages){
    if(page == 1) {
      return [];
    } else if(page == 2) {
      return [1];
    } else if (page > 3) {
      return [1, "...", page - 2, page - 1];
    } else {
      return [page - 2, page - 1];
    }
  };

  $scope.getPaginationPagesAfter = function(page, num_pages){
    if(page == num_pages) {
      return [];
    } else if(page == num_pages - 1) {
      return [num_pages];
    } else if (page < num_pages - 2) {
      return [page + 1, page + 2, "...", num_pages];
    } else {
      return [page + 1, page + 2];
    }
  };
  
  $scope.getNumber = function(num) {
    return new Array(num);   
  };

  $scope.isInteractionPresent = function(calltoaction_info, resource_type) {
    interaction_info = getInteraction(calltoaction_info.calltoaction.id, resource_type);
    if(interaction_info) {
      return true;
    } else {
      return false
    }
  };

  $scope.getInteraction = function(calltoaction_info, resource_type) {
    return getInteraction(calltoaction_info.calltoaction.id, resource_type);
  };

  $scope.isCommentEmpty = function(calltoaction_info) {
    interaction_info = getCommentInteraction(calltoaction_info.calltoaction.id);
    if(interaction_info) {
      return !(interaction_info.interaction.resource.comment_info && interaction_info.interaction.resource.comment_info.comments_total_count > 0);
    } else {
      return true;
    }
  };

  $scope.isCommentLikePressed = function(comment_id) {
    if(calltoaction_info.commentlike_interaction_info.user_interaction) {
      return (calltoaction_info.commentlike_interaction_info.user_interaction.aux.comment_active_ids.indexOf(comment_id) > -1);
    } else {
      return false;
    }
  };

  $scope.refreshCommentLikeCounter = function(calltoaction_info, comment_id, value) {
    var commentInteraction = getInteraction(calltoaction_info.calltoaction.id, "comment");
    var comments = commentInteraction.interaction.resource.comment_info.comments;
    angular.forEach(comments, function(comment) {
      if(comment.id == comment_id) {
        comment.like_counter += value;
      }
    });
  };

  $scope.initOrRefreshCommentLikeInteractionInfo = function(calltoaction_info) {
    calltoaction_info.commentlike_interaction_info = getInteraction(calltoaction_info.calltoaction.id, "commentlike");
  };

  $scope.getComments = function(calltoaction_info) {
    $scope.initOrRefreshCommentLikeInteractionInfo(calltoaction_info);
    comment_interaction_info = getInteraction(calltoaction_info.calltoaction.id, "comment");
    return comment_interaction_info.interaction.resource.comment_info.comments;
  };

  $scope.isCommentInteractionPresent = function(calltoaction_info) {
    interaction_info = getCommentInteraction(calltoaction_info.calltoaction.id);
    if(interaction_info) {
      return true
    } else {
      return false;
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

  $scope.getTestInteraction = function(cta_info) {
    result = null;
    angular.forEach(cta_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(interaction_info.interaction.resource_type == "test") {
        result = interaction_info;
      }
    });
    return result;
  };

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

  $scope.getUploadInteraction = function(calltoaction_info) {
    return getInteraction(calltoaction_info.calltoaction.id, "upload");
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

  $scope.filterTestInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type == "test");
  };

  $scope.evaluateVote = function(interaction_info) {
    if(angular.isDefined(interaction_info) && interaction_info.user_interaction && interaction_info.user_interaction.aux) {
      return interaction_info.user_interaction.aux["vote"];
    } else {
      return null;
    }
  };

  $scope.likePressed = function(interaction_info) {
    if(angular.isDefined(interaction_info) && interaction_info.user_interaction && interaction_info.user_interaction.aux) {
      return interaction_info.user_interaction.aux["like"];
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

  $scope.filterPinInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type == "pin");
  };

  $scope.excludePinInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type != "pin");
  };


  $scope.filterOvervideoDuringInteractions = function(interaction_info) {
    return (isOvervideoDuring(interaction_info.interaction.when_show_interaction) || interaction_info.interaction.when_show_interaction == "OVERVIDEO_END");
  };

  $scope.filterVisibleInteractionsUnderMedia = function(interaction_info) {
    return filterVisibleInteractionsByPositioning(interaction_info, "UNDER_MEDIA");
  };

  $scope.filterVisibleInteractionsOverMedia = function(interaction_info) {
    return filterVisibleInteractionsByPositioning(interaction_info, "OVER_MEDIA"); 
  };

  function filterVisibleInteractionsByPositioning(interaction_info, positioning) {
    return $scope.filterAlwaysVisibleInteractions(interaction_info) && interaction_info.interaction.interaction_positioning == positioning;
  }

  $scope.filterAlwaysVisibleInteractions = function(interaction_info) {
    return (interaction_info.interaction.when_show_interaction == "SEMPRE_VISIBILE");
  };

  $scope.filterOvervideoDuringActiveInteraction = function(interaction_info) {
    return interaction_info.interaction.overvideo_active;
  };

  $scope.filterRemoveShareInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type != "share");
  };

  $scope.hasCtaHistory = function(cta_info) {
    return (cta_info.optional_history != null && cta_info.optional_history.optional_total_count != null);
  };

  $scope.isLastStepInLinkedCallToAction = function(cta_info) {
    return $scope.hasCtaHistory(cta_info) && cta_info.optional_history.optional_total_count == cta_info.optional_history.optional_index_count; 
  };

  $scope.removeShareInteractionsExceptLastStep = function(cta_info, interaction_info) {
    is_last_step = $scope.isLastStepInLinkedCallToAction(cta_info);
    return (interaction_info.interaction.resource_type != "share" || is_last_step);
  };

  $scope.filterRemovePlayInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type != "play");
  };

  $scope.filterRemoveLikeInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type != "like");
  };

  $scope.filterRemoveCommentInteractions = function(interaction_info) {
    return (interaction_info.interaction.resource_type != "comment");
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

  $scope.update_ga_event = function(category, action, label, value) {
    if($scope.aux.property_path_name) {
      category = $scope.aux.property_path_name + "_" + category;
    }

    if($scope.google_analytics_code.length > 0) {
      ga('send', 'event', category, action, label, value, true);
    }
  };

  function currentPointRewardName() {
    if($scope.aux.property_path_name) {
      return ($scope.aux.property_path_name + "-point");
    } else {
      return "point";
    }
  };

  function adjustInteractionWithUserInteraction(calltoaction_id, interaction_id, user_interaction_info) {
    calltoaction_info = getCallToActionInfo(calltoaction_id);
    if(calltoaction_info) {
      angular.forEach(calltoaction_info.calltoaction.interaction_info_list, function(interaction_info) {
        if(interaction_info.interaction.id == interaction_id) {
          interaction_info.user_interaction = user_interaction_info;
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
    
        $("#calltoaction-stream").html(data.calltoactions_render);

        angular.forEach($scope.calltoactions, function(sc) {
          appendYTIframe(sc);
        });

        updateSecondaryVideoPlayers($scope.calltoactions);

        $scope.has_more = data.has_more;
		
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

  function appendChaptering(duration, cta_info) {
    chaptering = [];
    angular.forEach(cta_info.calltoaction.interaction_info_list, function(interaction_info) {
      if(interaction_info.interaction.when_show_interaction == "OVERVIDEO_DURING_WITH_CHAPTERING") {
        chaptering.push({
          id: interaction_info.interaction.id,
          position: ((interaction_info.interaction.seconds * 100) / duration),
          second: interaction_info.interaction.seconds,
          active: false
        });
      }
    });
    if(chaptering.length > 0) {
      $scope.$apply(function() {
        cta_info.chaptering = chaptering;
      });
    }
  }

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

      yt_player = new youtubePlayer('main-media-iframe-' + calltoaction_info.calltoaction.id, calltoaction_info.calltoaction.vcode);
      calltoaction_info.calltoaction["player"] = yt_player;

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
    return otherParamsForGallery();
  };

  $scope.updateOrderingOtherParams = function() {
    return otherParamsForGallery();
  };

  function otherParamsForGallery() {
    if($scope.aux.gallery_calltoaction) {
      other_params = { gallery: {} };
      if($scope.aux.gallery_user){
        other_params.gallery.user = $scope.aux.gallery_user.id;
      }
      if($scope.aux.gallery_calltoaction.calltoaction) {
        other_params.gallery.calltoaction_id = $scope.aux.gallery_calltoaction.calltoaction.id;
      } else {
        other_params.gallery.calltoaction_id = "all";
      }
      return other_params;
    } else {
      return null;
    } 
  }

  $scope.updateOrdering = function(ordering) {

    other_params = $scope.updateOrderingOtherParams();

    ordering_ctas = $scope.updatePathWithProperty("/ordering_ctas");

    $scope.ordering_in_progress = true;

    $http.get(ordering_ctas, { params: { "ordering": ordering, "other_params": other_params }})
      .success(function(data) { 
        $scope.calltoaction_ordering = ordering;
        $scope.initCallToActionInfoList(data.calltoaction_info_list);

        $scope.has_more = data.has_more;

        $scope.ordering_in_progress = false;

        if($scope.aux.gallery_calltoaction) {
          setGroupingGalleries($scope.calltoactions);
        }

      }).error(function() {
        $scope.ordering_in_progress = false;
      });
  };

  $scope.appendCallToAction = function(callback) {

    $("#append-other button").attr('disabled', true);
    $scope.append_ctas_in_progress = true;

    append_calltoaction_path = $scope.updatePathWithProperty("/append_calltoaction");

    calltoaction_ids_shown = [];
    angular.forEach($scope.calltoactions, function(_info) {
      calltoaction_ids_shown.push(_info.calltoaction.id);
    });

    other_params = $scope.appendCallToActionOtherParams();

    $http.post(append_calltoaction_path, { calltoaction_ids_shown: calltoaction_ids_shown, other_params: other_params, ordering: $scope.calltoaction_ordering, exclude_cta_with_ids: $scope.aux.exclude_cta_with_ids })
    .success(function(data) {

      angular.forEach(data.calltoaction_info_list, function(calltoaction_info) {
        $scope.calltoactions.push(calltoaction_info);
        appendYTIframe(calltoaction_info);
      });

      $scope.has_more = data.has_more;

      $("#append-other button").attr('disabled', false);

      $scope.append_ctas_in_progress = false;

      if($scope.aux.gallery_calltoaction) {
        setGroupingGalleries($scope.calltoactions);
      }

      if (!angular.isUndefined(callback)) {
        callback();
      }

    });
    
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

    cta_info = getCallToActionInfo(calltoaction_id);
    if(cta_info.chaptering) {
      angular.forEach(cta_info.chaptering, function(chapter) {
        if(chapter.id == overvideo_interaction.interaction.id) {
          chapter.active = true;
        }
      });
    }

    if(overvideo_interaction.user_interaction) {
      cta_info.overvideo_interaction_timeout = $timeout(function() { 
        removeOvervideoInteraction(player, calltoaction_id, overvideo_interaction);
      }, 5000);
    }
    // remove getOvervideoInteraction
  }

  function unsetChaptering(cta_info) {
    if(cta_info.chaptering) {
      angular.forEach(cta_info.chaptering, function(chapter) {
        chapter.active = false;
      });
    }
  }

  function removeOvervideoInteraction(player, calltoaction_id, overvideo_interaction) {
    cta_info = getCallToActionInfo(calltoaction_id);
    unsetChaptering(cta_info);

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
      if(isOvervideoDuring(overvideo_interaction.interaction.when_show_interaction)) {
        player.play();
      }
      overvideo_interaction.interaction.overvideo_active = false;
      $timeout(function() { 

        $scope.overvideo_interaction_locked[calltoaction_id] = false; 
        angular.forEach(overvideo_interaction.interaction.resource.answers, function(answer) {
          answer.class = "";
        });

        if(overvideo_interaction.interaction.when_show_interaction == "OVERVIDEO_END") {
          cta_info.active_end_interaction = true;
        }

      }, 1500);
    }, 2000);

  }

  //////////////////////// YOUTUBE CALLBACK ////////////////////////
  
  function youtubePlayer(playerId, media_data) {
  	this.playerId = playerId;
  	this.media_data = media_data;
  	
	  this.playerManager = new YT.Player( (this.playerId), {
        playerVars: { html5: 1, rel: 0, wmode: "transparent", showinfo: 0, controls: 0 }, /* { html5: 1, controls: 0, disablekb: 1, rel: 0, wmode: "transparent", showinfo: 0 }, */
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

  $scope.goToSecond = function(cta_info, second) {
    unsetChaptering(cta_info);

    setOvervideoInteractionsAsInactive(cta_info);
    overvideo_interaction = getOvervideoInteractionAtSeconds(cta_info.calltoaction.id, second);

    if(overvideo_interaction != null && !$scope.overvideo_interaction_locked[calltoaction_id]) {
      executeInteraction(current_video_player, calltoaction_id, overvideo_interaction);
    }

    yt_player = getPlayer(cta_info.calltoaction.id);
    yt_player.seek(second);
  };

  $window.onYouTubePlayerReady = function(event) {
    cta_div_id = event.target.getIframe().id;
    cta_id = $("#" + cta_div_id).attr("calltoaction-id");
    cta_info = getCallToActionInfo(cta_id);
    yt_player = getPlayer(cta_id);
    
    appendChaptering(yt_player.playerManager.getDuration(), cta_info);
  };

  $window.onPlayerStateChange = function(newState) {  
    calltoaction_div_id = newState.target.getIframe().id;

    calltoaction_id = $("#" + calltoaction_div_id).attr("calltoaction-id");

    current_video_player = getPlayer(calltoaction_id);
    if(current_video_player) {
      current_video_player_state = current_video_player.playerManager.getPlayerState();

      if(current_video_player_state == 1) {

        updateStartVideoInteraction(calltoaction_id);
        mayStartpolling(calltoaction_id);

      } else if(current_video_player_state == 0) {

        calltoaction_info = getCallToActionInfo(calltoaction_id);
        if(calltoaction_info.answer_with_video_linking_cta) {
          $scope.initCallToActionInfoList(calltoaction_info.answer_with_video_linking_cta);
          initializeVideoAfterPageRender();
        }
        else {
          updateEndVideoInteraction(calltoaction_id);
          mayStopPolling();
        }

      } else {
        // Other state.
      }
    }
  }; 

  //////////////////////// KALTURA CALLBACK ////////////////////////

  function kalturaPlayer(playerId, media_data) {
  	this.playerManager = null;
  	this.playerId = playerId;
  	this.media_data = media_data;

  	player = this;
    $scope.KalturaPlayerId = playerId;
    
    this.init = function() {
	    // Update: http://knowledge.kaltura.com/javascript-api-kaltura-media-players#EnablingtheJavascriptAPI
		  kWidget.embed({
	  		'targetId': this.playerId,
	  		'wid': '_' + $scope.aux.kaltura.partner_id,
	  		'uiconf_id': $scope.aux.kaltura.uiconf_id,
	  		'entry_id': media_data,
	  		'flashvars':{
	  			'autoPlay': false,
	  			'doubleClick': {
	  				//'adTagUrl': "http://analytics.disneyinternational.com/ads/tagsv2/video/?sdk=1&hub=disney.it&site=disneychannel.it&section=community&slug1=" + $scope.calltoaction_info.calltoaction.slug + "&sdk=1&cmsid=13728&vid=" + media_data + "&output=xml_vast2&url=http://community.disneychannel.it/call_to_action/" + $scope.calltoaction_info.calltoaction.slug + "&description_url=http://community.disneychannel.it/call_to_action/" + $scope.calltoaction_info.calltoaction.slug,
	  				'adTagUrl': "http://pubads.g.doubleclick.net/gampad/ads?env=vp&gdfp_req=1&impl=s&output=vast&unviewed_position_start=1&description_url=http://community.disneychannel.it/call_to_action/" + $scope.calltoaction_info.calltoaction.slug + "&iu=/165891808/disney.it/disneychannel.it/community/" + $scope.calltoaction_info.calltoaction.slug + "&sz=1920x480&url=http://community.disneychannel.it/call_to_action/" + $scope.calltoaction_info.calltoaction.slug + "&correlator=" + Date.now + "&ad_rule=1&cmsid=13728&ciu_szs=320x50,300x250&cust_params=&vid=" + media_data,
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
	};
     
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
      setTimeout(function(){
      	player.init();
      }, 1000);
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
          key: '$491717716267986',
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

  function buildUserInteractionForStorage(user_interaction, calltoaction_id, interaction_id) {
    return {
      "user_interaction": user_interaction,
      "calltoaction_id": parseInt(calltoaction_id),
      "interaction_id": parseInt(interaction_id)
    };
  }

  $window.updateStartVideoInteraction = function(calltoaction_id) {
    if(!$scope.play_event_tracked[calltoaction_id]) {

      $scope.play_event_tracked[calltoaction_id] = true;

      var play_interaction_info = $scope.getPlayInteraction(calltoaction_id);
      var interaction_id = play_interaction_info.interaction.id;

      play_interaction_info.hide = true; 
      
      if(interactionAllowed(play_interaction_info)) {
        update_interaction_path = $scope.updatePathWithProperty("/update_interaction");
        $http.post(update_interaction_path, { interaction_id: interaction_id })
          .success(function(data) {

            if(data.current_user) $scope.current_user = data.current_user;
      
            // GOOGLE ANALYTICS
            if(data.ga) {
              $scope.update_ga_event(data.ga.category, data.ga.action, data.ga.label, 1);
              if(data.new_outcome) {
                angular.forEach(data.new_outcome.attributes.reward_name_to_counter, function(value, name) {
                  $scope.update_ga_event("Reward", "UserReward", name.toLowerCase(), parseInt(value));
                });
              }
            }

            calltoaction_info = getCallToActionInfo(calltoaction_id);
            adjustInteractionWithUserInteraction(calltoaction_id, interaction_id, data.user_interaction);
            calltoaction_info.status = data.calltoaction_status;
            
          }).error(function() {
            // ERROR.
          });
        }

    } else {
      // Button play already selected.
    }
  };

  //////////////////////// USER EVENTS METHODS ////////////////////////

  $scope.showEmailShareModal = function(cta_info, interaction_info) {
    $("#cta-" + cta_info.calltoaction.id + "-share-modal").modal("hide");
    $("#modal-interaction-" + interaction_info.interaction.id + "-email").modal("show");
  };

  $scope.shareWith = function(cta_info, interaction_info, provider, enable_linked_share) {
    $("#cta-" + cta_info.calltoaction.id + "-share-modal").modal("hide");
    if(angular.isUndefined(enable_linked_share)) {
      enable_linked_share = false;
    }

    if($scope.aux.free_provider_share && provider != "email") {
      $scope.shareFree(cta_info, interaction_info, provider, enable_linked_share);
    } else {
      shareWithApp(calltoaction_info, interaction_info, provider);
    }
  };

  function stripTags(text) {
    return String(text).replace(/<[^>]+>/gm, '');
  }

  function openDirectUrlModal(interaction_id) {
    $("#modal-interaction-" + interaction_id + "-direct_url").modal("show");
  }

  $scope.shareFree = function(cta_info, interaction_info, provider, enable_linked_share) {
    if(!interactionAllowed(interaction_info)) {
      showRegistrateView();
    } else {
      if(provider == "direct_url") {
        openDirectUrlModal(interaction_info.interaction.id);
        share_url = null;
      } else {
        
        parent_cta_info = $scope.getParentCtaInfo(cta_info);

        message = parent_cta_info.calltoaction.title;
        if(cta_info.calltoaction.extra_fields.linked_result_title) {
          message = cta_info.calltoaction.extra_fields.linked_result_title;
        }

        url_to_share = $scope.computeShareFreeCallToActionUrl(parent_cta_info, cta_info, enable_linked_share);

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
          default:
            share_url = null;
        }
      }

      if(share_url != null) window.open(share_url);
 
      $http.post("/update_basic_share.json", { interaction_id: interaction_info.interaction.id, provider: provider })
        .success(function(data) {
          $scope.shareFreeAjaxSuccess(data);
        });
    }
  };

  $scope.shareFreeAjaxSuccess = function(data) {
    if(data.current_user) $scope.current_user = data.current_user;
    if(data.notice_anonymous_user) {
      showRegistrateView();
    }
  };

  $scope.computeShareFreeCallToActionUrl = function(parent_cta_info, cta_info, enable_linked_share) {
    url = $scope.aux.root_url + "call_to_action/" + parent_cta_info.calltoaction.slug;
    if(cta_info.calltoaction.extra_fields.linked_result_title && enable_linked_share) {
      url = url + "/" + cta_info.calltoaction.slug;
    }
    return url;
  };

  function shareWithApp(calltoaction_info, interaction_info, provider) {
    if(!interactionAllowed(interaction_info)) {
      showRegistrateView();
    } else {
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

      update_interaction_path = $scope.updatePathWithProperty("/update_interaction");

      $http.post(update_interaction_path, { interaction_id: interaction_id, share_with_email_address: share_with_email_address, provider: provider, facebook_message: facebook_message })
        .success(function(data) {

          button.attr('disabled', false);
          button.html(current_button_html);

          if(!data.share.result) {
            interaction_info.errors = data.share.exception;
            return;
          }

          if(data.current_user) $scope.current_user = data.current_user;

          adjustInteractionWithUserInteraction(calltoaction_id, interaction_id, data.user_interaction);
          interaction_info.status = data.interaction_status;

          $scope.aux.share_interaction_daily_done = true;

          $("#modal-interaction-" + interaction_id + "-" + provider).modal("hide");

          if(data.ga) {
            $scope.update_ga_event(data.ga.category, data.ga.action, data.ga.label);
            if(data.new_outcome) {
              angular.forEach(data.new_outcome.attributes.reward_name_to_counter, function(value, name) {
                $scope.update_ga_event("Reward", "UserReward", name.toLowerCase(), parseInt(value));
              });
            }
          }

        }).error(function() {
          // ERRORE
        });
    }
  }

  function openWindowForDownloadInteraction(resource_type) {
    // This feature outwits the popup block
    if(resource_type == "download") newWindow = window.open();
  }

  $scope.updateAnswer = function(calltoaction_info, interaction_info, params, when_show_interaction, before_callback, before_callback_timeout) {
    var resource_type = interaction_info.interaction.resource_type;
    if($scope.aux.assets && $scope.aux.assets.extra_fields && $scope.aux.assets.extra_fields.interaction_button_sound) {
      interactionButtonSound();
    }

    if(interactionAllowed(interaction_info)) {

      if(!$scope.answer_in_progress) {
        $scope.answer_in_progress = true;
        
        enableWaitingAudio("stop");
        if(!angular.isUndefined(before_callback)) before_callback();
        openWindowForDownloadInteraction(resource_type);

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

    update_interaction_path = $scope.updatePathWithProperty("/update_interaction");

    $http.post(update_interaction_path, { interaction_id: interaction_id, params: params, user_interactions_history: $scope.getUserInteractionsHistory(calltoaction_info), parent_cta_id: $scope.getParentCtaId(calltoaction_info) })
      .success(function(data) {
        $scope.updateAnswerAjaxSuccess(data, calltoaction_info, interaction_info, when_show_interaction, params);
      }).error(function() {
        $scope.answer_in_progress = false;
      });
  };

  $scope.updateAnswerAjaxSuccessCtaStatuses = function(calltoaction_info, interaction_info, data) {
    calltoaction_info.status = data.calltoaction_status;

    calltoaction_id = calltoaction_info.calltoaction.id;
    interaction_id = interaction_info.interaction.id;
    adjustInteractionWithUserInteraction(calltoaction_id, interaction_id, data.user_interaction);
  };

  $scope.updateAnswerAjaxSuccess = function(data, calltoaction_info, interaction_info, when_show_interaction, params) {
    if(data.session_empty) {
      alert("Per funzionare correttamente il sito necessita l'abilitazione dei cookie");
      $scope.answer_in_progress = false;
      return
    } 

    calltoaction_id = calltoaction_info.calltoaction.id;
    interaction_id = interaction_info.interaction.id;

    if(interaction_info.interaction.resource_type == "commentlike") {
      new_comment_active_ids_length = data.user_interaction.aux.comment_active_ids.length;
      if(!interaction_info.user_interaction || interaction_info.user_interaction.aux.comment_active_ids.length < new_comment_active_ids_length) {
        $scope.refreshCommentLikeCounter(calltoaction_info, params, 1);
      } else {
        $scope.refreshCommentLikeCounter(calltoaction_info, params, -1);
      }
    }

    if(data.current_user) {
      $scope.current_user = data.current_user;
    }

    if(data.notice_anonymous_user) { 
      showRegistrateView();
    }

    if(data.counter) {
      interaction_info.interaction.resource.counter = data.counter;
      interaction_info.interaction.resource.counter_aux = data.counter_aux;
    }

    // Google analytics.
    if(data.ga) {
      $scope.update_ga_event(data.ga.category, data.ga.action, data.ga.label, 1);
      if(data.new_outcome) {
        angular.forEach(data.new_outcome.attributes.reward_name_to_counter, function(value, name) {
          $scope.update_ga_event("Reward", "UserReward", name.toLowerCase(), parseInt(value));
        });
      }
    }

    if(data.answers) {
      updateAnswersInInteractionInfo(interaction_info, data.answers);
    }

    if(data.answer) {
      if(data.answer.media_type == "IMAGE") {
        calltoaction_info.calltoaction.media_image_from_answer_type = "IMAGE";
        calltoaction_info.calltoaction.media_image_from_answer = data.answer_media_image_url;
      } else if(data.answer.media_type == "YOUTUBE") {
        if(calltoaction_info.calltoaction.media_type != "YOUTUBE") {
          calltoaction_info.calltoaction.media_type = "YOUTUBE";
          calltoaction_info.calltoaction.vcode = data.answer.media_data;
          $timeout(function() { 
            player = new youtubePlayer('main-media-iframe-' + calltoaction_info.calltoaction.id, data.answer.media_data);
          }, 0);
        }
        else {
          $scope.updateYTIframe(calltoaction_info, data.answer.media_data, true);
        }
      }
    }

    if(isOvervideoDuring(when_show_interaction) || when_show_interaction == "OVERVIDEO_END") {

      interaction_info.feedback = true;

      if(interaction_info.interaction.resource_type == "trivia") {
        getPlayer(calltoaction_id).play();

        $timeout(function() { 
          interaction_info.feedback = false;
          removeOvervideoInteraction(getPlayer(calltoaction_id), calltoaction_id, interaction_info);
          $scope.answer_in_progress = false;
        }, 1500);                

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
        }, 3000);

      } else {
        removeOvervideoInteraction(getPlayer(calltoaction_id), calltoaction_id, interaction_info);
        $scope.answer_in_progress = false;
      }

    } else {
      if(data.new_outcome) {
        interaction_info.feedback = data.new_outcome.attributes;
      }

      if(interaction_info.interaction.resource_type == "like") {
        if(data.user_interaction.aux.like) {
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

    if(interaction_info.interaction.resource_type == "vote" || interaction_info.interaction.resource_type == "versus") {
      interaction_info.interaction.resource.counter_aux = data.counter_aux; 
    }

    // Next call to action for test interaction
    if(data.next_call_to_action_info) {
      if(data.answer) {
        if(data.has_answer_media && data.answer.media_type == "YOUTUBE") {
          // In this case, YouTube video switching is managed by onPlayerStateChange method from YouTube callback methods
          calltoaction_info.answer_with_video_linking_cta = data.next_call_to_action_info_list;
        }
        else {
          timeout_time = 0;
          if(data.answer) {
            if(data.has_answer_media && data.answer.media_type == "IMAGE") {
              timeout_time = 4000;
            }
          }
          $timeout(function() { 
            updateInteractionsHistory(data.user_interaction.id);

            $scope.replaceCallToActionInCallToActionInfoList(calltoaction_info, data.next_call_to_action_info);

            calltoaction_info = getCallToActionInfo(data.next_call_to_action_info.calltoaction.id);
            $scope.updateAnswerAjaxSuccessCtaStatuses(calltoaction_info, interaction_info, data);

            initializeVideoAfterPageRender();
            if($scope.calltoaction_info) {
              $scope.calltoaction_info.class = "trivia-interaction__update-answer--hide";
              $timeout(function() { 
                $scope.calltoaction_info.class = "trivia-interaction__update-answer--hide trivia-interaction__update-answer--fade_in";
              }, 200);
            }
          }, timeout_time);
        }
      }
    } else {
      $scope.updateAnswerAjaxSuccessCtaStatuses(calltoaction_info, interaction_info, data);
    }

    // Next call to action for random interaction
    if(data.next_random_call_to_action_info_list) {
      $scope.initCallToActionInfoList(data.next_random_call_to_action_info_list);
    }

    $scope.updateAnswerAjaxSuccessCallback(calltoaction_info, data);
  };

  $scope.updateAnswerAjaxSuccessCallback = function(calltoaction_info, data) {
  };

  $scope.calculateVoteTotal = function(interaction_info) {
    total = 0;
    angular.forEach(interaction_info.interaction.resource.counter_aux, function(value, key) {
      total = total + (key * value);
    });
    return total;
  };

  function initializeVideoAfterPageRender() {
    if($scope.calltoaction_info) {
      $timeout(function() { 

        if($scope.calltoaction_info.calltoaction.media_type == 'YOUTUBE') {
          $(".media-youtube iframe").remove();
          iframe = "<div id=\"main-media-iframe-" + $scope.calltoaction_info.calltoaction.id + "\" main-media=\"main\" calltoaction-id=\"" + $scope.calltoaction_info.calltoaction.id + "\" class=\"embed-responsive-item\"></div>";
          $(".media-youtube").html(iframe);
        }

        angular.forEach($scope.calltoactions, function(sc) {
          appendYTIframe(sc);
        });

      }, 0); // Code to be executed after page render
    } 
  }
  
  $scope.resetToRedo = function(cta_info) {
    cta_info.class = "trivia-interaction__update-answer--fade_out";
    $timeout(function() { 
      $http.post("/reset_redo_user_interactions", { user_interaction_ids: $scope.getUserInteractionsHistory(cta_info), parent_cta_id: $scope.getParentCtaId(cta_info) })
      .success(function(data) {   
        $scope.replaceCallToActionInCallToActionInfoList(cta_info, data.calltoaction_info);
        cta_info = getCallToActionInfo(data.calltoaction_info.calltoaction.id);
        cta_info.hide_class = "";
        cta_info.class = "trivia-interaction__update-answer--hide"
        $timeout(function() { 
          cta_info.class = "trivia-interaction__update-answer--hide trivia-interaction__update-answer--fade_in";
        }, 500);
      }).error(function() {
      });
    }, 200);
  };

  $scope.computePercentageForVersus = function(interaction_info, answer_id) {
    if(interaction_info.user_interaction) {
      answer_counter = interaction_info.interaction.resource.counter_aux[answer_id];
      if(answer_counter) {
        return $scope.computePercentage(interaction_info.interaction.resource.counter, answer_counter);
      } else {
        return 0;
      }
    } else {
      return 0;
    }
  };

  $scope.computePercentage = function(total, partial) {
    if(total == 0) {
      return 0;
    } else {
      return Math.round(partial / total * 100);
    }
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
    updateUserRewardInView(data.main_reward_counter.general);

    $("#home-undervideo-interaction-" + interaction_id).html(data.feedback); 
  };

  $window.userAnswerWithMedia = function(answer, calltoaction_id, interaction_id, when_show_interaction) {
    if(isOvervideoDuring(when_show_interaction)) {
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

      if(isOvervideoDuring(interaction_shown_in)) {
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
    if(!$scope.polling) {
      $scope.polling = $interval(videoPolling, 800);
    }
  };

  $window.mayStopPolling = function() { 
    if($scope.polling) {
      
      video_with_polling_counter = false;
      
      angular.forEach($scope.play_event_tracked, function(video_started, calltoaction_id) {
        if(video_started) {
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
      calltoaction_info = getCallToActionInfo(calltoaction_id);
      if(calltoaction_info) {
        if(calltoaction_info.answer_with_video_linking_cta) {
          // Do nothing
        }
        else {
          if(calltoaction_info.calltoaction.media_type == "YOUTUBE"){
          	youtube_player = getPlayer(calltoaction_id);
          	youtube_player_current_time = Math.floor(youtube_player.playerManager.getCurrentTime()); 

            youtube_player_duration = Math.floor(youtube_player.playerManager.getDuration()); 
            calltoaction_info.progress = 100 * youtube_player_current_time / youtube_player_duration;

          	overvideo_interaction = getOvervideoInteractionAtSeconds(calltoaction_id, youtube_player_current_time);
            enable_percentage_animation = getOvervideoInteractionAtSeconds(calltoaction_id, (youtube_player_current_time + OVERVIDEO_COUNTDOWN_ANIMATION_TIME + 1));            

            preinteraction_animation = !(calltoaction_info.calltoaction.extra_fields.preinteraction_animation && calltoaction_info.calltoaction.extra_fields.preinteraction_animation.value == false);
            
            if(enable_percentage_animation != null && !calltoaction_info.percentage_animation && preinteraction_animation) {
              calltoaction_info.percentage_animation = true;
              adjustPercentageAnimation(OVERVIDEO_COUNTDOWN_ANIMATION_TIME, 0, calltoaction_info);
          	} else if(video_started && overvideo_interaction != null && !$scope.overvideo_interaction_locked[calltoaction_id]) {
              executeInteraction(youtube_player, calltoaction_id, overvideo_interaction);
          	} 
          }
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
        } else if($scope.aux.init_captcha && !data.captcha_evaluate) {
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
            $scope.update_ga_event(data.ga.category, data.ga.action, data.ga.label, 1);
          }

        } else {

          if(!isCommentPresent(data.comment.id, interaction_info.interaction.resource.comment_info.comments)) {
            interaction_info.interaction.resource.comment_info.comments.unshift(data.comment);
          }


          interaction_info.interaction.resource.comment_info.user_text = "";
          interaction_info.interaction.resource.comment_info.user_captcha = "";
          if(!$scope.current_user) {
            interaction_info.interaction.captcha = "data:image/jpeg;base64," + data.captcha.image;
          }

          // GOOGLE ANALYTICS
          if(data.ga) {
            $scope.update_ga_event(data.ga.category, data.ga.action, data.ga.label, 1);
          }

        }

      }).error(function() {
      });
  };

  function isCommentPresent(id, comments) {
    angular.forEach(comments, function(comment) {
      if(comment.id == id) return true;
    });
    return false;
  }

  $scope.appendComments = function(interaction_info) {
    if(!$scope.ajax_comment_append_in_progress) {
      $scope.ajax_comment_append_in_progress = true;

      interaction_id = interaction_info.interaction.id;
      comments = interaction_info.interaction.resource.comment_info.comments;

      comment_ids = [];
      angular.forEach(comments, function(comment) {
        comment_ids.push(comment.id);
      });

      try {
        $http.post("/append_comments", { interaction_id: interaction_id, comment_ids: comment_ids, last_updated_at: (comments[comments.length - 1].updated_at) })
          .success(function(data) {
            comment_info = interaction_info.interaction.resource.comment_info
            comment_info.comments = comment_info.comments.concat(data.comments);
          }).error(function() {
            // error
          });
      } finally {
        $scope.ajax_comment_append_in_progress = false;
      }
    }
  };

  $scope.commentsPolling = function() {
    if(!$scope.ajax_comment_append_in_progress) {
      $scope.ajax_comment_append_in_progress = true;

      interaction_info = $scope.comments_polling.interaction_info;
      interaction_id = interaction_info.interaction.id;
      comments = interaction_info.interaction.resource.comment_info.comments;

      comment_ids = [];
      angular.forEach(comments, function(comment) {
        comment_ids.push(comment.id);
      });

      if(comments.length > 0) {
        first_updated_at = comments[0].updated_at
      } else {
        first_updated_at = null;
      }
      
      try {
        $http.post("/comments_polling", { interaction_id: interaction_id, comment_ids: comment_ids, first_updated_at: first_updated_at })
          .success(function(data) {
            comment_info = interaction_info.interaction.resource.comment_info;
            comment_info.comments = data.comments.concat(comment_info.comments);
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
	      $(".cta-preview__locked-layer--reward").html(data.html);
	    }).error(function() {
	      // ERROR
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

  $scope.formatFullDateWithoutYear = function(date, language) {
    date = new Date(date);
    return $scope.computeDayName(date.getDay(), language) + " " + date.getDate() + " " + $scope.computeMonthName(date.getMonth(), language);
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