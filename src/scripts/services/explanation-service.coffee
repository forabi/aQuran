app.service 'ExplanationService', ['$http', '$log', ($http, $log) ->
    ###
    TODO: fix this so we won't have to load the file every time
    we fetch a translation because this way performance will suffer

    Maybe a Nedb per translation is a good idea, but we will have
    to load all translations ahead of time as this service is independent
    of the Preferences service and the selected translations may change
    during runtime
    ###
    getExplanation: (id) ->
        $http.get "resources/#{id}.trans/#{id}.txt", cache: yes
        .then (response) ->
            $log.debug 'Translation response:', response
            properties: null
            content:
                response.data.split /\n/g
]