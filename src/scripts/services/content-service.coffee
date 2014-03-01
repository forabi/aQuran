# nedb = require 'nedb'
# async = require 'async'
# Q = require 'q'
# module.exports = (app) -> 
    app.service 'ContentService', ['$http', '$log', ($http, $log) -> 
        database:
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

                deferred = Q.defer()
                db.insert response.data, (err, docs) ->
                    if err
                        $log.error err
                        deferred.reject err
                    else
                        $log.info "#{docs.length} documents inserted"
                        deferred.resolve db
                deferred.promise
    ]