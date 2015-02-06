var disneyStreamCalltoactionModule = angular.module('DisneyStreamCalltoactionModule', ['ngRoute', 'ngSanitize', 'ngAnimate']);

DisneyStreamCalltoactionCtrl.$inject = ['$scope', '$window', '$http', '$timeout', '$interval', '$sce'];
disneyStreamCalltoactionModule.controller('DisneyStreamCalltoactionCtrl', DisneyStreamCalltoactionCtrl);

// Gestione del csrf-token nelle chiamate ajax.
disneyStreamCalltoactionModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);


function DisneyStreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document) {
  angular.extend(this, new StreamCalltoactionCtrl($scope, $window, $http, $timeout, $interval, $document));

  $scope.extraInit = function() {
    if($scope.current_user && !$scope.current_user.profile_completed) {
      $("#complete-registration").modal("show");
      $scope.form_data.current_user = new Object();
      $scope.form_data.current_user.username = $scope.current_user.username;
    }

    if($scope.aux.flash_notice == "from-disney-registration") {
      $("#modal__from-disney-registration").modal("show");
    }

  };

  $scope.angularReady = function() {
    if($scope.calltoactions.length == 1 && $scope.calltoactions[0].calltoaction.media_type == "IFRAME") {

      var hasFlash = false;
      try {
        hasFlash = Boolean(new ActiveXObject('ShockwaveFlash.ShockwaveFlash'));
      } catch(exception) {
        hasFlash = ('undefined' != typeof navigator.mimeTypes['application/x-shockwave-flash']);
      }

      calltoaction = $scope.calltoactions[0].calltoaction;
      if(hasFlash) {
        $("#iframe-calltoaction-" + calltoaction.id).html(calltoaction.media_data);
      } else {
        $("#iframe-calltoaction-" + calltoaction.id).html("Accedi da desktop per visualizzare questo contenuto");
        $("#iframe-calltoaction-" + calltoaction.id).removeClass();
        $("#iframe-calltoaction-" + calltoaction.id).addClass("text-center");
      }
    } 
  };

  $scope.appendCallToActionOtherParams = function() {
    console.log($scope.aux);
    if($scope.aux.gallery) {
      other_params = new Object();
      other_params.gallery = new Object();
      if($scope.aux.gallery.calltoaction) {
        other_params.gallery.calltoaction_id = $scope.aux.gallery.calltoaction.id;
      } else {
        other_params.gallery.calltoaction_id = "all";
      }
      return other_params;
    } else {
      return null;
    } 
  }

  $scope.setAvatar = function(avatar, id) {
    $scope.form_data.current_user.avatar_selected_url = avatar;
    $(".avatars__flexslider__avatar-container").removeClass("avatars__flexslider__avatar-container--selected");
    $("#avatar_" + id + "__flexslider__avatar-container").addClass("avatars__flexslider__avatar-container--selected");
  };

  $scope.processRegistrationForm = function() {
    delete $scope.form_data.current_user.errors;
    data = { user: $scope.form_data.current_user };
    $http({ method: 'POST', url: '/profile/complete_registration', data: data })
      .success(function(data) {
        if(data.errors) {
          $scope.form_data.current_user.errors = data.errors;
        } else {
          $scope.current_user.avatar = data.avatar;
          $scope.current_user.username = data.username;
          $("#complete-registration").modal("hide");
        }
      });
  };

}