var commentModule = angular.module('CommentModule', ['ngRoute']);

CommentCtrl.$inject = ['$scope', '$window', '$http', '$timeout', '$interval'];
commentModule.controller('CommentCtrl', CommentCtrl);

// Gestione del csrf-token nelle chiamate ajax.
commentModule.config(["$httpProvider", function(provider) {
  provider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
}]);

function CommentCtrl($scope, $window, $http, $timeout, $interval) {

  $scope.init = function(current_user, interaction_id, must_be_approved, last_comment_shown_date, first_comment_shown_date, not_shown_comments_counter, captcha_data) {

    $scope.comment = new Object();

    $scope.comment.last_comment_shown_date = last_comment_shown_date;
    $scope.comment.first_comment_shown_date = first_comment_shown_date;

    $scope.comment.current_user = current_user;
    $scope.comment.interaction_id = interaction_id;

    $scope.comment.must_be_approved = must_be_approved;

    $scope.comment.ajax_polling_in_progress = false;
    $scope.comment.ajax_append_in_progress = false;

    $scope.comment.not_shown_comments_counter = not_shown_comments_counter;
    $("#comment-append-counter-" + $scope.comment.interaction_id).html($scope.comment.not_shown_comments_counter);

    $interval(function() { newCommentsPolling(); }, 15000);

    if(!$scope.comment.current_user) {
      initSessionStorageAndCaptchaImage(captcha_data);
    }

  };

  $window.initCaptcha = function() {
    $http.post("/captcha" , { })
      .success(function(data) { 
        initSessionStorageAndCaptchaImage(data)
      }).error(function() {
        // ERROR.
      });
  }

  $window.initSessionStorageAndCaptchaImage = function(captcha_data) {
    $("#captcha-img-" + $scope.comment.interaction_id).attr("src", 'data:image/jpeg;base64,' + captcha_data.image);
    sessionStorage.setItem("captcha" + $scope.comment.interaction_id, captcha_data.code);
  }

  $window.newCommentsPolling = function() {
    if(!$scope.comment.ajax_polling_in_progress) {

      $scope.comment.ajax_polling_in_progress = true;

      $http.post("/new_comments_polling", { interaction_id: $scope.comment.interaction_id, first_comment_shown_date: $scope.comment.first_comment_shown_date })
        .success(function(data) {

          if(haveNewCommentsToAppend(data)) {
            $scope.comment.first_comment_shown_date = data.first_comment_shown_date;
            $("#comments-" + $scope.comment.interaction_id).prepend(data.comments_to_append);
            showNewCommentFeedback();   
          }
        
          $scope.comment.ajax_polling_in_progress = false; 

        }).error(function() {

          $scope.comment.ajax_polling_in_progress = false;

        });
    }
  }

  $window.haveNewCommentsToAppend = function(data_from_new_comments_polling_ajax) {
    return data_from_new_comments_polling_ajax.first_comment_shown_date
  }

  $window.appendComments = function() {
    if($scope.comment.not_shown_comments_counter > 0 && !$scope.comment.ajax_append_in_progress) {
      $scope.comment.ajax_append_in_progress = true;
      $http.post("/append_comments", { interaction_id: $scope.comment.interaction_id, last_comment_shown_date: $scope.comment.last_comment_shown_date })
        .success(function(data) {

          $scope.comment.last_comment_shown_date = data.last_comment_shown_date;
          $("#comments-" + $scope.comment.interaction_id).append(data.comments_to_append);

          $scope.comment.not_shown_comments_counter -= data.comments_to_append_counter;
          $("#comment-append-counter-" + $scope.comment.interaction_id).html($scope.comment.not_shown_comments_counter);    

          showNewCommentFeedback();    
          $scope.comment.ajax_append_in_progress = false;
        }).error(function() {
          $scope.comment.ajax_append_in_progress = false;
        });
    }
  }

  $window.userFeedbackAfterSubmitCommentWithCaptcha = function(data_from_submit_comment_ajax) {

    if(data.captcha_check) {
      userFeedbackAfterSubmitComment(data_from_submit_comment_ajax);
    } else {
      $("#comment-captcha-error-feedback").modal("show");
    }

    initCaptcha();

    $("#user-captcha-" + $scope.comment.interaction_id).val("");

  }

  $window.userFeedbackAfterSubmitComment = function(data_from_submit_comment_ajax) {

    if($scope.comment.must_be_approved) {
      $("#comment-must-be-approved").css("display", "block");
    } else {
      $("#comment-must-be-approved").css("display", "none");
    }

    $("#comment-feedback").modal("show");
    
  }

  $window.submitComment = function() {
    comment = $("#user-comment-" + $scope.comment.interaction_id).val();
    user_filled_captcha = $("#user-captcha-" + $scope.comment.interaction_id).val();
    stored_captcha = sessionStorage["captcha" + $scope.comment.interaction_id];

    $("#comment-button-" + $scope.comment.interaction_id).attr('disabled', true);

    $http.post("/add_comment", { comment: comment, interaction_id: $scope.comment.interaction_id, user_filled_captcha: user_filled_captcha, stored_captcha: stored_captcha })
      .success(function(data) {
        if(data.errors) {
          // TODO: show errors in a modal.
        } else {

          if(!$scope.comment.current_user) {
            userFeedbackAfterSubmitComment(data);
          } else {
            userFeedbackAfterSubmitCommentWithCaptcha(data);
          }

          newCommentsPolling();
          $("#user-comment-" + $scope.comment.interaction_id).val("");
        }

        $("#comment-button-" + $scope.comment.interaction_id).attr('disabled', false);

      }).error(function() {
        $("#comment-button-" + $scope.comment.interaction_id).attr('disabled', false);
      });
  }

  function showNewCommentFeedback() {
    $(".new-comment").animate({ backgroundColor: "#FFF5E5" }, 1000, function() {  
      $timeout(function() { 
        $(".new-comment")
          .animate({ backgroundColor: "transparent" }, 1000)
          .removeClass("new-comment");
      }, 2000);
    });
  }

}