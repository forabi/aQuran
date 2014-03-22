# _ = require('lodash')
app.factory 'QueryBuilder', ['$q', '$log', ($q, $log) -> 
    (db) ->
        _index = undefined
        _limit = undefined
        _lower = undefined
        _upper = undefined
        _exclude_lower = no
        _exclude_upper = no
        _order = 'ASC'
        _one = no

        _parse_bounds = (range) ->
            if range instanceof Array # Something like [1, 34]
                _lower = range[0]
                _upper = range[1] || null
            else # Number, String...
                _lower = range
                _upper = _lower

        _make_range = () ->
            if not _lower and not _upper then undefined
            else
                db.makeKeyRange
                    lower: Math.min _lower, _upper # Fix order of range if wrong
                    excludeLower: _exclude_lower
                    upper: Math.max _lower, _upper
                    excludeUpper: _exclude_upper

        exec = () ->
            deferred = $q.defer() # A deferred promise
            
            success = (result) ->
                result = result[0] || null if _one # Returns only one object for findOne()
                deferred.resolve result
            
            error = (err) ->
                $log.error err
                deferred.reject err

            # Options for IDBWrapper
            options = _.omit
                index: _index
                keyRange: _make_range()
                order: _order
                onError: error
            , (item) -> not item # Remove all falsy values
                


            $log.debug 'Executing query:', options

            db.query success, options # IDBWrapper method

            deferred.promise

        limit = (limit) ->
            _limit = limit # Not implemented yet

        sort = (sort) ->
            _order = 'DESC' if sort.match /^des/gi or Number(sort) is -1

        where = (index) ->
            _index = index
            
            between = (lower, upper) ->
                _lower = lower
                _upper = upper
                _exclude_lower = yes
                _exclude_upper = yes
                limit: limit, sort: sort, exec: exec
            
            from = (lower) ->
                _lower = lower
                limit: limit, sort: sort, exec: exec,
                to: (upper) ->
                    _upper = upper
                    limit: limit, sort: sort, exec: exec

            is_ = (value) -> # Do not confuse with findOne(), this may match multiple objects
                if value
                    _lower = value
                    _upper = value
                    exec: exec
                else exec: exec, from: from, between: between # Syntactic sugar
            
            between: between, 'is': is_, from: from, limit: limit, exec: exec

        find = (query, range) ->
            switch 
                # db.find('page_id') or db.find()
                when not query or typeof query is 'string'
                    _index = query
                    _parse_bounds range
                    exec: exec, where: where, limit: limit, sort: sort

                # db.find({ page_id: 4 }) or db.find({ page_id: [1, 3] })
                # or
                # db.find({page_id: [1, 3], limit: 1, sort: 'ASC'})

                when typeof query is 'object'
                    keys = _.keys query
                    if _.include keys, 'limit' then limit query.limit and _.pull keys, 'limit'
                    if _.include keys, 'sort' then sort query.sort and _.pull keys, 'sort'
                    throw 'QueryBuilder is limited to one key per query' if keys.length > 1
                    _index = keys[0]
                    range = query[_index]
                    _parse_bounds range
                    exec: exec, limit: limit, sort: sort

        findOne = (query) ->
            _one = yes # Set query option to individual object instead of array
            delete query.limit if query # Delete limit if exists
            limit 1 # Force set limit to 1
            find query # Perform a normal query, the result is transformed in the promise

        findById = (id, query, range) ->
            _index = 'id'
            find query, range

        findOneById = (id, query) ->
            _index = 'id'
            find query

        find: find
        findOne: findOne
        findById: findById
        findOneById: findOneById
        where: where
]