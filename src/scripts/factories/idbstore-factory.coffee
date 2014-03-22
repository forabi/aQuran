# IDBStore = require 'idb-wrapper'
app.factory 'IDBStoreFactory', ['$q', '$http', '$log', 'QueryBuilder', 'Preferences', ($q, $http, $log, QueryBuilder, Preferences) ->
    (url, options) ->
        deferred = $q.defer()
        
        get = () -> $http.get url, cache: yes
        
        insert = (response) ->
            # TODO: clear database
            d = $q.defer()
            store.putBatch response.data, () ->
                d.resolve store
            , (err) ->
                d.reject err
            Preferences["#{options.storeName}-version"] = options.dbVersion
            d.promise

        extend = (store) ->
            QueryBuilder store

        store = new IDBStore _.extend options
        store.onStoreReady = () ->
            if Number Preferences["#{options.storeName}-version"] is options.dbVersion
                deferred.resolve store
            else get().then(insert).then (store) -> deferred.resolve store

        deferred.promise.then extend
]