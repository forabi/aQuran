# async = require 'async'
app.controller 'AyaController', ['$scope', 'ContentService' , '$stateParams', 'Preferences', '$log', ($scope, ContentService, $stateParams, Preferences, $log) ->
    # $log.debug 'Here we go'
    $scope.options = Preferences

    $scope.progress =
        status: 'init'

    $scope.aya = 
        gid: Number $stateParams.gid || 1

    ContentService.findOne gid: $scope.aya.gid, (err, aya) ->
        if err then $scope.progress.status = 'error'
        else 
            $scope.aya = aya
            $scope.progress.status = 'ready'
]