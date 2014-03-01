# module.exports = (app) ->
    app.directive 'highlight', ['ArabicService', '$timeout', '$log', (Arabic, $timeout, $log) -> 
        restrict: 'AEC'
        replace: yes
        link: ($scope, $element, $attrs) ->
            colorize = (text) ->
                text.split(/\s+/g).map (word, index) ->
                    word_diacritics = word.replace Arabic.Quranic.Signs.RegExp, ''
                    word_signs      = word.replace Arabic.Diacritics.RegExp, ''
                    word_standard   = word.replace Arabic.Quranic.Signs.RegExp, ''
                                          .replace Arabic.Diacritics.RegExp, ''
                    "<span class='layers'>
                        <span class='original'>#{word}</span>
                        <span class='diacritics'>#{word_diacritics}</span>
                        <span class='quranic-signs'>#{word_signs}</span>
                       <span class='letters'>#{word_standard}</span>
                     </span>"
                .join(' ')


            $timeout () -> 
                # console.log $element, $attrs
                # text = $element.text()
                text = $attrs['colorize']
                # $log.debug 'Text', text
                # $log.debug 'Colorized HTML', colorize text
                $element.html colorize text
                # $element.css('color', 'red')
    ]