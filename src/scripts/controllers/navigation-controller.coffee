app.controller 'NavigationController', ['ContentService', '$scope', '$log', (ContentService, $scope, $log) ->
    ContentService.suras.then (db) ->
        db.find 'sura_id'
        .exec()
    .then (suras) ->
        $log.debug 'Assigning'
        $scope.suras = suras
]