# _ = require 'lodash'
# q = require 'q'
# module.exports = (app) ->
app.controller 'ContentController', ['$rootScope', '$scope', '$state', '$stateParams', '$log', 'ContentService', 'Preferences', ($rootScope, $scope, $state, $stateParams, $log, ContentService, Preferences) ->

    $scope.playlist = []

    $scope.pages = []

    $scope.view = _.defaults $stateParams, $scope.options.reader.view

    $scope.progress =
        status: 'init'
        total: 0
        current: 0

    $scope.$watch 'scrollTo', (n, o) ->
        if n > o then $scope.loadMore()

    # $scope.$on 'audioPlayer:ready', (player) ->
    #     $log.debug 'Player ready', player

    # $scope.$on 'audioPlayer.play', (i) ->
    #     $log.debug "Playing #{i}"

    transform = (docs) ->
        _.chain docs
        .map (aya, index) ->
            $scope.playlist.push aya.recitation
            aya.index = index
            aya
        .value()

    loadContent = () ->
        query = {}
        query[$scope.view.type] = $scope.view.current
        # $scope.progress.status = 'loading'
        ContentService.ayas.then (db) ->
            db.find query
            .exec()
        .then transform
        .then (content) ->
            $log.debug 'Content ready', content
            $rootScope.title = content[0].sura_name # TODO: use a proper title
            $scope.progress.status = 'ready'
            content
        , error, (message) ->
            $scope.progress.message = message

    $scope.loadMore = () ->
        # $log.debug 'Loading more...'
        $scope.view.current++
        loadContent()
        .then (content) ->
            # $log.debug 'New content ready', content
            # TODO: remove old content to reduce memory usage
            # array = $scope.pages
            # array = _.last array, Math.min array.length, 2
            # array.push content
            # $scope.pages = array
            $scope.pages.push content
            $scope.$broadcast 'scroll.infiniteScrollComplete'

    loadContent().then (content) ->
        $scope.pages.push content
        $scope.options.first_time = no
        $scope.scrollTo = $stateParams.scrollTo

    error = (err) ->
        $scope.progress.status = 'error'
        $scope.error = err
        $log.error 'Error', err
]