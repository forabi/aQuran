app.controller 'PreferencesController', ['$scope', 'Preferences', '$log', ($scope, Preferences, $log) ->
    # $log.debug 'Here we go'
    $scope.options = Preferences
]