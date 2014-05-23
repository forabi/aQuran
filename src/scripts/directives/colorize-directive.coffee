# module.exports = (app) ->
app.directive 'colorize', ['ArabicService', 'ColorizeFactory', '$timeout', '$log', (Arabic, ColorizeFactory, $timeout, $log) ->
    restrict: 'A'
    replace: yes
    link: ($scope, $element, $attrs) ->
        $timeout ->
            colorized = false
            colorized = yes if $attrs.colorize and $attrs.colorize != 'false'
            text = $attrs.colorizeText
            highlight = $attrs.highlight
            searchText = $attrs.searchText
            text = ColorizeFactory text, searchText, highlight, colorized
            # $log.debug 'Text', text
            # $log.debug 'Full Text', searchText
            $element.removeAttr 'colorize'
            $element.removeAttr 'colorize-text'
            $element.removeAttr 'search-text'
            $element.html text
]