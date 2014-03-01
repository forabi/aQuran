app.directive 'autoDirection', ['LocalizationService', (LocalizationService) ->
    restrict: 'ACE'
    link: ($scope, $element, $attrs) ->
        $attrs.$observe 'autoDirection', (text) ->
            $element.attr 'dir', if LocalizationService.isRTL text then 'rtl' else 'ltr'
]