# module.exports = (app) ->
    app.directive 'colorize', ['ArabicService', '$timeout', '$log', (Arabic, $timeout, $log) -> 
        restrict: 'A'
        replace: yes
        link: ($scope, $element, $attrs) ->
            colorize = (text, searchText, highlight) ->
                if searchText and highlight
                    if typeof highlight is 'string'
                        highlight = Arabic.getRegExp highlight
                    # $log.debug 'Highligting strings matching',  highlight
                    searchText = searchText.replace highlight, "<span class='highlighted'>$1</span>"

                html = text.split(/\s+/g).map (word, index) ->
                    "<span class='layers'>
                        <span class='diacritics'>#{word}</span>
                        <span class='quranic-signs'>#{word}</span>
                       <span class='letters'>#{word}</span>
                     </span>"
                .join ' '

                if searchText then html = 
                    "<span class='layers'>
                        <span class='original'>#{searchText}</span>
                        <span class='overlay'>#{html}</span>
                    </span>"
                html

            $timeout () -> 
                colorize = yes if $attrs.colorize and $attrs.colorize is not 'false'
                text = $attrs.colorizeText
                highlight = $attrs.highlight
                searchText = $attrs.searchText
                text = colorize text, searchText, highlight if colorize
                # $log.debug 'Text', text
                # $log.debug 'Full Text', searchText
                $element.html text
    ]