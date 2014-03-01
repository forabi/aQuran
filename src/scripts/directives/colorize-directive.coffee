# module.exports = (app) ->
    app.directive 'colorize', ['ArabicService', '$timeout', '$log', (Arabic, $timeout, $log) -> 
        restrict: 'A'
        replace: yes
        link: ($scope, $element, $attrs) ->
            colorize = (text, searchText, highlight) ->
                if searchText and highlight
                    if typeof highlight is 'string'
                        highlight = Arabic.getRegExp highlight
                    $log.debug 'Highligting strings matching',  highlight
                    searchText = searchText.replace highlight, "<span class='highlighted'>$1</span>"

                html = text.split(/\s+/g).map (word, index) ->
                    wordDiacritics   = word.replace Arabic.Quranic.Sign.RegExp, ''
                    wordSigns        = word.replace Arabic.Diacritics.RegExp, ''
                    wordBare         = word.replace Arabic.Quranic.Sign.RegExp, ''
                                          .replace Arabic.Diacritics.RegExp, ''

                    "<span class='layers'>
                        <span class='original'>#{word}</span>
                        <span class='diacritics'>#{wordDiacritics}</span>
                        <span class='quranic-signs'>#{wordSigns}</span>
                       <span class='letters'>#{wordBare}</span>
                     </span>"
                .join ' '

                if searchText then html = 
                    "<span class='layers'>
                        <span class='original'>#{searchText}</span>
                        <span class='overlay'>#{html}</span>
                    </span>"
                html

            $timeout () -> 
                text = $attrs['colorize']
                highlight = $attrs['highlight']
                searchText = $attrs['searchText']
                # $log.debug 'Text', text
                # $log.debug 'Full Text', searchText
                $element.html colorize text, searchText, highlight
    ]