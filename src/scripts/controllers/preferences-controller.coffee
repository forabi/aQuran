app.controller 'PreferencesController', ['$scope', 'Preferences', '$log', 'ExplanationService', ($scope, Preferences, $log, ExplanationService) ->
    # $log.debug 'Here we go'
    $scope.options = Preferences
]