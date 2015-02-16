var orderingModule = angular.module('OrderingModule', ['dndLists']);

orderingModule.controller('OrderingCtrl', OrderingCtrl);

function OrderingCtrl($scope) {

  $scope.models = {
    selected: null,
    lists: { "orderedElements": [], 
             "taggedCallToActions": [],
             "taggedRewards": [],
             "taggedTags": []
            }
  };

  $scope.init_ordering = function(orderedElements, callToActionNames, rewardNames, tagNames) {

    angular.forEach(orderedElements, function(el) {
      if(el != '')
        $scope.models.lists.orderedElements.push(el);
    });
    
    angular.forEach(callToActionNames, function(el) {
      if(el != '')
        $scope.models.lists.taggedCallToActions.push(el);
    });

    angular.forEach(rewardNames, function(el) {
      if(el != '')
        $scope.models.lists.taggedRewards.push(el);
    });

    angular.forEach(tagNames, function(el) {
      if(el != '')
        $scope.models.lists.taggedTags.push(el);
    });

  };

  // for (var i = 1; i <= 3; ++i) {
  //   $scope.models.lists.A.push({label: "Item A" + i});
  //   $scope.models.lists.B.push({label: "Item B" + i});
  // };

  $scope.$watch('models', function(model) {
    $scope.modelAsJson = angular.toJson(model, true);
  }, true);

};