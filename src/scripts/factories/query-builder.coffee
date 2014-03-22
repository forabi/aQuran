# _ = require('lodash')
app.factory 'QueryBuilder', ['$q', ($q) -> 
    (db) ->
        _index = 'id'
        _limit = undefined
        _lower = undefined
        _upper = undefined
        _exclude_lower = no
        _exclude_upper = no
        _order = 'ASC'
        _one = no

        _parse_bounds = (range) ->
            if range instanceof Array
                _lower = range[0]
                _upper = range[1] || null
            else
                _lower = range
                _upper = _lower

        _make_range = () ->
            db.makeKeyRange
                lower: Math.min _lower, _upper
                exculdeLower: _exclude_lower
                upper: Math.max _lower, _upper
                excludeUpper: _exclude_upper

        exec = () ->
            deferred = $q.defer()
            
            success = (result) ->
                result = result[0] || null if _one
                deferred.resolve result
            
            error = (err) ->
                deferred.reject err

            options =
                index: _index
                keyRange: _make_range()
                order: _order
                onError: error

            db.query success, options

            deferred.promise

        limit = (limit) ->
            _limit = limit

        sort = (sort) ->
            _order = 'DESC' if Number sort is -1 or sort.match /^des/gi

        where = (index) ->
            _index = index
            exec: exec
            limit: limit
            between: (lower, upper) ->
                _lower = lower
                _upper = upper
                _exclude_lower = yes
                _exclude_uower = yes
                limit: limit, sort: sort, exec: exec
            from: (lower) ->
                _lower = lower
                limit: limit, sort: sort, exec: exec,
                to: (upper) ->
                    _upper = upper
                    limit: limit, sort: sort, exec: exec
            is: (value) ->
                _lower = value
                _upper = value
                exec: exec

        find = (query, range) ->
            switch 
                when not query or typeof query is 'string'
                    _index = query
                    _parse_bound range
                    exec: exec, where: where, limit: limit, sort: sort

                when typeof query is 'object'
                    keys = _.keys query
                    if _.include keys, 'limit' then limit query.limit and _.pull keys, 'limit'
                    if _.include keys, 'sort' then sort query.sort and _.pull keys, 'sort'
                    throw 'QueryBuilder is limited to one key per query.' if keys.length > 1
                    _index = keys[0]
                    range = query[_index]
                    _parse_bounds range
                    exec: exec, limit: limit, sort: sort

        findOne = (query) ->
            _one = yes
            delete query.limit if query
            limit 1
            find query

        find: find
        findOne: findOne
        where: where
]