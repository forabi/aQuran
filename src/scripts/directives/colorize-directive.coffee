# module.exports = (app) ->
app.directive 'colorize', ['ArabicService', '$timeout', '$log', (Arabic, $timeout, $log) ->
    process = (text, searchText, highlight, colorized=yes) ->
        if searchText and highlight
            if typeof highlight is 'string'
                highlight = Arabic.getRegExp highlight
            # $log.debug 'Highligting strings matching',  highlight
            searchText = searchText.replace highlight, "<span class='highlighted'>$1</span>"

        if colorized
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

    restrict: 'A'
    replace: yes
    link: ($scope, $element, $attrs) ->
        $timeout () ->
            colorized = false
            colorized = yes if $attrs.colorize and $attrs.colorize != 'false'
            text = $attrs.colorizeText
            highlight = $attrs.highlight
            searchText = $attrs.searchText
            text = process text, searchText, highlight, colorized
            # $log.debug 'Text', text
            # $log.debug 'Full Text', searchText
            $element.html text
]