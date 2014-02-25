nedb = require 'nedb'
q = require 'q'
module.exports = (app) -> 
    app.service 'ContentService', ['$http', '$log', ($http, $log) -> 
        database:
            $http.get 'resources/ayas.json'
            .then (response) ->
                db = new nedb()
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