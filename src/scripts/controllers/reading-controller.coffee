# _ = require 'lodash'
# q = require 'q'
# module.exports = (app) ->
app.controller 'ReadingController', ['$ionicLoading', '$rootScope', '$scope', '$state', '$stateParams', '$timeout', '$log', 'ContentService', 'SearchService', 'Preferences', ($ionicLoading, $rootScope, $scope, $state, $stateParams, $timeout, $log, ContentService, SearchService, Preferences) ->
    # database = undefined

    # $scope.loading = $ionicLoading.show 
    #         content: '<i class="text-center icon icon-large ion-loading-c"></i>'
    #         animation: 'fade-in'
    #         showBackdrop: yes
    #         maxWidth: 200
    #         showDelay: 0
    $scope.playlist = []

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

    $scope.view = _.defaults $stateParams, $scope.options.reader.view

    # $scope.static =
    #     views: [
    #         (id: 'page_id' , name: 'Page')
    #         (id: 'sura_id' , name: 'Sura')
    #         (id: 'hizb_gid', name: 'Hizb')
    #     ]
    #     modes: [
    #         (id: 'standard'     , name: 'Standard')
    #         (id: 'standard_full', name: 'Standard (Full)')
    #         (id: 'uthmani'      , name: 'Uthmani (Full)')
    #         (id: 'uthmani_min'  , name: 'Uthmani (Minimum)')
    #     ]
    #     sura_name: [
    #         (id: 'sura_name'             , name: 'Arabic')
    #         (id: 'sura_name_en'          , name: 'English')
    #         (id: 'sura_name_romanization', name: 'Arabic (transliterated)')
    #     ]

    $scope.progress =
        status: 'init'
        total: 0
        current: 0

    transform = (docs) ->
        # default sorting
        _.chain docs
        .map (aya, index) -> 
            $scope.playlist.push aya.recitation
            aya.index = index
            aya
        .sortBy 'gid'
        .groupBy 'sura_id'
        .map (ayas, key) -> 
            ayas: ayas
            sura_name: ayas[0].sura_name
            sura_name_romanization: ayas[0].sura_name_romanization
            sura_id: ayas[0].sura_id
        .sortBy 'sura_id'
        .value()

    loadContent = () ->
        query = {}
        query[$scope.view.type] = $scope.view.current
        $scope.progress.status = 'loading'
        ContentService.then (db) ->   
            db.find query
            .exec()
        .then transform
        .then (content) ->
            $log.debug 'Content ready', content
            $rootScope.title = content[0].sura_name # TODO: use a proper title
            $scope.progress.status = 'ready'
            content
        .catch error

    $scope.loadMore = () ->
        $log.debug 'Loading more...'
        $scope.content.current++
        loadContent()
        .then (content) ->
            $log.debug 'New content ready', content
            $scope.view.content.concat content  
            $scope.$broadcast 'scroll.infiniteScrollComplete'

    loadContent().then (content) ->
        $scope.view.content = content
        $scope.options.first_time = no

    error = (err) ->
        $scope.progress.status = 'error'
        $scope.error = err
        $log.error 'Error', err
]