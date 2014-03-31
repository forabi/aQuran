# IDBStore = require 'idb-wrapper'
app.factory 'IDBStoreFactory', ['$q', '$http', '$log', 'QueryBuilder', 'Preferences', ($q, $http, $log, QueryBuilder, Preferences) ->
    (url, options) ->
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
        
        insert = (data) ->
            # TODO: clear database
            # console.log 'DATA:', data
            deferred.notify action: "STORE.INSERTING", data: storeName: options.storeName
            d = $q.defer()
            store.putBatch data, () ->
                d.resolve store
            , (err) ->
                d.reject err
            Preferences["#{options.storeName}-version"] = options.dbVersion
            d.promise

        extend = (store) ->
            find: (args...) -> QueryBuilder(store, options.transforms).find args...
            findOne: (args...) -> QueryBuilder(store, options.transforms).findOne args...
            findById: (args...) -> QueryBuilder(store, options.transforms).findById args...
            findOneById: (args...) -> QueryBuilder(store, options.transforms).findOneById args...
            where: (args...) -> QueryBuilder(store, options.transforms).where args...

        store = new IDBStore options
        store.onStoreReady = () ->
            if Number Preferences["#{options.storeName}-version"] is options.dbVersion
                deferred.resolve store
            else get().then(insert).then deferred.resolve
        store.onError = (err) ->
            deferred.reject err

        deferred.promise.then extend
]