# _ = require 'lodash'
# q = require 'q'
# module.exports = (app) ->
    app.controller 'ReadingController', ['$ionicLoading', '$scope', '$state', '$stateParams', '$timeout', '$log', 'ContentService', 'SearchService', 'RecitationService', 'Preferences', ($ionicLoading, $scope, $state, $stateParams, $timeout, $log, ContentService, SearchService, RecitationService, Preferences) ->
        database = undefined

        $scope.loading = $ionicLoading.show 
                content: '<i class="text-center icon icon-large ion-loading-c"></i>'
                animation: 'fade-in'
                showBackdrop: yes
                maxWidth: 200
                showDelay: 0

        $scope.rightButtons = [
            (
                type: 'button-positive'
                content: '<i class="icon ion-android-search"></i>'
                tap: (e) ->
                    $state.go 'search'
            ),
            (
                type: 'button-positive'
                content: '<i class="icon ion-android-more"></i>'
                tap: (e) ->
                    $state.go 'search'
            )
        ]

        $scope.playlist = []

        $scope.data = _.defaults $stateParams, (
                type: 'page'
                current: 1
                view: []
                total: undefined
                highlight: null
            )

        $scope.options = _.defaults Preferences, 
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
            $scope.loading.hide()
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
                    # $scope.playlist = []
                    # $scope.data.utmani = ''
                    # $scope.data.standard = ''
                    $scope.title = docs[0].sura_name
                    $scope.progress.status = 'ready'
                    $log.debug 'Content ready', $scope.data
                    $scope.$apply()
                    audioPlayer.load($scope.playlist, true)

        transform = (docs) ->
            # default sorting
            number = (n) ->
                n = '000' + n
                n.substr(n.length - 3)
            _.chain docs
            .sortBy 'gid'
            .groupBy 'sura_id'
            .map (ayas, key) -> 
                        ayas: ayas.map (aya) ->
                            aya = _.extend aya, 
                                recitation: 'http://www.everyayah.com/data/Hudhaify_32kbps/' +
                                    number(aya.sura_id) +
                                    number(aya.aya_id) + '.mp3'
                            $scope.playlist.push src: aya.recitation, type: 'audio/mp3'
                            console.log $scope.playlist
                            aya
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