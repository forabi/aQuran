# module.exports = (app) ->
app.directive 'page', ['Preferences', 'ColorizeFactory', '$timeout', '$log', (Preferences, ColorizeFactory, $timeout, $log) ->
    process = (page) ->
        renderAya = (aya) ->
            # $log.debug aya
            "<span class='aya' id='#{aya.gid}'>
                <span class='aya-text'>#{ColorizeFactory aya.text}</span>
                <i class='aya-number'>#{aya.aya_id_display}</i>
            </span>
            "

        html = ''
        if page[0].aya_id is 1
            html = "<h2 class='sura-name item item-divider'>
                        <b>#{page[0].sura_name}</b>
                    </h2>"
        html = html + (renderAya aya for aya in page).join('')

    restrict: 'A'
    replace: no
    link: ($scope, $element, $attrs) ->
        $timeout ->
            page = $attrs.page
            html = process $scope.pages[page]
            $element.html html
]