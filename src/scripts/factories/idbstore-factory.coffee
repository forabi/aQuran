app.factory 'IDBStoreFactory', ['$q', '$http', ($q, $http) ->
    (url, options) ->
        deferred = $q.defer()
        
        $http.get url, cahce: yes
        .then (response) ->
            insert = () ->
                store.putBatch response.data, () ->
                    deferred.resolve store
                , (err) ->
                    deferred.reject err

            store = new IDBStore _.extend options,
                onStoreReady: insert
]