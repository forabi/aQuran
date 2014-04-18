# async = require 'async'
app.controller 'AyaController', ['$scope', 'ContentService' , '$stateParams', '$log', ($scope, ContentService, $stateParams, $log) ->
    $scope.progress =
        status: 'init'

    $scope.aya =
        gid: Number $stateParams.gid || 1

    ContentService.ayas.then (db) ->
        db.findOne $scope.aya
        .exec()
        .then (aya) ->
            $scope.aya = aya
            $scope.progress.status = 'ready'
        # .catch (err) ->
        #     $scope...
]