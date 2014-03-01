# _ = require 'lodash'
# q = require 'q'
# module.exports = (app) ->
    app.controller 'ReadingController', ['$scope', '$state', '$stateParams', '$timeout', '$log', '$rootScope', 'ContentService', 'SearchService', ($scope, $state, $stateParams, $timeout, $log, $rootScope, ContentService, SearchService) ->
        database = undefined

        $scope.rightButtons = [
            (
                type: 'button-positive'
                content: '<i class="icon ion-android-search"></i>'
                tap: (e) ->
                    $state.go 'search'
            )
        ]

        $scope.data = _.defaults $stateParams, (
                type: 'page'
                current: 1
                view: []
                total: undefined
            )

        $scope.options =
            aya_mode: 'uthmani'
            view_mode: 'page_id'
            sura_name: 'sura_name'
            preferred: 'ayas'

        $scope.static =
            views: [
                (id: 'page_id' , name: 'Page')
                (id: 'sura_id' , name: 'Sura')
                (id: 'hizb_gid', name: 'Hizb')
            ]
            modes: [
                (id: 'standard'     , name: 'Standard')
                (id: 'standard_full', name: 'Standard (Full)')
                (id: 'uthmani'      , name: 'Uthmani (Full)')
                (id: 'uthmani_min'  , name: 'Uthmani (Minimum)')
            ]
            sura_name: [
                (id: 'sura_name'             , name: 'Arabic')
                (id: 'sura_name_en'          , name: 'English')
                (id: 'sura_name_romanization', name: 'Arabic (transliterated)')
            ]

        $scope.progress =
            status: 'init'
            total: 0
            current: 0

        ContentService.database.then (db) -> 
            database = db
            loadContent()
            $scope.$watch 'data.current', loadContent

        loadContent = () ->
            $scope.progress.status = 'loading'

            current = Number $scope.data.current

            query = switch $scope.data.type
                when 'page' then page_id: current
                when 'sura' then sura_id: current
                when 'juz'  then juz:     current


            database.find query
            .sort gid: 1 
            .exec (err, docs) ->
                if err then error err
                else
                    $scope.data.view = transform docs
                    $scope.progress.status = 'ready'
                    $log.debug 'Content ready', $scope.data
                    $scope.$apply()

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