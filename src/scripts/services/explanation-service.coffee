app.service 'ExplanationService', ['IDBStoreFactory', 'RESOURCES', '$log', (IDBStoreFactory, RESOURCES, $log) ->
    cache = []
    database = IDBStoreFactory "#{RESOURCES}/translations.json",
        dbVersion: 3
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
        cache["trans:#{id}"] || cache["trans:#{id}"] = database.then (properties) ->
            properties.findOne id: id
            .exec()
        .then (explanation) ->
            IDBStoreFactory "#{RESOURCES}/translations/#{explanation.file}",
                transformResponse: (response) ->
                    # $log.debug 'Got response:', response
                    response.data.split /\n/g
                    .map (item, index) ->
                        gid: index + 1, text: item
                dbVersion: explanation.version || 1
                storeName: id
                keyPath: 'gid'
                autoIncrement: no
                indexes: [(name: 'gid', unique: yes)]
                transforms: [
                    (item) ->
                        _.extend item, explanation
                ]
        .then (store) ->
            # Store in cache
            $log.debug "Store ready for explanation #{id}"
            store
        .catch (err) ->
            $log.error err
]