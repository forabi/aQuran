# _ = require 'lodash'
# q = require 'q'
# module.exports = (app) ->
    app.controller 'SearchController', ['$scope', '$timeout', '$log', '$rootScope', 'ContentService', 'SearchService', ($scope, $timeout, $log, $rootScope, ContentService, SearchService) ->
        database = undefined

        $scope.options =
            aya_mode: 'standard_full'
            view_mode: 'page_id'
            sura_name: 'sura_name'
            preferred: 'ayas'
            search:
                online:
                    enabled: true

        $scope.progress =
            status: 'init'
            total: 0
            current: 0

        $scope.search =
            query: ''
            results: []
            history: ['قرآن', 'سبحانك']
            execute: (query = $scope.search.query) -> 
                if query
                    $scope.progress.status = 'searching'
                    $scope.$apply() 
                    SearchService.search query
                    .then (results, regex) ->
                        $scope.search.results = transform results || []
                        # $scope.search.regex = regex.toString()
                        if results.length
                            _($scope.search.history).remove query if $scope.search.history.indexOf query > -1
                            $scope.search.history.unshift query
                        $scope.progress.status = 'ready'
                        $scope.$apply()
                    .catch(error)

        ContentService.database.then (db) -> 
            database = db
            # $scope.$watch 'search.query', $scope.search.execute

        transform = (docs) ->
            # default sorting
            _.chain docs
            .sortBy 'gid'
            .groupBy 'sura_id'
            .map (ayas, key) -> 
                        ayas: ayas
                        sura_name: ayas[0].sura_name
                        sura_name_romanization: ayas[0].sura_name_romanization
                        sura_id: ayas[0].sura_id
            .sortBy 'sura_id'
            .value()

        error = (err) ->
            $scope.progress.status = 'error'
            $scope.error = err
            $log.error 'Error', err
            $scope.$apply()
    ]