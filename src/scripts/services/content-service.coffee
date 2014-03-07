# nedb = require 'nedb'
# async = require 'async'
# module.exports = (app) -> 
app.service 'ContentService', ['RecitationService', 'ExplanationService', 'Preferences', '$http', '$q', '$log', (RecitationService, ExplanationService, Preferences, $http, $q, $log) -> 
    database =
        $http.get 'resources/ayas.json'
        .then (response) ->
            db = new Nedb()
            indexes = [
                (fieldName: 'gid', unique: yes)
                (fieldName: 'page_id')
                (fieldName: 'sura_id')
                (fieldName: 'aya_id')
                (fieldName: 'standard')
            ]

            async.each indexes,
            ((index, callback) -> db.ensureIndex index, callback),
            (err) -> if err then $log.debug 'Error indexing datastore', err
            else $log.info 'Indexes created'

            deferred = $q.defer()
            db.insert response.data, (err, docs) ->
                if err
                    $log.error err
                    deferred.reject err
                else
                    $log.info "#{docs.length} documents inserted"
                    deferred.resolve db
            deferred.promise
    transform = (aya, callback) ->
        aya.recitation = RecitationService.getAya aya.sura_id, aya.aya_id
        async.mapSeries Preferences.explanations.ids, (id, callback) ->
            ExplanationService.getExplanation(id).then (explanation) ->
                callback null, (text: explanation.content[aya.gid - 1], properties: explanation.properties)
        , (err, results) ->
            if err then callback err
            else
                aya.explanations = results
                callback null, aya

    findOne: (query, callback) ->
        database.then (db) ->
            db.findOne query, (err, aya) ->
                if err then callback err
                else transform aya, callback

    find: (query, callback) ->
        database.then (db) ->
            db.find query, (err, ayas) ->
                if err then callback err
                else
                    async.mapSeries ayas, transform, (err, ayas) ->
                        if err then callback err
                        else callback null, ayas
]