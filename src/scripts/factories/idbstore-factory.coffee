# IDBStore = require 'idb-wrapper'
app.factory 'IDBStoreFactory', ['$q', '$http', '$log', 'QueryBuilder', 'Preferences', ($q, $http, $log, QueryBuilder, Preferences) ->
    (url, options) ->
        options = _.defaults options,
            dbVersion: 1
            transforms: []
            transformResponse: (response) -> response.data

        deferred = $q.defer()
        
        get = () -> 
            $http.get url, cache: yes
            .then(options.transformResponse)
        
        insert = (data) ->
            # TODO: clear database
            console.log 'DATA:', data
            d = $q.defer()
            store.putBatch data, () ->
                d.resolve store
            , (err) ->
                d.reject err
            Preferences["#{options.storeName}-version"] = options.dbVersion
            d.promise

        extend = (store) ->
            QueryBuilder store, options.transforms

        store = new IDBStore options
        store.onStoreReady = () ->
            if Number Preferences["#{options.storeName}-version"] is options.dbVersion
                deferred.resolve store
            else get().then(insert).then (store) -> deferred.resolve store
        store.onError = (err) ->
            deferred.reject err

        deferred.promise.then extend
]