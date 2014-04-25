# nedb = require 'nedb'
# async = require 'async'
app.service 'ContentService', ['IDBStoreFactory', 'ExplanationFactory', 'AudioSrcFactory', 'Preferences', '$q', '$log', (IDBStoreFactory, ExplanationFactory, AudioSrcFactory, Preferences, $q, $log) ->
    ayas =  IDBStoreFactory 'resources/quran.json',
        dbVersion: 10
        storeName: 'ayas'
        keyPath: 'gid'
        autoIncrement: no
        indexes: [
                (name: 'gid', unique: yes)
                (name: 'page_id')
                (name: 'sura_id')
                (name: 'juz_id')
                (name: 'aya_id')
            ]
        # TODO: add support for Mongoose-like `populate` feature
        # where we can fill properties from other collections using references
        transforms: [
            (aya) ->
                aya.sura_name = aya[Preferences.reader.sura_name] if aya.aya_id == 1
                aya.text = switch
                    when not Preferences.reader.diacritics then aya.standard
                    when Preferences.reader.standard_text and Preferences.reader.diacritics then aya.standard_full
                    else aya.uthmani
                aya
            (aya) ->
                if Preferences.explanations.enabled
                    $q.all Preferences.explanations.ids.map (id) ->
                        # $log.debug "Loading explanation #{id} for aya #{aya.gid}"
                        ExplanationFactory id, aya.gid
                    .then (explanations) ->
                        aya.explanations = explanations
                        aya
                else $q.when aya
            (promise) ->
                # We expect a promise because the previous transform is async
                promise.then (aya) ->
                    if Preferences.audio.enabled
                        AudioSrcFactory aya.sura_id, aya.aya_id
                        .then (audioSrc) ->
                            aya.recitation = audioSrc
                            aya
                    else aya
        ]

    suras = IDBStoreFactory 'resources/quran.json',
        dbVersion: 3
        storeName: 'suras'
        keyPath: 'sura_id'
        autoIncrement: no
        indexes: [ name: 'sura_id', unique: yes ]
        transformResponse: (response) ->
            _.chain response.data
            .uniq yes, (aya) -> aya.sura_id
            .map (aya) ->
                _.pick aya, 'sura_id', 'gid', 'page_id', 'sura_name', 'sura_name_en', 'sura_name_romanization', 'standard', 'standard_full', 'uthmani'
            .value()
        # Note: we do not need a transform for sura_name here
        # because we are doing it in sidemenu view, this will allow
        # us to cache the query while allowing the sura_name to dynamically
        # update outside of the cache.

    juzs = IDBStoreFactory 'resources/quran.json',
        dbVersion: 4
        storeName: 'juzs'
        keyPath: 'juz_id'
        autoIncrement: no
        indexes: [ name: 'juz_id', unique: yes ]
        transformResponse: (response) ->
            _.chain response.data
            .uniq yes, (aya) -> aya.juz_id
            .map (aya) ->
                _.pick aya, 'juz_id', 'gid', 'page_id', 'standard', 'standard_full', 'uthmani'
            .value()

    juzs: juzs
    suras: suras
    ayas: ayas
]