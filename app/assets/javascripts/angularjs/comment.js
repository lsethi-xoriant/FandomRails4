var commentModule = angular.module('CommentModule', ['ngRoute']);

CommentCtrl.$inject = ['$scope', '$window', '$http', '$timeout', '$interval'];
commentModule.controller('CommentCtrl', CommentCtrl);

// Gestione del csrf-token nelle chiamate ajax.
commentModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

function CommentCtrl($scope, $window, $http, $timeout, $interval) {

  $scope.init = function(current_user, interaction_id, must_be_approved, last_comment_show_date, first_comment_show_date, comment_append_counter) {

    $scope.last_comment_show_date = last_comment_show_date;
    $scope.first_comment_show_date = first_comment_show_date;

    $scope.current_user = current_user;
    $scope.interaction_id = interaction_id;

    $scope.must_be_approved = must_be_approved;

    $scope.comment_append_counter = comment_append_counter;
    $("#comment-append-counter-" + $scope.interaction_id).html($scope.comment_append_counter);

    $interval(function() { newCommentsPolling(); }, 15000);

  };

  $window.newCommentsPolling = function() {
    $http.post("/new_comments_polling", { interaction_id: $scope.interaction_id, first_comment_show_date: $scope.first_comment_show_date })
      .success(function(data) {

        if(data.first_comment_show_date) {
          $scope.first_comment_show_date = data.first_comment_show_date;
        }
        
        $("#comments-" + $scope.interaction_id).prepend(data.comments_to_append);
   
        showNewCommentFeedback();    
      }).error(function() {
        // ERROR.
      });
  }

  $window.appendComments = function() {
    if($scope.comment_append_counter > 0) {
      $http.post("/append_comments", { interaction_id: $scope.interaction_id, last_comment_show_date: $scope.last_comment_show_date })
        .success(function(data) {

          $scope.last_comment_show_date = data.last_comment_show_date;
          $("#comments-" + $scope.interaction_id).append(data.comments_to_append);

          $scope.comment_append_counter -= data.comments_to_append_counter;
          $("#comment-append-counter-" + $scope.interaction_id).html($scope.comment_append_counter);    

          showNewCommentFeedback();    
        }).error(function() {
          // ERROR.
        });
    }
  }

  $window.submitComment = function() {
    comment = $("#user-comment-" + $scope.interaction_id).val();
    captcha = $("#user-captcha-" + $scope.interaction_id).val();

    $http.post("/add_comment", { comment: comment, interaction_id: $scope.interaction_id, captcha: captcha })
      .success(function(data) {
        if(data.errors) {

          console.log("ERROR IN COMMENT SUBMIT");

        } else {

          if(!$scope.current_user) {

            if(!data.captcha_result) {

              $("#comment-captcha-error-feedback").modal("show");

            } else {

              if($scope.must_be_approved) {
                $("#comment-must-be-approved-feedback").html(comment);
              } else {
                $("#comment-modal-body").html(comment);
              }
              
              $("#comment-feedback").modal("show");

            }

            $("#captcha").attr("src", "/captcha/" + $scope.interaction_id);
            $("#user-comment-" + $scope.interaction_id).val("");
            $("#user-captcha-" + $scope.interaction_id).val("");

          } else {

            if($scope.must_be_approved) {
              $("#comment-must-be-approved-feedback").html(comment);
            } else {
              $("#comment-modal-body").html(comment);
            }
              
            $("#comment-feedback").modal("show");

          }

          newCommentsPolling();

          $("#user-comment-" + $scope.interaction_id).val("");
        }
      }).error(function() {
        // ERROR.
      });
  }

  function showNewCommentFeedback() {
    $(".new-comment").animate({ backgroundColor: "#FFF5E5" }, 1000, function() {  
      $timeout(function() { 
        $(".new-comment").animate({ backgroundColor: "transparent" }, 1000);
        $(".new-comment").removeClass("new-comment");
      }, 2000);
    });
  }


}