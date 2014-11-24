// Applicazione definita in ng-app="CalltoactionApp" all'interno di un nodo padre.
var fandomApp = angular.module('FandomApp', ['NoticeModule', 'StreamCalltoactionModule', 'CommentModule', 'FilterEventModule', 'BrowseModule', 'RankingModule']);

fandomApp.filter('unsafe', function($sce) {
  return function(value) {
    return $sce.trustAsHtml(value);
    };
});