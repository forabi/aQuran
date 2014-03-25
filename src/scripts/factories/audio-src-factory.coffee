app.factory 'AudioSrcFactory', ['$sce', 'EveryAyah', 'Preferences', 'RecitationService', '$q', 'CacheService', '$log', ($sce, EveryAyah, Preferences, RecitationService, $q, CacheService, $log) ->
    repeat = (str, n) ->
        while n > 0
            str += str
            n--
        str
    max = (array) ->
        Math.max.apply Math, array

    number = (n, z='3') ->
        n = repeat('0', z) + n
        n.substr n.length - 3

    (sura, aya) ->
        sura = number sura
        aya  = number aya
        
        if not Preferences.audio.auto_quality or not navigator.mozConnection
            subfolder = Preferences.audio.recitation.subfolder
            src = "#{EveryAyah}/#{subfolder}/#{sura}#{aya}.mp3"
            $q.when
                src: $sce.trustAsResourceUrl src
                type: 'audio/mp3'
        else        
            getQuality = () ->
                cached = CacheService.get "audio:#{Preferences.audio.recitation.name}:quality"
                if cached then $q.when cached
                else
                    choose = (available) ->
                        # We need to find the highest available bitrate that is
                        # not higher than connection bandwidth so we can ensure a
                        # continuous stream
                        bandwidth = navigator.mozConnection.bandwidth
                        # $log.debug 'Bandwidth:', bandwidth
                        # $log.debug 'Available:', available
                        best = switch bandwidth
                            when Infinity then max available
                            else
                                _.remove available, (item) -> bandwidth < item * 8 / 1024
                                # $log.debug "After removal", available
                                max available
                        # $log.debug "Best quality:", best
                        best || available[0] # minimum available bitrate if bandwidth is too low

                    RecitationService.properties.then (db) ->
                        db.find().where('name').is(Preferences.audio.recitation.name).exec()
                    .then (available) ->
                        available.map (item) ->
                            Number item.subfolder.match(/(\d+)kbps/i)[1]
                    .then choose
                    .then (quality) ->
                        CacheService.put "audio:#{Preferences.audio.recitation.name}:quality", quality
                        quality
           
               getQuality().then (quality) ->
                    id = Preferences.audio.recitation.subfolder.match(/^(.+)_\d+kbps/i)[1]
                    subfolder = "#{id}_#{quality}kbps"
                    src = "#{EveryAyah}/#{subfolder}/#{sura}#{aya}.mp3"
                    # $log.debug 'audio src:', src
                    src: $sce.trustAsResourceUrl src
                    type: 'audio/mp3'
]