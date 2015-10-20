var intesaExpoStreamCalltoactionModule = angular.module('IntesaExpoStreamCalltoactionModule', ['ngRoute', 'ngSanitize', 'ngAnimate']);

IntesaExpoStreamCalltoactionCtrl.$inject = ['$scope', '$window', '$http', '$timeout', '$interval', '$sce'];
intesaExpoStreamCalltoactionModule.controller('IntesaExpoStreamCalltoactionCtrl', IntesaExpoStreamCalltoactionCtrl);

// csrf-token handling in ajax calls
intesaExpoStreamCalltoactionModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);


function IntesaExpoStreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document) {
  angular.extend(this, new StreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document));

  $window.update_ga_event = function(category, action, label, value) {
    if($scope.aux.property_path_name) {
      category = $scope.aux.property_path_name + "_" + category;
    }

    if($scope.google_analytics_code.length > 0) {
      ga('send', 'event', category, action, label, value, true);
    }
  };

  $scope.intesaExpoGa = function(el1, el2, el3, $event) {
    if (!angular.isUndefined($event)) {
      _this = $event.currentTarget;
      if(_this.target != "_blank") {
        _gaq.push(['_set','hitCallback', function() {
          document.location = _this.href;
        }]);
        _gaq.push(['_trackEvent', el1, el2, el3]);
        return false;
      } else {
        _gaq.push(['_trackEvent', el1, el2, el3]);
      }  
    } else {
      _gaq.push(['_trackEvent', el1, el2, el3]);
    }
  };

  $window.intesaExpoGaW = function(el1, el2, el3, el) {
    _this = el;
    if(_this.target != "_blank") {
      _gaq.push(['_set','hitCallback', function() {
        document.location = _this.href;
      }]);
      _gaq.push(['_trackEvent', el1, el2, el3]);
      return false;
    } else {
      _gaq.push(['_trackEvent', el1, el2, el3]);
    }  
  };

  $scope.intesaExpoGaSocial = function(el1, el2) {
    _gaq.push(['_trackSocial', el1, el2]);
  };

  $scope.extraInit = function() {
    $scope.content_ical = new Object();

    if($scope.calltoaction_info) {
      if($scope.aux.tag_menu_item) {
        $scope.menu_field = $scope.aux.tag_menu_item;
      } else {
        $scope.menu_field = "";
      }

      adjustGalleryCtaInfo($scope.calltoaction_info);
      
    } else {
      if($scope.aux.tag_menu_item) {
        $scope.menu_field = $scope.aux.tag_menu_item;
      }
    }

    if($scope.aux.context_root == "inaugurazione" && $scope.aux.event_stripe) {
      initEventContainer();

      if($scope.aux.italiadalvivo_branch_cta_info) {
        adjustGalleryCtaInfo($scope.aux.italiadalvivo_branch_cta_info);
      }
    }

  };

  function initEventContainer() {
    eventPreviews = {};
    $scope.eventPreviewDates = [];
    $scope.fullDates = {};

    // build an hash with date as key and time with content preview as value
    angular.forEach($scope.aux.event_stripe.contents, function(contentPreview) {
      interactions = getIcalInteractionsForContentPreview(contentPreview);

      angular.forEach(interactions, function(interactionResource) {
        _datetime = interactionResource.ical_fields.start_datetime.value
        var date = $scope.formatDate(_datetime);
        if(!(date in eventPreviews)) {
          eventPreviews[date] = [];
        }

        $scope.fullDates[date] = $scope.formatFullDateWithoutYear(_datetime);
        eventPreviews[date].push([$scope.extractTimeFromDate(_datetime), contentPreview]);
      });
    });

    // build an array from previous hash to use with ng-repeat (ordering by first value). Each element
    // has date, date with week day name and content preview.
    angular.forEach(eventPreviews, function(eventPreview, key) {
      fullDate = $scope.fullDates[key];
      $scope.eventPreviewDates.push([key, fullDate, eventPreview]);
    });
  }

  $scope.getItaliaDalVivoBranchCtaInfo = function() {
    return [$scope.aux.italiadalvivo_branch_cta_info];
  };

  function adjustGalleryCtaInfo(calltoaction_info) {
    if(calltoaction_info.calltoaction.extra_fields) {
      contents = $scope.getContentWithPrefixFromExtraFields(calltoaction_info.calltoaction.extra_fields, "content_");
      if(contents.length > 0) {
        calltoaction_info.calltoaction.contents = contents;
      }
      gallery = $scope.getContentWithPrefixFromExtraFields(calltoaction_info.calltoaction.extra_fields, "photo_gallery_");
      if(gallery.length > 0) {
        calltoaction_info.calltoaction.gallery = gallery;
      }
    }
  }

  $scope.orderEventPreviewDates = function(eventPreviewDate) {
    return eventPreviewDate[0];
  }

  $scope.hasPhotoGallery = function(calltoaction) {
    return ($scope.getContentWithPrefixFromExtraFields(calltoaction.extra_fields, "photo_gallery_").length > 0);
  };

  $scope.getContentWithPrefixFromExtraFields = function(extra_fields, prefix) {
    contents = [];
    angular.forEach(extra_fields, function(value, key) {
      if(key.indexOf(prefix) > -1) {
        content = { key: key, value: value }; 
        contents.push(content);
      }
    });
    return contents;
  };

  function getIcalInteractionsForContentPreview(contentPreview) {
    icalInteractions = []
    angular.forEach(contentPreview.interactions, function(contentPreviewInteraction) {
      if(contentPreviewInteraction.interaction_info.when_show_interaction != "MAI_VISIBILE" && contentPreviewInteraction.interaction_resource.ical_fields) {
        icalInteractions.push(contentPreviewInteraction.interaction_resource); 
      }
    });
    return icalInteractions;
  }

  function getIcalInteractions(calltoaction_id) {
    interaction_info_list = $scope.getInteractions(calltoaction_id, "download");
    ical_info_list = [];
    angular.forEach(interaction_info_list, function(value, key) {
      if(value.interaction.resource.ical) {
        ical_info_list.push(value);
      }
    });
    ical_info_list.sort(function(a, b) {
      return new Date(a.interaction.resource.ical.start_datetime.value) - new Date(b.interaction.resource.ical.start_datetime.value);
    });
    return ical_info_list;
  }

  //ng-if="ical.dates[$index] != ical.dates_to[$index] || !(ical.times[$index] == '00:00' && ical.times_to[$index] == '23:59')"
  $scope.getFirstIcalInteractionForContent = function(content) {
    if(angular.isUndefined(content.content_ical)) {

      min_date = min_date_to = _location = null;
      today_date = new Date();

      angular.forEach(content.interactions, function(value) {
        if(value.interaction_info.resource_type.toLowerCase() == "download" && value.interaction_resource.ical_fields) {
          ical_fields = value.interaction_resource.ical_fields;
          start_datetime = ical_fields["start_datetime"];
          end_datetime = ical_fields["end_datetime"];
          if(start_datetime) {
            date = new Date(start_datetime["value"]);
            if(!min_date || (date < min_date && date > today_date)) {
              _location = value.interaction_resource.ical_fields.location.split("|")[0];
              min_date = date;
              min_date_to = new Date(end_datetime["value"]);
            }
          }
        }
      });

      if(min_date) {
        month = $scope.computeMonthName(min_date.getMonth(), $scope.aux.language).substring(0, 3);
        day = ("0" + min_date.getDate()).slice(-2);
        
        _datetime = $scope.formatDate(min_date, $scope.aux.language);
        _datetime_to = $scope.formatDate(min_date_to, $scope.aux.language);
        
        time = $scope.extractTimeFromDate(min_date);
        time_to = $scope.extractTimeFromDate(min_date_to);
        
        fulldate = $scope.formatFullDate(min_date, $scope.aux.language);

        if(_datetime == _datetime_to && time == '00:00' && time_to == '23:59') {
          time = null;
        }

        content.content_ical = [month, day, time, _datetime, fulldate, _location];
      } else {
        content.content_ical = min_date;
      }

    }
    return content.content_ical;
  };

  $scope.checkAndGenerateIcalForView = function(calltoaction_info) {
    ical_info_list = getIcalInteractions(calltoaction_info.calltoaction.id);
    if (angular.isUndefined($scope.ical) && ical_info_list.length > 0) { 
      generateIcalForView(ical_info_list);
    }
    return ical_info_list.length > 0;
  };
  
  $scope.showSearch = function(hidden){
	if('search' != $scope.menu_field){
  		if($(".navbar__search").is(":visible")){
  			$(".navbar__search").slideUp();
  		}else{
  			$(".navbar__search").slideDown();
  		}
  	}
  };

  $scope.icalTimestamp = function(cta_slug, _datetime) {
    _datetime = new Date(_datetime);
    date = cta_slug + "_" + $scope.zerosBeforeNumber(_datetime.getDate(), 1) + "" + $scope.zerosBeforeNumber(_datetime.getMonth(), 1) + "" + _datetime.getFullYear();
    date = date + $scope.zerosBeforeNumber(_datetime.getHours(), 1) + "" + $scope.zerosBeforeNumber(_datetime.getMinutes(), 1);
    return date;
  };

  $scope.checkLocationExtraField = function(calltoaction_info) {
    if(calltoaction_info.calltoaction.extra_fields.custom_time && calltoaction_info.calltoaction.extra_fields.custom_location) {
      _location_arr = calltoaction_info.calltoaction.extra_fields.custom_location.split("|");
      if(_location_arr.length > 1) {
        calltoaction_info.calltoaction.extra_fields.custom_location = _location_arr[0];
        calltoaction_info.calltoaction.extra_fields.custom_location_url = _location_arr[1];
      } else {
        calltoaction_info.calltoaction.extra_fields.custom_location = _location_arr[0];
      }
      return true;
    } else {
      return false;
    }
  };

  function generateIcalForView(ical_info_list) {
    $scope.ical = new Object({"dates": [], "dates_to": [], "times": [], "times_to": [], "locations": [], "location_urls": [], "interaction_ids": [], "datetimes": [], "n": []});
    
    i = 0;
    angular.forEach(ical_info_list, function(value, key) {
      _datetime = value.interaction.resource.ical.start_datetime.value;
      _datetime_to = value.interaction.resource.ical.end_datetime.value;
      _location = value.interaction.resource.ical.location;
      _date = $scope.formatDate(_datetime, $scope.aux.language);
      _date_to = $scope.formatDate(_datetime_to, $scope.aux.language);

      date_index = $scope.ical.dates.indexOf(_date);
      location_index = $scope.ical.locations.indexOf(_location);

      /*
      if(date_index < 0 || location_index < 0) {
        $scope.ical.dates.push(_date);
        $scope.ical.locations.push(_location);
        $scope.ical.times.push($scope.extractTimeFromDate(_datetime));
        $scope.ical.n.push(i);
        i = i + 1;
      } else {
        index = Math.max(date_index, location_index);
        $scope.ical.times[index] = $scope.ical.times[index] + ", " + $scope.extractTimeFromDate(_datetime);
      }
      */

      _location_arr = _location.split("|");
      if(_location_arr.length > 1) {
        _location = _location_arr[0];
        _location_url = _location_arr[1];
      } else {
        _location = _location_arr[0];
        _location_url = null;
      }

      $scope.ical.datetimes.push(_datetime);
      $scope.ical.interaction_ids.push(value.interaction.id);
      $scope.ical.dates.push(_date);
      $scope.ical.dates_to.push(_date_to);
      $scope.ical.locations.push(_location);
      $scope.ical.location_urls.push(_location_url);
      $scope.ical.times.push($scope.extractTimeFromDate(_datetime));
      $scope.ical.times_to.push($scope.extractTimeFromDate(_datetime_to));
      $scope.ical.n.push(i);
      i = i + 1;

    });

  }

  $scope.orderContent = function(content) {
    return content["key"];
  };

  $scope.isContentValid = function(content) {
    if(!content.valid_from) {
      return true;
    } else {
      valid_from = new Date(content.valid_from);
      today_date = new Date();
      return (valid_from < today_date);
    }
  };

  $scope.linkToValidFrom = function(content) {
    if($scope.isContentValid(content)) {
      return $scope.linkTo(content.detail_url);
    } else {
      return "";
    }
  };

  $scope.evidenceLinkTo = function(content) {
    if(content.extra_fields.external_url) {
      return content.extra_fields.external_url;
    } else {
      return $scope.linkTo(content.detail_url);
    }
  };

  $scope.linkTo = function(url, stripe_name) {
    if(angular.isUndefined(stripe_name)) {
      stripe_name = "";
    }

    if($scope.aux.context_root && url.indexOf("/" + $scope.aux.context_root + "/") < 0) {
      url = "/" + $scope.aux.context_root + "" + url;
    }
    
    /*
      if(stripe_name == "article-it") {
        if($scope.aux.context_root && url.indexOf("/" + $scope.aux.context_root + "/") > -1) {
          url = url.replace("/" + $scope.aux.context_root + "/", "/imprese/");
        } else {
          url = "/imprese" + url;
        }
      } else {
        if($scope.aux.context_root && url.indexOf("/" + $scope.aux.context_root + "/") < 0) {
          url = "/" + $scope.aux.context_root + "" + url;
        }
      }
    */
    return url;
  };

  $window.updateInteractionDownloadIcal = function(interaction_id, ical_name) {
    updateInteractionDownloadIcal(interaction_id, ical_name);
  };

  $scope.updateInteractionDownloadIcal = function(interaction_id, ical_name) {
    updateInteractionDownloadIcal(interaction_id, ical_name);
  };

  function updateInteractionDownloadIcal(interaction_id, ical_name) {
    _gaq.push(['_trackEvent','Event','Download', ical_name]);
    //ga('send', 'event', "Navigation", "Click", "Download", 1, true);

    if(!$scope.answer_in_progress) {
      $scope.answer_in_progress = true;

      update_interaction_path = "/update_interaction";
      if($scope.aux.language) {
        update_interaction_path = "/" + $scope.aux.language + "" + update_interaction_path;
      }

      $http.post(update_interaction_path, { interaction_id: interaction_id })
        .success(function(data) {
          
          // Google analytics.
          if(data.ga) {
            update_ga_event(data.ga.category, data.ga.action, data.ga.label, 1);
            if(data.new_outcome) {
              angular.forEach(data.new_outcome.attributes.reward_name_to_counter, function(value, name) {
                update_ga_event("Reward", "UserReward", name.toLowerCase(), parseInt(value));
              });
            }
          }

          window.location.href = "/ical/" + interaction_id + "/" + ical_name;
          $scope.answer_in_progress = false;

        }).error(function() {

          $scope.answer_in_progress = false;

        });
    }
  }

  $window.updateStartVideoInteraction = function(calltoaction_id, interaction_id) {
    if(!$scope.play_event_tracked[calltoaction_id]) {

      $scope.play_event_tracked[calltoaction_id] = true;

      play_interaction_info = $scope.getPlayInteraction(calltoaction_id);
      if(play_interaction_info == null) {
        console.log("You must enable the play interaction for this calltoaction.");
        return;
      }

      // INTESA
      _gaq.push(['_trackEvent','Video','Play','Partnership_' + $scope.calltoaction_info.calltoaction["vcode"]]);

      play_interaction_info.hide = true; 

      update_interaction_path = $scope.updatePathWithProperty("/update_interaction");

      $http.post(update_interaction_path, { interaction_id: play_interaction_info.interaction.id })
        .success(function(data) {
    
          // GOOGLE ANALYTICS
          if(data.ga) {
            update_ga_event(data.ga.category, data.ga.action, data.ga.label, 1);
            angular.forEach(data.outcome.attributes.reward_name_to_counter, function(value, name) {
              update_ga_event("Reward", "UserReward", name.toLowerCase(), parseInt(value));
            });
          }
          
        }).error(function() {
          // ERROR.
        });

    } else {
      // Button play already selected.
    }
  };

  $window.appendYTIframe = function(calltoaction_info) {
    if(calltoaction_info.calltoaction.media_type == "YOUTUBE" && $scope.youtube_api_ready) {

      // Moved in RR controller otherwise flexslider not work
      // vcode = calltoaction_info.calltoaction.media_data;
      // if(vcode.indexOf(",") > -1) {
      //   $scope.$apply(function() {
      //     calltoaction_info.calltoaction.vcodes = vcode.split(",");
      //     calltoaction_info.calltoaction.vcode = calltoaction_info.calltoaction.vcodes[0];
      //   });
      // } else {
      //   calltoaction_info.calltoaction.vcode = vcode;
      // }

      player = new youtubePlayer('main-media-iframe-' + calltoaction_info.calltoaction.id, calltoaction_info.calltoaction.vcode);
      calltoaction_info.calltoaction["player"] = player;

      $scope.play_event_tracked[calltoaction_info.calltoaction.id] = false;
      $scope.current_user_answer_response_correct[calltoaction_info.calltoaction.id] = false;

    }
  };

  function youtubePlayer(playerId, media_data) {
    this.playerId = playerId;
    this.media_data = media_data;
    
    this.playerManager = new YT.Player( (this.playerId), {
        playerVars: { html5: 1, rel: 0, wmode: "transparent", showinfo: 0 },
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

}