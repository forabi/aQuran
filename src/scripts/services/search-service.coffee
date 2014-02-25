q = require 'q'
_ = require 'lodash'
module.exports = (app) ->
    app.service 'SearchService', ['ContentService', '$log', '$http', (ContentService, $log, $http) -> 
        
        diacritics = '(ّ|َ|ً|ُ|ٌ|ِ|ِ|ٍ|ْ)'
        diacritics_regex = new RegExp diacritics, 'g'

        hamzas = '(آ|إ|أ|ء|ئ|ؤ|ا|ى|و)'
        hamzas_regex = new RegExp hamzas, 'g'

        search: (query, options = { }) -> 
            ContentService.database.then (database) ->
            
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
                    limit: 50,
                    skip: 0,
                    field: 'standard'
                )
               
                deferred = q.defer()

                # query = query.replace(hamzas_regex, hamzas.split(/./).join('|')) if options.ignoreHamzaCase
                # dicatrics are [\u0650-\u065f]

                if options.srtictDiacritics
                    #
                    # We want to replace all letters not having a diacritic
                    # so that it does not matter which diacritic they have
                    # when matching against the full text
                    #
                    # TODO
                    _re = new RegExp "[](?! " + diacritics + ")", 'g'
                    query = query.replace _re, + '{1}(?' + diacritics + ')*'
                    options.field = 'standard_full'

                else
                    query = query.replace diacritics_regex, ''

                if options.ignoreHamzaCase
                    query = query.replace hamzas_regex, hamzas

                # remove unnecessary spaces
                query = query.replace /\s{2,}/g, ' '
                query = query.trim()

                query = new RegExp query, 'gi'
                $log.debug 'Matching against', query

                query[options.field] = $regex: query
                cursor = database.find query
                
                # cursor.sort options.sort # This will not work

                # Sorting in NeDB is broken,
                # we cannot have sort with something like { sort1: 1, sort2: 2 }
                # because the properties of a object are randomly sorted when loaded in the browser.
                # So instead of that, we use lodash sortBy method (see the "transform" function in ContentController),
                # this a temporary fix, I will contribute an array-based sorting function

                # TODO: find some way to calculate total, so we
                # can know in advance if more is available
                # cursor.count (err, docs) ->
                console.log cursor

                cursor
                .skip options.skip
                .limit options.limit
                .exec (err, docs) ->
                    if err then deferred.reject err
                    else deferred.resolve docs, query ## RegExp that was used
                deferred.promise
    ]