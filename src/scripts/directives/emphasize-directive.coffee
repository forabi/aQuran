# module.exports = (app) ->
app.directive 'emphasize', ['$timeout', ($timeout) ->
    restrict: 'A'
    replace: yes
    link: ($scope, $element, $attrs) ->
        emphasize = (text, term) ->
            regexp = new RegExp "(#{term})", 'gi'
            console.log text.replace regexp, '<em>$1</em>'
            text.replace regexp, '<em>$1</em>'

        $timeout ->
            term = $attrs['emphasize']
            $element.html emphasize $element.text(), term
]