app.controller 'RecitationsController', ['$scope', '$log', 'RecitationService', ($scope, $log, RecitationService) ->
    $scope.recitations = []

    $scope.set = (recitation) ->
        $scope.options.audio.recitation = recitation

    RecitationService.properties.then (db) ->
        db.find()
        .exec()
        .then (properties) ->
            # $log.debug properties
            $scope.recitations = _.chain properties
            .uniq true, 'name'
            .value()
    .catch (err) ->
        $log.error err
]