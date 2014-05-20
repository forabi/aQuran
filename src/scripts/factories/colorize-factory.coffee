app.factory 'ColorizeFactory', ['Preferences', '$log', (Preferences, $log) ->
    (text, searchText, highlight, colorized = yes) ->
        if searchText and highlight
            if typeof highlight is 'string'
                highlight = Arabic.getRegExp highlight
            # $log.debug 'Highligting strings matching',  highlight
            searchText = searchText.replace highlight, "<span class='highlighted'>$1</span>"

        if Preferences.reader.colorized and colorized
            html = text.split(/\s+/g).map (word, index) ->
                "<span class='layers'>
                    <span class='diacritics'>#{word}</span>
                    <span class='quranic-signs'>#{word}</span>
                   <span class='letters'>#{word}</span>
                 </span>"
            .join ' '
        else html = text

        if searchText then html =
            "<span class='search layers'>
                <span class='original'>#{searchText}</span>
                <span class='overlay'>#{html}</span>
            </span>"
        html
]