app.service 'RecitationService', ['$sce', 'EveryAyah', 'Preferences', '$http', '$log', ($sce, EveryAyah, Preferences, $http, $log) ->
    number = (n, z='3') ->
        n = '0'.repeat(z) + n
        n.substr(n.length - 3)

    getRecitations: () ->
        $http.get 'resources/recitations.json'
        .then (response) ->
            $log.debug 'Available recitations:', response.data
            response.data
        .catch (response) ->
            $log.error 'Error retrieving reciations, got response:', response
    getAya: (sura, aya) ->
        sura = number sura
        aya  = number aya
        src = EveryAyah + Preferences.audio.id + "/#{sura}#{aya}.mp3"
        src: $sce.trustAsResourceUrl src
        type: 'audio/mp3'
]