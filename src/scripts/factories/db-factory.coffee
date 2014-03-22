app.factory 'DBFactory', ['$q', '$http', ($q, $http) ->
    (url, options, notify = no) ->
        deferred = $q.defer()
        db.open options
        .done (server) -> 
            $http.get url, cache: yes
            .then (response) ->
                i = 0
                collection = server[options.name]
                content = response.data
                total = content.length
                
                insert = (item, callback) ->
                    collection.add item
                    .done () -> 
                        deferred.notify i++/total * 100 if options.notify
                        callback()
                    .fail callback

                async.eachSeries content, insert, (err) ->
                    if err then deferred.reject err
                    else deferred.resolve collection

        deferred.promise
]