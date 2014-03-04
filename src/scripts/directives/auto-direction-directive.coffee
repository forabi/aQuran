app.directive 'autoDirection', ['LocalizationService', (LocalizationService) ->
    restrict: 'ACE'
    link: ($scope, $element, $attrs) ->
        $attrs.$observe 'autoDirection', (text) ->
            text = $element.text() if !text
            $element.attr 'dir', if LocalizationService.isRTL text then 'rtl' else 'ltr'
]