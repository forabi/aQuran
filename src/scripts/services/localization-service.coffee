app.service 'LocalizationService', [ ->
    sanitizeText = (text) -> text.replace /@\w+/, ''

    countMatches = (text, match) ->
        matches = text.match new RegExp match, 'g'
        if matches then matches.length else 0

    isRTL: (text) ->
        text = sanitizeText text
        count_rtl = countMatches text, '[\\u060C-\\u06FE\\uFB50-\\uFEFC]'
        count_rtl * 100 / text.length > 20
]