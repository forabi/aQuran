# _ = require 'lodash'
# q = require 'q'
# module.exports = (app) ->
    app.controller 'SearchController', ['$scope', '$rootScope', '$state', '$timeout', '$log', '$stateParams', 'SearchService', 'APIService', 'Preferences', ($scope, $rootScope, $state, $timeout, $log, $stateParams, SearchService, APIService, Preferences) ->

        $scope.options = Preferences

        $scope.progress =
            status: 'init'
            total: 0
            current: 0

        $scope.online = $rootScope.online

        $scope.search =
            query: $stateParams.query || ''
            suggestions: []
            results: []
            history: Preferences.search.history
            execute: (query = $scope.search.query) -> 
                $log.debug 'Search executing...'
                if query
                    $scope.progress.status = 'searching'
                    $timeout () ->
                        SearchService.search query
                        .then (transform)
                        .then (results) ->
                            $scope.search.results = results
                            if results.length
                                _.pull $scope.search.history, query
                                $scope.search.history.unshift query
                                $scope.progress.status = 'ready'
                                $scope.$apply()
                            else if $scope.options.search.online.enabled and $scope.online()
                                $log.debug 'No results found, going to fetch suggestions'
                                $scope.progress.status = 'ready'
                                $scope.$apply()
                                APIService.suggest(query).then (suggestions) ->
                                    $scope.search.suggestions = suggestions || []
                                    $log.debug 'Suggestions:', $scope.search.suggestions
                                    $scope.$apply()
                            else 
                                $scope.progress.status = 'ready'
                                $scope.$apply()
                        .catch(error)

        $scope.search.execute()

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
            .value() || []

        error = (err) ->
            $scope.progress.status = 'error'
            $scope.error = err
            $log.error 'Error', err
            $scope.$apply()
    ]