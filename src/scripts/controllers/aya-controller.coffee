# async = require 'async'
app.controller 'AyaController', ['$scope', 'ContentService' , '$stateParams', 'Preferences', '$log', ($scope, ContentService, $stateParams, Preferences, $log) ->
    $scope.options = Preferences

    $scope.progress =
        status: 'init'

    $scope.aya = 
        gid: Number $stateParams.gid || 1

    ContentService.then (db) ->
        db.findOne $scope.aya
        .exec()
        .then (aya) ->
            $scope.aya = aya
            $scope.progress.status = 'ready'
        # .catch (err) ->
        #     $scope...
]