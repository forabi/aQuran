# nedb = require 'nedb'
# async = require 'async'
# module.exports = (app) -> 
app.service 'ContentService', ['IDBStoreFactory', 'ExplanationFactory', 'AudioSrcFactory', 'Preferences', '$q', '$log', (IDBStoreFactory, ExplanationFactory, AudioSrcFactory, Preferences, $q, $log) -> 
    IDBStoreFactory 'resources/quran.json',
        dbVersion: 3
        storeName: 'ayas'
        keyPath: 'gid'
        autoIncrement: no
        indexes: [
                (name: 'gid', unique: yes)
                (name: 'page_id')
                (name: 'sura_id')
                (name: 'aya_id')
                (name: 'standard')
            ]
        transforms: [
            (aya) ->
                aya.sura_name = aya[Preferences.reader.sura_name]
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
                else aya
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
    .catch (err) ->
        $log.error err
]