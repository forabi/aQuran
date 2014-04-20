app.controller 'PreferencesController', ['$scope', '$log', 'ExplanationService', ($scope, $log, ExplanationService) ->
    $scope.sura_names = [
        (value: 'sura_name', name: 'Arabic', example: 'الفاتحة')
        (value: 'sura_name_en', name: 'English', example: 'The Opening')
        (value: 'sura_name_romanization', name: 'Romanized', example: 'Al-Fatiha')
    ]

    $scope.$watch 'options.reader.arabic_text', (value) ->
        if not value then $scope.options.explanations.enabled = yes

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