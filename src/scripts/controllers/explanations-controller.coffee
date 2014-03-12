app.controller 'ExplanationsController', ['$scope', 'Preferences', '$log', 'ExplanationService', ($scope, Preferences, $log, ExplanationService) ->
    # $log.debug 'Here we go'
    $scope.options = Preferences
    $scope.explanations = { }
    

    
    ExplanationService.properties.then (db) ->
        $scope.enable = (item) ->
            $scope.explanations.enabled.push item
            item.enabled = yes
            Preferences.explanations.ids = _.pluck $scope.explanations.enabled, 'id'

        db.find id: $nin: Preferences.explanations.ids
        .sort language: 1
        .exec (err, properties) ->
            $scope.explanations.available = properties
            $scope.$apply()
        
        db.find id: $in: Preferences.explanations.ids
        .sort language: 1
        .exec (err, properties) ->
            $scope.explanations.enabled = properties
            $scope.$apply()
]