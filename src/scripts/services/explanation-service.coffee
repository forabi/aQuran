app.service 'ExplanationService', ['IDBStoreFactory', '$q', '$http', 'CacheService', '$log', 'Preferences', (IDBStoreFactory, $q, $http, CacheService, $log, Preferences) ->

    IDBStoreFactory 'resources/recitations.json',
        dbVersion: 1
        storeName: 'explanations'
        storePrefix: ''
        keyPath: 'id'
        autoIncrement: no
        indexes: [
            (name: 'gid', unique: yes)
            (name: 'country')
            (name: 'language')
        ]
    .then (store) ->
        $log.debug 'All explanations inserted:', store
    # database = $http.get 'resources/translations.json'
    # .then (response) ->
    #     db = new Nedb()
    #     indexes = [
    #         (fieldName: 'id', unique: yes)
    #         (fieldName: 'language')
    #         (fieldName: 'country')
    #     ]

    #     async.each indexes,
    #     ((index, callback) -> db.ensureIndex index, callback),
    #     (err) -> if err then $log.debug 'Error indexing translations', err
    #     else $log.info 'Indexes created for translations'

    #     deferred = $q.defer()
    #     db.insert response.data, (err, docs) ->
    #         if err
    #             $log.error err
    #             deferred.reject err
    #         else
    #             $log.info "#{docs.length} translations inserted"
    #             deferred.resolve db
    #     deferred.promise

    # properties: database
    # getExplanation: (id) ->
    #     if not Preferences.explanations.enabled then $q.reject 'Explanations disabled' 
    #     else
    #         cached = CacheService.get "trans:#{id}"
    #         if cached
    #             # $log.debug "Translation #{id} retrieved from cache:", cached
    #             $q.when cached
    #         else 
    #             database.then (db) ->
    #                 deferred = $q.defer()
    #                 db.findOne id: id, (err, properties) ->
    #                     if err then deferred.reject err
    #                     else deferred.resolve properties
    #                 deferred.promise
    #             .then (properties) ->
    #                 $q.all [properties, ($http.get "resources/translations/#{properties.file}", cache: yes)]
    #             .then (results) ->
    #                 $log.debug "Translation #{id} response:", results
    #                 properties: results[0]
    #                 content:
    #                     results[1].data.split /\n/g
    #             .then (translation) ->
    #                 # Store in cache
    #                 CacheService.put "trans:#{id}", translation
    #                 translation
]