# IDBStore = require 'idb-wrapper'
app.factory 'IDBStoreFactory', ['$q', '$http', '$log', 'QueryBuilder', 'Preferences', ($q, $http, $log, QueryBuilder, Preferences) ->
    (url, options) ->
        upgrade = no
        options = _.defaults options,
            dbVersion: 1
            storePrefix: ''
            transforms: []
            transformResponse: (response) -> response.data

        deferred = $q.defer()

        get = () ->
            deferred.notify action: "STORE.FETCHING", data: storeName: options.storeName
            $http.get url, cache: yes
            .then(options.transformResponse)

        clear = () ->
            d = $q.defer()
            store.clear () ->
                d.resolve()
            , (err) ->
                $log.error err
                d.reject err
            d.promise

        insert = (data) ->
            # $log.debug 'Inserting...'
            deferred.notify
                action: if upgrade then "STORE.UPDATING" else "STORE.INSERTING"
                data: storeName: options.storeName
            d = $q.defer()
            store.putBatch data, () ->
                $log.info 'Data inserted.'
                Preferences["#{options.storeName}-version"] = options.dbVersion
                d.resolve store
            , (err) ->
                # $log.error 'Error inserting', err
                d.reject err
            d.promise

        extend = (store) ->
            find: (args...) -> QueryBuilder(store, options.transforms).find args...
            findOne: (args...) -> QueryBuilder(store, options.transforms).findOne args...
            findById: (args...) -> QueryBuilder(store, options.transforms).findById args...
            findOneById: (args...) -> QueryBuilder(store, options.transforms).findOneById args...
            where: (args...) -> QueryBuilder(store, options.transforms).where args...

        store = new IDBStore options
        store.onStoreReady = () ->
            version = Preferences["#{options.storeName}-version"]
            if not version then version = -1
            upgrade = yes if version > -1
            if Number Preferences["#{options.storeName}-version"] is options.dbVersion
                deferred.resolve store
            else if version > options.dbVersion
                clear().then(get).then(insert).then deferred.resolve
            else
                get().then(insert).then deferred.resolve
        store.onError = (err) ->
            deferred.reject err

        deferred.promise.then extend
]