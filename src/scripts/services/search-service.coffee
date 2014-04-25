# _ = require 'lodash'
# module.exports = (app) ->
app.service 'SearchService', [
    'APIService', 'ContentService', 'ArabicService',
    'Preferences', '$log', '$http', '$q',
    (APIService, ContentService, Arabic, Preferences, $log, $http, $q) ->
        # We cannot perform a regex search on an indexedDB
        # so we load a subset of ayas data into memory with
        # the excellent louischatriot/nedb which allows
        # queries with MongoDb-like syntax

        database = undefined
        loadDatabase = ->
            database = $http.get 'resources/search.json', cache: yes
            .then (response) ->
                response.data
            .then (ayas) ->
                deferred = $q.defer()
                db = new Nedb()
                db.insert ayas, (err) ->
                    if err then throw err
                    deferred.resolve db
                deferred.promise

        getFromIDBStore = (ayas) ->
            deferred = $q.defer()
            # notify 'Preparing results...'
            ContentService.ayas.then (idb) ->
                async.mapLimit ayas, 10, (aya, callback) ->
                    idb.findOne gid: aya.gid
                    .exec()
                    .then (aya) ->
                        callback null, aya
                , (err, all) ->
                    if err then throw err
                    # deferred.resolve all
                    deferred.resolve _.merge ayas, all
            deferred.promise

        methods = {}
        methods.online = (str, options) ->
            $log.debug 'Searching online...'
            APIService.query(
                action: 'search'
                unit: 'aya'
                traduction: 1
                query: str
                sortedBy: 'mushaf'
                word_info: 'False'
                recitation: 0
                aya_position_info: 'True'
                aya_sajda_info: 'False'
                fuzzy: 'True'
                script: 'standard'
                vocalized: 'True'
                range: '25'
                perpage: '25'
            ).then (response) ->
                $log.debug 'Online search response:', response
                # Remap response to match assumed schema
                data = _(response.data.search.ayas).map (aya, index) ->
                    gid: aya.identifier.gid, index: index
                    # $log.log 'Processing aya:', aya
                    # _.extend aya.identifier,
                    #     index: index
                    #     html: aya.aya.text
                    #     standard_full: aya.aya.text_no_highlight
                    #     sura_name: aya.sura.arabic_name
                    #     sura_name_en: aya.sura.english_name
                    #     page_id: aya.position.page
                .toArray()
                .sortBy 'index'
                .value()
                # $log.debug 'Tranformed online search data:', data
                data


        methods.offline = (str, options) ->
            # Make sure our database is only loaded once,
            # and only when performing an offline search
            (database || loadDatabase()).then (db) ->
                deferred = $q.defer()

                # str = str.replace(Arabic.Hamzas.RegExp, Arabic.Hamzas.String.split(/./).join('|')) if options.ignoreHamzaCase
                # dicatrics are [\u0650-\u065f]

                if options.srtictDiacritics
                    #
                    # We want to replace all letters not having a diacritic
                    # so that it does not matter which diacritic they have
                    # when matching against the full text
                    #
                    # TODO
                    _re = new RegExp "[](?! " + Arabic.Diacritics.String + ")", 'g'
                    str = str.replace _re, '$1(?' + Arabic.Diacritics.String + ')*'
                    options.field = 'standard_full'

                else
                    str = str.replace Arabic.Diacritics.RegExp, ''

                if options.ignoreHamzaCase
                    str = str.replace Arabic.Hamzas.RegExp, Arabic.Hamzas.String

                # remove unnecessary spaces
                str = str.replace /\s{2,}/g, ' '
                str = str.trim()

                # if options.wholeWord
                #     str = str
                #     .split /\s/g
                #     .map (word) -> '\b' + word + '\b'
                #     .join ' '

                regex = new RegExp str, 'gi'
                # $log.debug 'Matching against', regex

                query = { }
                query[options.field] = $regex: regex
                # cursor = database.find query
                db.find query
                .sort gid: 1
                .exec (err, all) ->
                    if err then throw err
                    deferred.resolve all

                # cursor.sort options.sort # This will not work

                # Sorting in NeDB is broken,
                # we cannot have sort with something like { sort1: 1, sort2: 2 }
                # because the properties of an object are randomly sorted when loaded in the browser.
                # So instead of that, we use lodash sortBy method (see the "transform" function in ContentController),
                # this a temporary fix, I will contribute an array-based sorting function

                # TODO: find some way to calculate total, so we
                # can know in advance if more is available
                # cursor.count (err, docs) ->
                # console.log cursor

                # cursor
                # .skip options.skip
                # .limit options.limit
                # .exec (err, docs) ->
                #     if err then deferred.reject err
                #     else deferred.resolve docs, regex
                deferred.promise

        search: (str, options = {}) ->
            options = _.defaults options, (
                    matches: 'autocomplete'
                    srtictDiacritics: no
                    ignoreHamzaCase: yes
                    onlyStartAya: no
                    wholeWord: yes
                    scope: 'all'
                    sort: [
                        (sura_id: 1)
                        (aya_id: 1)
                    ]
                    limit: 0,
                    skip: 0,
                    field: 'standard',
                    online: Preferences.search.online.enabled
                )

            if not str
                $q.reject 'NO_QUERY'
            else
                mode = 'offline'
                mode = 'online' if options.online
                methods[mode] str, options
                .catch (reason) ->
                    if mode != 'offline' then methods.offline str, options
                    else throw reason
                .then getFromIDBStore
                .then (results) ->
                    if results.length
                        _.pull Preferences.search.history, str
                        Preferences.search.history.unshift str
                        Preferences.search.history = Preferences.search.history.slice 0, Preferences.search.max_history
                        results
                    else throw new Error 'NO_RESULTS'
]