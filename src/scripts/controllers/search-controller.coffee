# _ = require 'lodash'
# q = require 'q'
# module.exports = (app) ->
app.controller 'SearchController', ['$scope', '$rootScope', '$state', '$log', '$stateParams', 'SearchService', 'APIService', ($scope, $rootScope, $state, $log, $stateParams, SearchService, APIService) ->

    $scope.progress =
        status: 'init'
        total: 0
        current: 0
        message: ''

    $scope.search =
        query: $stateParams.query || ''
        suggestions: []
        results: []
        execute: (query = $scope.search.query) ->
            if query
                # $log.debug 'Search executing...'
                $scope.progress.status = 'searching'
                $scope.search.results = []
                SearchService.search query
                .then (results) ->
                    # $log.debug "Found #{results.length} results:", results
                    $scope.search.results = results
                    results
                .catch (reason) ->
                    if reason is 'NO_RESULTS'
                        # $log.debug 'No results found, going to fetch suggestions'
                        APIService.suggest query
                    else throw reason
                .then (suggestions) ->
                    $scope.search.suggestions = suggestions || []
                    # $log.debug 'Suggestions:', $scope.search.suggestions
                    suggestions
                .then ->
                    $scope.progress.status = 'ready'
                .catch error
                # .then undefined, undefined, (message) ->
                #     $scope.progress.message = message

    $scope.search.execute()

    error = (err) ->
        $scope.progress.status = 'error'
        $scope.error = err
        $log.error 'Error:', err
        $scope.$apply()
]