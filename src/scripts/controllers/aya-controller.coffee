# async = require 'async'
app.controller 'AyaController', ['$scope', 'ContentService' , '$stateParams', 'Preferences', '$log', ($scope, ContentService, $stateParams, Preferences, $log) ->
    # $log.debug 'Here we go'
    $scope.options = Preferences

    $scope.progress =
        status: 'init'

    $scope.aya = 
        sura_id: Number $stateParams.sura_id || 1
        aya_id: Number $stateParams.aya_id || 1

    console.log 'Here!'
    ContentService.findOne $scope.aya, (err, aya) ->
        console.log 'Here!'
        if err then $scope.progress.status = 'error'
        else 
            $scope.aya = aya
            $scope.progress.status = 'ready'
]