# _ = require 'lodash'
# module.exports = (app) ->
app.service 'SearchService', ['APIService', 'ContentService', 'ArabicService', '$log', '$http', '$q', (APIService, ContentService, Arabic, $log, $http, $q) -> 
    search: (str, options = { }) -> 
        
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
                field: 'standard'
            )
       
        deferred = $q.defer()

        deferred.reject 'No query provided' if not str

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
            str = str.replace _re, + '$1(?' + Arabic.Diacritics.String + ')*'
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
        ContentService.find query, (err, docs) ->
            if err then deferred.reject err
            else deferred.resolve docs
        
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
]