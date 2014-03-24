app.controller 'RecitationsController', ['$scope', '$log', 'RecitationService', ($scope, $log, RecitationService) ->
    $scope.recitations = []

    RecitationService.properties.then (db) ->
        db.find()
        .exec()
        .then (properties) ->
            $log.debug properties
            $scope.recitations = properties
    .catch (err) ->
        $log.error err
]