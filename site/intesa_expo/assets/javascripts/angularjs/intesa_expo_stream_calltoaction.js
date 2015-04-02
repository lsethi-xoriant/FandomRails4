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

  $scope.areIcalInteractionsPresent = function(calltoaction_info) {
    return getIcalInteractions(calltoaction_info.calltoaction.id).length > 0
  };

  $scope.formatDateForDownloadInteractions = function(calltoaction_info, language) {
    ical_info_list = getIcalInteractions(calltoaction_info.calltoaction.id);
    date = ical_info_list[0].interaction.resource.ical.start_datetime.value;
    return $scope.formatDate(date, language);
  }

  $scope.extractTimeFromDateForDownloadInteractions = function(calltoaction_info) {
    ical_info_list = getIcalInteractions(calltoaction_info.calltoaction.id);
    times = []
    angular.forEach(interaction_info_list, function(value, key) {
      times.push($scope.extractTimeFromDate(value.interaction.resource.ical.start_datetime.value));
    });

    return times.join(", ");
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