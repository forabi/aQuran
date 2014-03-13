app.controller 'ExplanationsController', ['$scope', 'Preferences', '$log', 'ExplanationService', ($scope, Preferences, $log, ExplanationService) ->
    # $log.debug 'Here we go'
    $scope.options = Preferences
    $scope.explanations = { }
    
    ExplanationService.properties.then (db) ->
        transform = (obj) ->
            _.chain obj
            .sortBy ['language', 'name']
            .value()

        $scope.toggle = (item) ->
            if not $scope.isEnabled item
                $log.debug "Item #{item.id} will be enabled now"
                $scope.explanations.enabled.push item
            else
                $log.debug "Item #{item.id} will be disabled now"
                _.remove $scope.explanations.enabled, id: item.id
            Preferences.explanations.ids = _.pluck $scope.explanations.enabled, 'id'

        $scope.isEnabled = (item) ->
            # $log.debug 'item.id:', item.id
            # $log.debug 'Preferences.explanations.ids:', Preferences.explanations.ids
            _.contains Preferences.explanations.ids, item.id
        
        db.find { }
        # .sort language: 1
        .exec (err, properties) ->
            $scope.explanations.available = transform properties
            $scope.$apply()
        
        db.find id: $in: Preferences.explanations.ids
        # .sort language: 1
        .exec (err, properties) ->
            $scope.explanations.enabled = transform properties
            $scope.$apply()
]