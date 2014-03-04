app.service 'ExplanationService', ['$http', '$log', ($http, $log) ->
    getTranslation: (id) ->
        $http.get "resources/#{id}.trans/#{id}.txt"
        .then (response) ->
            $log.debug 'Translation response:', response
            properties: null
            content:
                response.data.split /\n/g
]