_ = require 'lodash'
q = require 'q'
module.exports = (app) ->
    app.controller 'ContentController', ['$scope', '$log', '$rootScope', 'ContentService', 'SearchService', ($scope, $log, $rootScope, ContentService, SearchService) ->
        database = undefined

        $scope.content =
            type: 'page'
            view: null
            current: 1
            total: undefined
            options:
                mode: 'standard'

        $scope.static =
            modes: [
                (id: 'standard'     , name: 'Standard')
                (id: 'standard_full', name: 'Standard (Full)')
                (id: 'uthmani'      , name: 'Uthmani (Full)')
                (id: 'uthmani_min'  , name: 'Uthmani (Minimum)')
            ]

        $scope.search =
            execute: () -> 
                $scope.progress.status = 'searching'
                $scope.$apply() 
                SearchService.search $scope.search.text
                .then (results) ->
                    $scope.progress.status = 'ready'
                    $scope.content.view = transform results
                    $scope.content.type = 'search'
                    $scope.$apply()
                .catch(error)

        $scope.progress =
            status: 'init'
            total: 0
            current: 0

        ContentService.database.then (db) -> 
            database = db
            $scope.$watch 'content.current', loadContent
            loadContent()

        loadContent = () ->
            $scope.progress.status = 'loading'

            query = switch $scope.content.type
                when 'page' then page_id: $scope.content.current
                when 'sura' then sura_id: $scope.content.current
                when 'juz'  then juz:     $scope.content.current

            database.find query
            .sort gid: 1 
            .exec (err, docs) ->
                if err then error err
                else
                    $scope.content.view = transform docs
                    $scope.progress.status = 'ready'
                    $log.debug 'Content ready', $scope.content
                    $scope.$apply()

        transform = (docs) ->
            # default sorting
            _.chain docs
            .sortBy 'gid'
            .groupBy 'sura_id'
            .map (ayas, key) -> ayas: ayas, sura_name: ayas[0].sura_name, sura_id: ayas[0].sura_id
            .sortBy 'sura_id'
            .value()

        error = (err) ->
            $scope.progress.status = 'error'
            $scope.error = err
            $log.error 'Error', err
            $scope.$apply()
    ]