var ballandoIframeCalltoactionModule = angular.module('BallandoIframeCalltoactionModule', ['ngRoute']);

BallandoIframeCalltoactionCtrl.$inject = ['$scope', '$window', '$http'];
ballandoIframeCalltoactionModule.controller('BallandoIframeCalltoactionCtrl', BallandoIframeCalltoactionCtrl);

function BallandoIframeCalltoactionCtrl($scope, $window, $http, $timeout, $interval) {

  $window.showRegistrateView = function() {
    document.cookie = "connect_from_page = " + top.location;
    top.location = PROFILE_URL;
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