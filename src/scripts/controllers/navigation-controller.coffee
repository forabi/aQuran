app.controller 'NavigationController', ['ContentService', 'CacheService', '$scope', '$log', (ContentService, CacheService, $scope, $log) ->
    $scope.search = {}
    
    $scope.views = [
        (id: 'sura_id', display: 'Sura', store: 'suras')
        (id: 'juz_id', display: 'Juz', store: 'juzs')
    ]

    $scope.view = _.findWhere $scope.views, (item) -> item.id == $scope.options.nav.view.id

    transform = (items) ->
        _.map items, (item) ->
            item.title = switch $scope.view.id
                when 'sura_id' then item[$scope.options.reader.sura_name]
                when 'juz_id' then item.juz_id # TODO: filter()
            item

    $scope.$watch 'view.id', (id) ->
        cached = CacheService.get "navigation.#{id}"
        if not cached 
            cached = ContentService[$scope.view.store].then (db) ->
                db.find $scope.view.id
                .exec()
            CacheService.put "navigation.#{id}", cached

        cached
        .then transform
        .then (items) ->
            $scope.items = items

        $scope.options.nav.view.id = id
]