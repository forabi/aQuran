app.controller 'PreferencesController', ['$scope', '$log', 'ExplanationService', ($scope, $log, ExplanationService) ->
    # $log.debug 'Here we go'
    $scope.sura_names =
    	sura_name: (name: 'Arabic', example: 'الفاتحة')
    	sura_name_en: (name: 'English', example: 'The Opening')
    	sura_name_romanized: (name: 'Romanized', example: 'Al-Fateha')
]