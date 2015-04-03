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
      $scope.menu_field = "";

      if($scope.calltoaction_info.calltoaction.extra_fields) {
        contents = $scope.getContentWithPrefixFromExtraFields($scope.calltoaction_info.calltoaction.extra_fields, "content_")
        if(contents.length > 0) {
          $scope.calltoaction_info.calltoaction.contents = contents;
        }
        gallery = $scope.getContentWithPrefixFromExtraFields($scope.calltoaction_info.calltoaction.extra_fields, "photo_gallery_")
        if(gallery.length > 0) {
          $scope.calltoaction_info.calltoaction.gallery = gallery;
        }
      }
      
    } else {
      if($scope.aux.page_tag) {
        $scope.menu_field = $scope.aux.page_tag.miniformat.name;
      }
    }
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
    return ical_info_list;
  }

  $scope.getFirstIcalInteractionForContent = function(content) {
    if(angular.isUndefined($scope.content_ical[content.id])) {
      console.log("here");
      min_date = null;
      today_date = new Date();
      angular.forEach(content.interactions, function(value) {
        if(value.interaction_info.resource_type.toLowerCase() == "download" && value.interaction_resource.ical_fields) {
          date = JSON.parse(value.interaction_resource.ical_fields)["start_datetime"]["value"];
          date = new Date(date);
          if(!min_date || (date < min_date && date > today_date)) {
            min_date = date;
          }
        }
      });
      if(min_date) {
        month = $scope.computeMonthName(min_date.getMonth(), $scope.auxlanguage).substring(0, 3);
        day = min_date.getDate();
        time = $scope.extractTimeFromDate(min_date);
        $scope.content_ical[content.id] = [month, day, time];
      } else {
        $scope.content_ical[content.id] = min_date;
      }
    }
    return $scope.content_ical[content.id];
  }

  $scope.checkAndGenerateIcalForView = function(calltoaction_info) {
    ical_info_list = getIcalInteractions(calltoaction_info.calltoaction.id);
    if (angular.isUndefined($scope.ical) && ical_info_list.length > 0) { 
      generateIcalForView(ical_info_list);
    }
    return ical_info_list.length > 0;
  };

  function generateIcalForView(ical_info_list) {
    $scope.ical = new Object({"dates": [], "times": [], "locations": [], "n": []});
    
    i = 0
    angular.forEach(ical_info_list, function(value, key) {
      _datetime = value.interaction.resource.ical.start_datetime.value;
      _location = value.interaction.resource.ical.location;
      _date = $scope.formatDate(_datetime, $scope.aux.language);

      date_index = $scope.ical.dates.indexOf(_date);
      location_index = $scope.ical.locations.indexOf(_location);

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

    });

  }

  $scope.orderContent = function(content) {
    return content["key"];
  };

  $scope.linkTo = function(url, stripe_name) {
    if(angular.isUndefined(stripe_name)) {
      stripe_name = "";
    }
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
    return url;
  };

}