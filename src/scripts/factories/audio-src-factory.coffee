app.factory 'AudioSrcFactory', ['$sce', 'EveryAyah', 'Preferences', ($sce, EveryAyah, Preferences) ->
    repeat = (str, n) ->
        while n > 0
            str += str
            n--
        str
    
    number = (n, z='3') ->
        n = repeat('0', z) + n
        n.substr n.length - 3

    (sura, aya) ->
        sura = number sura
        aya  = number aya
        src = EveryAyah + Preferences.audio.id + "/#{sura}#{aya}.mp3"
        src: $sce.trustAsResourceUrl src
        type: 'audio/mp3'
]