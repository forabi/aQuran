app.service 'ExplanationService', ['IDBStoreFactory', 'DownloadQueue', 'ONLINE_RESOURCES', 'RESOURCES', '$log', (IDBStoreFactory, DownloadQueue, ONLINE_RESOURCES, RESOURCES, $log) ->
    cache = []
    database = IDBStoreFactory "#{RESOURCES}/translations.json",
        dbVersion: 4
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
        DownloadQueue.push "trans:#{id}"
        cache["trans:#{id}"] || cache["trans:#{id}"] = database.then (properties) ->
            properties.findOne id: id
            .exec()
        .then (explanation) ->
            $log.debug "Explanation", explanation
            IDBStoreFactory "#{if explanation.offline then RESOURCES else ONLINE_RESOURCES}/translations/#{explanation.file}",
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
            _.pull DownloadQueue, "trans:#{id}"
            store
        .catch (err) ->
            $log.error err
            _.pull DownloadQueue, "trans:#{id}"
]