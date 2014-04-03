app.directive 'scrollTo', ['$location', '$anchorScroll', '$timeout', ($location, $anchorScroll, $timeout) ->
    scroll = (id) ->
        if id
            $location.hash "#{id}"

    restrict: 'A',
    replace: no,
    link: ($scope, $element, $attrs) ->
        $attrs.$observe 'scrollTo', (id) ->
            $scope.$watch '$location.hash', (e) ->
                $timeout $anchorScroll
            scroll id
]