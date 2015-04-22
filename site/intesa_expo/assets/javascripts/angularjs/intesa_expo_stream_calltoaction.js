var intesaExpoStreamCalltoactionModule = angular.module('IntesaExpoStreamCalltoactionModule', ['ngRoute', 'ngSanitize', 'ngAnimate']);

IntesaExpoStreamCalltoactionCtrl.$inject = ['$scope', '$window', '$http', '$timeout', '$interval', '$sce'];
intesaExpoStreamCalltoactionModule.controller('IntesaExpoStreamCalltoactionCtrl', IntesaExpoStreamCalltoactionCtrl);

// csrf-token handling in ajax calls
intesaExpoStreamCalltoactionModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);


function IntesaExpoStreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document) {
  angular.extend(this, new StreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document));

  $scope.extraInit = function() {
    $scope.content_ical = new Object();
    if($scope.calltoaction_info) {
      if($scope.aux.tag_menu_item) {
        $scope.menu_field = $scope.aux.tag_menu_item;
      } else {
        $scope.menu_field = "";
      }

      if($scope.calltoaction_info.calltoaction.extra_fields) {
        contents = $scope.getContentWithPrefixFromExtraFields($scope.calltoaction_info.calltoaction.extra_fields, "content_");
        if(contents.length > 0) {
          $scope.calltoaction_info.calltoaction.contents = contents;
        }
        gallery = $scope.getContentWithPrefixFromExtraFields($scope.calltoaction_info.calltoaction.extra_fields, "photo_gallery_");
        if(gallery.length > 0) {
          $scope.calltoaction_info.calltoaction.gallery = gallery;
        }
      }
      
    } else {
      if($scope.aux.tag_menu_item) {
        $scope.menu_field = $scope.aux.tag_menu_item;
      }
    }
  };

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
      min_date = null;
      min_date_to = null;
      today_date = new Date();
      angular.forEach(content.interactions, function(value) {
        if(value.interaction_info.resource_type.toLowerCase() == "download" && value.interaction_resource.ical_fields) {
          ical_fields = JSON.parse(value.interaction_resource.ical_fields)
          start_datetime = ical_fields["start_datetime"];
          end_datetime = ical_fields["end_datetime"];
          if(start_datetime) {
            date = new Date(start_datetime["value"]);
            if(!min_date || (date < min_date && date > today_date)) {
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
        if(_datetime == _datetime_to && time == '00:00' && time_to == '23:59') {
          time = null;
        }
        content.content_ical = [month, day, time, _datetime];
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

  function generateIcalForView(ical_info_list) {
    $scope.ical = new Object({"dates": [], "dates_to": [], "times": [], "times_to": [], "locations": [], "interaction_ids": [], "datetimes": [], "n": []});
    
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

      $scope.ical.datetimes.push(_datetime);
      $scope.ical.interaction_ids.push(value.interaction.id);
      $scope.ical.dates.push(_date);
      $scope.ical.dates_to.push(_date_to);
      $scope.ical.locations.push(_location);
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
    _gaq.push(['_trackEvent','Navigation','Click','Download']);
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
            angular.forEach(data.outcome.attributes.reward_name_to_counter, function(value, name) {
              update_ga_event("Reward", "UserReward", name.toLowerCase(), parseInt(value));
            });
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
          
        }).error(function() {
          // ERROR.
        });

    } else {
      // Button play already selected.
    }
  };

}