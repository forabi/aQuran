nedb = require 'nedb'
async = require 'async'
q = require 'q'
module.exports = (app) -> 
    app.service 'ContentService', ['$http', '$log', ($http, $log) -> 
        database:
            $http.get 'resources/ayas.json'
            .then (response) ->
                db = new nedb()
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

                defered = q.defer()
                db.insert response.data, (err, docs) ->
                    if err
                        $log.error err
                        defered.reject err
                    else
                        $log.info 'Documents inserted'
                        defered.resolve db
                defered.promise
    ]