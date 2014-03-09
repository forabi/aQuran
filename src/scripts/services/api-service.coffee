app.service 'APIService', ['API', '$http', '$log', (API, $http, $log) ->     
    checkForErrors = (response) ->
        throw 'API Error' if response.data.error.code is not 0
        response
    query: (params) ->
        $http.get API, cache: true, params: _.defaults params, (action: 'search', unit: 'aya', traduction: 1, fuzzy: 'True')
    suggest: (term) ->
        $http.get API, params: (query: term, action: 'suggest', unit: 'aya')
        .then (checkForErrors)
        .then (response) ->
            $log.debug 'Response for suggestions', response
            suggestions = []
            _(response.data.suggest).each (words, key) ->
                words.forEach (word) -> suggestions.push 
                    string: term.replace key, word
                    replace: key
                    with: word
            _.pull suggestions, string: term
            suggestions
]