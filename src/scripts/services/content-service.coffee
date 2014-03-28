# nedb = require 'nedb'
# async = require 'async'
# module.exports = (app) -> 
app.service 'ContentService', ['IDBStoreFactory', 'ExplanationFactory', 'AudioSrcFactory', 'Preferences', '$http', '$q', '$log', (IDBStoreFactory, ExplanationFactory, AudioSrcFactory, Preferences, $http, $q, $log) -> 
    IDBStoreFactory 'resources/quran.json',
        dbVersion: 3
        storeName: 'ayas'
        keyPath: 'gid'
        autoIncrement: no
        indexes: [
                (name: 'gid', unique: yes)
                (name: 'page_id')
                (name: 'sura_id')
                (name: 'aya_id')
                (name: 'standard')
            ]
        transforms: [
            (aya) ->
                aya.sura_name = aya[Preferences.reader.sura_name]
                aya
            (aya) ->
                if Preferences.explanations.enabled
                    $q.all Preferences.explanations.ids.map (id) ->
                        # $log.debug "Loading explanation #{id} for aya #{aya.gid}"
                        ExplanationFactory id, aya.gid
                    .then (explanations) ->
                        aya.explanations = explanations
                        aya
                else aya
            (promise) ->
                # We expect a promise because the previous transform is async
                promise.then (aya) ->
                    if Preferences.audio.enabled
                        AudioSrcFactory aya.sura_id, aya.aya_id 
                        .then (audioSrc) ->
                            aya.recitation = audioSrc
                            aya
                    else aya
        ]
    .catch (err) ->
        $log.error err

    # database =
    #     $http.get 'resources/ayas.json'
    #     .then (response) ->
    #         db = new Nedb()
    #         indexes = [
    #             (fieldName: 'gid', unique: yes)
    #             (fieldName: 'page_id')
    #             (fieldName: 'sura_id')
    #             (fieldName: 'aya_id')
    #             (fieldName: 'standard')
    #         ]

    #         async.each indexes,
    #         ((index, callback) -> db.ensureIndex index, callback),
    #         (err) -> if err then $log.debug 'Error indexing datastore', err
    #         else $log.info 'Indexes created for ayas'

    #         deferred = $q.defer()
    #         db.insert response.data, (err, docs) ->
    #             if err
    #                 $log.error err
    #                 deferred.reject err
    #             else
    #                 $log.info "#{docs.length} ayas inserted"
    #                 deferred.resolve db
    #         deferred.promise
    
    # transform = (aya, callback) ->
    #     aya.recitation = RecitationService.getAya aya.sura_id, aya.aya_id
    #     async.mapSeries Preferences.explanations.ids, (id, callback) ->
    #         ExplanationService.getExplanation(id).then (explanation) ->
    #             callback null, (text: explanation.content[aya.gid - 1], properties: explanation.properties)
    #         .catch (reason) -> callback()
    #     , (err, results) ->
    #         if err then callback err
    #         else
    #             aya.explanations = results
    #             callback null, aya

    # findOne: (query, callback) ->
    #     database.then (db) ->
    #         db.findOne query, (err, aya) ->
    #             if err then callback err
    #             else transform aya, callback

    # find: (query, callback) ->
    #     database.then (db) ->
    #         db.find query, (err, ayas) ->
    #             if err then callback err
    #             else
    #                 async.mapSeries ayas, transform, (err, ayas) ->
    #                     if err then callback err
    #                     else callback null, ayas
]