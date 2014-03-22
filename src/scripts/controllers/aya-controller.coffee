# async = require 'async'
app.controller 'AyaController', ['$scope', 'ContentService' , '$stateParams', 'Preferences', '$log', ($scope, ContentService, $stateParams, Preferences, $log) ->
    # $log.debug 'Here we go'
    $scope.options = Preferences

    $scope.progress =
        status: 'init'

    $scope.aya = 
        gid: Number $stateParams.gid || 1

    ContentService.then (db) ->
        db.findOne()
        .where 'gid'
        .is $scope.aya.gid
        .exec()
        .then (aya) ->
            $scope.aya = aya
            $scope.progress.status = 'ready'
        # .catch (err) ->
        #     $scope...
]