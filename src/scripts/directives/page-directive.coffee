# module.exports = (app) ->
app.directive 'page', ['Preferences', '$log', (Prefernces, $log) ->
    process = (page) ->
        renderAya = (aya) -> "
            <span class='aya-text'>#{aya.text}</span>
            <i class='aya-number'>#{aya.aya_id_display}</i>
        "

        html = (html + renderAya for aya in page)

    restrict: 'A'
    replace: yes
    compile: ($scope, $element, $attrs) ->
        $attrs.observe 'page', (page) ->
            $element.html process page
]