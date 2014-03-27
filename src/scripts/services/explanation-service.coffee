app.service 'ExplanationService', ['IDBStoreFactory', '$q', '$http', 'CacheService', '$log', 'Preferences', (IDBStoreFactory, $q, $http, CacheService, $log, Preferences) ->

    database = IDBStoreFactory 'resources/translations.json',
        dbVersion: 2
        storeName: 'explanations'
        keyPath: 'id'
        autoIncrement: no
        indexes: [
            (name: 'id', unique: yes)
            (name: 'country')
            (name: 'language')
        ]

    properties: database
    load: (id) ->
        # $log.debug "Loading store for #{id}"
        cached = CacheService.get "trans:#{id}"
        if cached
            # $log.debug "Translation #{id} retrieved from cache:", cached
            $q.when cached
        else
            database.then (properties) ->
                properties.findOne id: id
                .exec()
            .then (explanation) ->
                IDBStoreFactory "resources/translations/#{explanation.file}",
                    transformResponse: (response) ->
                        # $log.debug 'Got response:', response
                        response.data.split /\n/g
                        .map (item, index) ->
                            gid: index + 1, text: item
                    dbVersion: 1
                    storeName: id
                    keyPath: 'gid'
                    autoIncrement: no
                    indexes: [(name: 'gid', unique: yes)]
                    transforms: [
                        (item) ->
                            _.extend explanation, item
                    ]
            .then (store) ->
                # Store in cache
                $log.debug "Store ready for explanation #{id}"
                CacheService.put "trans:#{id}", store
                store
            .catch (err) ->
                $log.error err
]