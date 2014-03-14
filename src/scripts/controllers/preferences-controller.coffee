app.controller 'PreferencesController', ['$scope', 'Preferences', '$log', 'ExplanationService', ($scope, Preferences, $log, ExplanationService) ->
    # $log.debug 'Here we go'
    $scope.options = Preferences
    $scope.sura_names =
    	sura_name: (name: 'Arabic', example: 'الفاتحة')
    	sura_name_en: (name: 'English', example: 'The Opening')
    	sura_name_romanized: (name: 'Romanized', example: 'Al-Fateha')
]