{ Promise } = require 'Dexie'

# module.exports.delcare = (db, version) ->


module.exports.populate = (db, definition) ->
    { table_name, schema, filename } = definition
    db[table_name].count (count) ->
        if count is 0
            new Promise (resolve, reject) ->
                url = "./db/#{filename}"
                
                req = new XMLHttpRequest
                req.open 'GET', url
                req.responseType = 'json'
                
                req.onload = ->
                    if req.readyState is 4 and req.status <= 200
                        # console.log('Request success', req.response.length);
                        return resolve req.response
                    else if (req.readyState == 4 and req.status > 200)
                        return reject new Error req.response
                    null
                
                req.onprogress = (e) ->
                    if e.lengthComputable
                        percent = 100 * e.loaded / e.total
                        console.log '%d% Complete', percent
                
                req.send()
            .then (response) ->
                db.transaction 'rw', [table_name], ->
                    db[table_name].add item for item in response