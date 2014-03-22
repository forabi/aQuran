app.factory 'IDBStoreFactory', ['$q', '$http', 'QueryBuilder', ($q, $http, QueryBuilder) ->
    (url, options) ->
        deferred = $q.defer()
        
        get = () -> $http.get url, cahce: yes
        
        insert = (response) ->
            d = $q.defer()
            store.putBatch response.data, () ->
                d.resolve store
            , (err) ->
                d.reject err
            d.promise

        extend = (store) ->
            QueryBuilder store

        store = new IDBStore _.extend options,
            onStoreReady: () ->
                get().then(insert).then(extend).then (db) ->
                    deferred.resolve db

        deferred.promise
]