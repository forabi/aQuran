app.service 'RecitationService', ['EveryAyah', '$http', '$log', (EveryAyah, $http, $log) ->
    $http.get 'resources/recitations.json'
    .then (response) ->
        $log.debug 'Available recitations:', response.data
        reciations: response.data
    .catch (response) ->
        $log.error 'Error retrieving reciations, got response:', response
]