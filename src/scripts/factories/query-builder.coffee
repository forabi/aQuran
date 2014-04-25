# _ = require('lodash')
app.factory 'QueryBuilder', ['$q', '$log', ($q, $log) ->
    (db, transforms) ->
        _index = undefined
        _limit = undefined
        _lower = undefined
        _upper = undefined
        _exclude_lower = no
        _exclude_upper = no
        # _iterate = no
        _order = 'ASC'
        _one = no
        _transforms = transforms || []

        _parse_bounds = (range) ->
            if range instanceof Array # Something like [1, 34]
                _lower = range[0]
                _upper = range[1] || null
            else # Number, String...
                _upper = _lower = range

        _make_range = ->
            # $log.debug 'Making key range for', _upper, _lower
            # debugger
            if not _lower and not _upper then undefined
            else
                try
                    db.makeKeyRange(
                        lower: Math.min _lower, _upper # Fix order of range if wrong
                        excludeLower: _exclude_lower
                        upper: Math.max _lower, _upper
                        excludeUpper: _exclude_upper
                        )
                catch err
                    _lower


        exec = ->
            deferred = $q.defer() # A deferred promise

            success = (result) ->
                deferred.resolve result

            error = (err) ->
                # $log.error err
                deferred.reject err

            # Options for IDBWrapper
            options =
                index: _index
                keyRange: _make_range()
                order: _order
                onError: error

            # $log.debug 'Executing query:', options
            # IDBWrapper method
            # if not _iterate
            db.query success, options
            # else
            #     db.iterate (current, cursor, trans) ->
            #         deferred.resolve
            #             value: current
            #             next: cursor.continue


            deferred.promise
            .then (results) ->
                if _transforms.length # Check if any transforms were registered
                    $q.all results.map (result) ->
                        result = fn result for fn in _transforms # Tranfsorm result in sepcified order
                        result
                else results
            .then (results) ->
                results = results[0] || null if _one # Returns only one object for findOne()
                results

        toCursor = ->
            _iterate = yes
            { transform, exec }

        transform = (fn) ->
            # Tranfsorms are functions that are iterated over with each result
            # we get from the query.
            # A transform returns a modified result that is passed to the next transform
            _transforms.push fn
            { exec }

        limit = (limit) ->
            _limit = limit # Not implemented yet
            { transform, exec }

        sort = (sort) ->
            _order = 'DESC' if Number(sort) is -1 or sort.match /^des/gi
            { limit, transform, exec }


        skip = (howMany) ->
            # Not implemented yet
            { limit, transform, exec }

        where = (index) ->
            _index = index

            between = (lower, upper) ->
                _lower = lower
                _upper = upper
                _exclude_lower = _exclude_upper = yes
                { limit, sort, transform, exec }

            from = (lower) ->
                _lower = lower
                { limit, sort, transform, exec, to: (upper) ->
                    _upper = upper
                    { limit, sort, transform, exec }
                }

            is_ = (value) -> # Do not confuse with findOne(),
                             # this may match multiple objects
                if value
                    _lower = _upper = value
                    { exec }
                else { exec, from, between, transform } # Syntactic sugar

            { between, is: is_, from, skip, limit, exec, transform }

        find = (query, range...) ->
            switch
                # db.find('page_id') or db.find()
                when not query or typeof query is 'string'
                    _index = query
                    _parse_bounds range
                    { exec, where, skip, limit, sort, transform }

                # db.find({ page_id: 4 }) or db.find({ page_id: [1, 3] })
                # or
                # db.find({page_id: [1, 3], limit: 1, sort: 'ASC'})

                when typeof query is 'object'
                    keys = _.keys query
                    if _.include keys, 'limit'
                        limit query.limit
                        _.pull keys, 'limit'

                    if _.include keys, 'sort'
                        sort query.sort
                        _.pull keys, 'sort'

                    throw new Error 'QueryBuilder is limited to one key per query' if keys.length > 1
                    _index = keys[0]
                    # $log.debug 'keys[0]', _index
                    range = query[_index]
                    # $log.debug "query[_index]", range
                    # debugger
                    _parse_bounds range
                    { exec, skip, limit, sort, transform }

        findOne = (query...) ->
            _one = yes # Set query option to individual object instead of array
            delete query.limit if query # Delete limit if exists
            limit 1 # Force set limit to 1
            find query... # Perform a normal query, the result is transformed in the promise

        findById = (id, query...) ->
            _index = 'id'
            find query...

        findOneById = (id, query...) ->
            _index = 'id'
            findOne query...

        { transform, find, findOne, findById, findOneById, where }
]