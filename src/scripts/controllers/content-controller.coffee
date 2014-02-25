_ = require 'lodash'
q = require 'q'
module.exports = (app) ->
    app.controller 'ContentController', ['$scope', '$log', '$rootScope', 'ContentService', ($scope, $log, $rootScope, ContentService) ->
        database = undefined

        $scope.content =
            type: 'page'
            view: null
            previous: no
            current: 1
            next: no
            total: undefined
            options:
                mode: 'standard'
                modes: [
                    (id: 'standard'     , name: 'Standard')
                    (id: 'standard_full', name: 'Standard (Full)')
                    (id: 'uthmani'      , name: 'Uthmani (Full)')
                    (id: 'uthmani_min'  , name: 'Uthmani (Minimum)')
                ]

        $scope.search =
            execute: () -> 
                search standard: $regex: new RegExp $scope.search.text, 'g'
                .then (results) ->
                    $scope.progress.status = 'ready'
                    $scope.content.view = transform results
                    $scope.content.type = 'search'
                    $scope.$apply()
                .catch (error)

        $scope.progress =
            status: 'init'
            total: 0
            current: 0

        ContentService.database.then (db) -> 
            database = db
            loadContent()
            $scope.$watch 'content.current', loadContent

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
        
        search = (query, options) -> 
            $scope.progress.status = 'searching'
            deferred = q.defer()
            options = _(options).defaults
                matches: 'autocomplete'
                scope: 'all'
                sort:
                    gid: 1
                limit: 50

            database.find query
            .sort options.sort
            .limit options.limit
            .exec (err, docs) ->
                if err then deferred.reject err
                else deferred.resolve docs
            deferred.promise

        transform = (docs) ->
            _.chain docs
            .groupBy 'sura_name'
            .map (ayas, key) -> ayas: ayas, sura_name: key
            .value()

        error = (err) ->
            $scope.progress.status = 'error'
            $scope.error = err
            $log.error 'Error', err
            $scope.$apply()
    ]