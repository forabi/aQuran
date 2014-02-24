_ = require 'lodash'
module.exports = (app) ->
    app.controller 'ContentController', ($scope, $log, $rootScope) ->
        $scope.content =
            page_id: 1

        $scope.progress =
            status: "init"
        
        transform = (obj) ->
            _.chain(obj)
            .groupBy('sura_name')
            .map(sura_ayas, key -> ayas: sura_ayas, sura_name: key)
            .value()