# module.exports = (app) ->
app.directive 'page', ['Preferences', 'ColorizeFactory', '$timeout', '$log', (Preferences, ColorizeFactory, $timeout, $log) ->
    process = (page) ->
        renderExplanations = (aya) ->
            if aya.explanations and aya.explanations.length > 0
                (for explanation in aya.explanations
                    "<div class='explanation-text' dir='#{explanation.dir || 'ltr'}'>" +
                        (if not Preferences.reader.arabic_text or explanation.language isnt 'ar'
                            "<i class='aya-number explanation-aya-number'
                                dir>
                                #{aya.aya_id}
                            </i>"
                        else '') + "
                        #{explanation.text}
                     </div>"
                ).join('')
            else ''

        renderAya = (aya) ->
            # $log.debug aya
            itemClass = if aya.explanations and aya.explanations.length
                    'item item-text-wrap'
                else ''

            "<span class='aya #{itemClass}' id='#{aya.gid}'>" + (
                if Preferences.reader.arabic_text then "
                    <span class='aya-text'>#{ColorizeFactory aya.text}</span>
                    <i class='aya-number'>#{aya.aya_id_display}</i>" else ''
                ) + renderExplanations(aya) +
            "</span>"

        html = ''
        if page[0].aya_id is 1
            html = "<h2 class='sura-name item item-divider'>
                        <b>#{page[0].sura_name}</b>
                    </h2>"
        html = html + (renderAya aya for aya in page).join('')

    restrict: 'A'
    replace: yes
    link: ($scope, $element, $attrs) ->
        $timeout ->
            page = $attrs.page
            html = process $scope.pages[page]
            $element.html html
            arabicClass = ''
            if !Preferences.explanations.ids.length or !Preferences.explanations.enabled
                    arabicClass = 'arabic-only'
            $element.addClass arabicClass
]