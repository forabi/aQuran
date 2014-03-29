app.controller 'RecitationsController', ['$scope', '$log', 'RecitationService', ($scope, $log, RecitationService) ->
    $scope.recitations = []

    RecitationService.properties.then (db) ->
        db.find()
        .exec()
        .then (properties) ->
            $scope.recitations = _.chain properties
            .uniq true, 'name'
            .value()
    .catch (err) ->
        $log.error err
]