app.service 'RecitationService', ['$sce', 'EveryAyah', 'Preferences', '$http', '$log', ($sce, EveryAyah, Preferences, $http, $log) ->
    repeat = (str, n) ->
        while n > 0
            str += str
            n--
        str
    number = (n, z='3') ->
        n = repeat('0', z) + n
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