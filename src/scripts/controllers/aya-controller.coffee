app.controller 'AyaController', ['$scope', 'ContentService' , 'RecitationService', 'ExplanationService', '$stateParams', 'Preferences', '$log', ($scope, ContentService, RecitationService, ExplanationService, $stateParams, Preferences, $log) ->
    # $log.debug 'Here we go'
    $scope.options = Preferences

    $scope.progress =
        status: 'init'

    $scope.aya = 
        gid: Number $stateParams.gid || 1

    ContentService.database.then (db) ->
        db.findOne gid: $scope.aya.gid, (err, aya) ->
            $log.debug 'Found', aya
            $scope.aya = aya
            $scope.aya.recitation = RecitationService.getAya aya.sura_id, aya.aya_id
            async.map Preferences.explanations.ids, (id, callback) ->
                ExplanationService.getTranslation(id).then (explanation) ->
                    callback null, text: explanation.content[aya.gid - 1]
            , (err, results) ->
                if err then $scope.progress.status = 'error'
                else
                    $scope.aya.explanations = results
                    $scope.progress.status = 'ready'
                $scope.$apply()
]