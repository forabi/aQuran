app.factory 'IDBStoreFactory', ['$q', '$http', 'QueryBuilder', 'Preferences', ($q, $http, QueryBuilder, Preferences) ->
    (url, options) ->
        deferred = $q.defer()
        
        get = () -> $http.get url, cahce: yes
        
        insert = (response) ->
            if Preferences["#{options.storeName}-OK"] then store
            else
                d = $q.defer()

                store.putBatch response.data, () ->
                    d.resolve store
                , (err) ->
                    d.reject err

                Preferences["#{options.storeName}-OK"] = yes

                d.promise

        extend = (store) ->
            QueryBuilder store

        store = new IDBStore _.extend options,
            onStoreReady: () ->
                get().then(insert).then(extend).then (db) ->
                    deferred.resolve db

        deferred.promise
]