var ballandoIframeCalltoactionModule = angular.module('BallandoIframeCalltoactionModule', ['ngRoute']);

BallandoIframeCalltoactionCtrl.$inject = ['$scope', '$window', '$http'];
ballandoIframeCalltoactionModule.controller('BallandoIframeCalltoactionCtrl', BallandoIframeCalltoactionCtrl);

function BallandoIframeCalltoactionCtrl($scope, $window, $http, $timeout, $interval) {

  $scope.ballandoIframeCalltoactionCtrl = function(profile_url) {
    $scope.referrer = top.location.toString();
    $scope.profile_url = profile_url;

    $http.post("/iframe/get_check.json", { referrer: $scope.referrer })
      .success(function(data) {
        $("#check-container").html(data.template);
      });
  };
  
  $window.doCheck = function() {
    $(".button-inter-check").attr('disabled', true);
    $(".button-inter-check").attr('onclick', "");

    $http.post("/iframe/do_check.json", { referrer: $scope.referrer })
      .success(function(data) {
        $("#check-container").html(data.template);
      });
  };

  $window.showRegistrateView = function() {
    document.cookie = "connect_from_page = " + top.location + "; path=/";
    top.location = $scope.profile_url;
  };
  
  $window.onEnterInteraction = function(interaction_id, answer_id) {
    if(answer_id) {
      $("#answer-" + answer_id).find(".interaction-baloon .baloon.unchosen img").removeClass("hidden");
      $("#answer-" + answer_id).find(".interaction-baloon .baloon.unchosen").removeClass("square");
    } else {
      $("#iframe-interaction").find(".interaction-baloon .baloon.unchosen img").removeClass("hidden");
      $("#iframe-interaction").find(".interaction-baloon .baloon.unchosen").removeClass("square");
    }
  };

  $window.onLeaveInteraction = function(interaction_id, answer_id) {
    if(answer_id) {
      $("#answer-" + answer_id).find(".interaction-baloon .baloon.unchosen img").addClass("hidden");
      $("#answer-" + answer_id).find(".interaction-baloon .baloon.unchosen").addClass("square");
    } else {
      $("#iframe-interaction").find(".interaction-baloon .baloon.unchosen img").addClass("hidden");
      $("#iframe-interaction").find(".interaction-baloon .baloon.unchosen").addClass("square");
    }
  };

}