app.factory 'QueryBuilder', ['$q', ($q) -> 
	(db) ->
		_index = 'id'
		_limit = undefined
		_range = undefined
		_order = 'ASC'

		makeRange = (lower, upper=lower) ->
			_range = db.makeKeyRange
				lower: Math.min lower, upper
				upper: Math.max lower, upper

		exec = () ->
			deferred = $q.defer()
			
			success = (result) ->
				deferred.resolve result
			
			error = (err) ->
				deferred.reject err

			options =
				index: _index
				keyRange: _range
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
				_range = makeRange lower, upper
				limit: limit, sort: sort, exec: exec
			is: (value) ->
				_range = makeRange value
				limit: limit, sort: sort, exec: exec

		find = (query, range) ->
			switch 
				when typeof query is 'string'
					_index = query
					makeRange range if range instanceof Array
					exec: exec, where: where, limit: limit, sort: sort
				when typeof query is 'object'
					keys = _.keys query
					if _.include keys, 'limit' then limit query.limit and _.pull keys, 'limit'
					if _.include keys, 'sort' then sort query.sort and _.pull keys, 'sort'
					throw 'QueryBuilder is limited to one key per query.' if keys.length > 1
					_index = keys[0]
					makeRange query[_index]
					exec: exec, limit: limit, sort: sort

		findOne = (query) ->
			delete query.limit
			limit 1
			find query
			.exec()
			.then (array) ->
				if array then array[0]
				else null

		find: find
		findOne: findOne
]