app.controller 'PreferencesController', ['$scope', '$log', 'ExplanationService', ($scope, $log, ExplanationService) ->
    # $log.debug 'Here we go'
    $scope.sura_names = [
        (value: 'sura_name', name: 'Arabic', example: 'الفاتحة')
        (value: 'sura_name_en', name: 'English', example: 'The Opening')
        (value: 'sura_name_romanization', name: 'Romanized', example: 'Al-Fatiha')
    ]

    $scope.themes = [
        (id: 'light', name: 'Light')
        (id: 'stable', name: 'Stable')
        (id: 'positive', name: 'Positive')
        (id: 'calm', name: 'Calm')
        (id: 'balanced', name: 'Balanced')
        (id: 'energized', name: 'Energized')
        (id: 'assertive', name: 'Assertive')
        (id: 'royal', name: 'Royal')
        (id: 'dark', name: 'Dark')
    ]
]