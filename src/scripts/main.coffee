# angular = require 'angular'
app = angular.module 'quran', ['ngSanitize', 'ngStorage', 'ionic', 'mediaPlayer']

app.constant 'API', 'http://www.alfanous.org/jos2'
app.constant 'EVERY_AYAH', 'http://www.everyayah.com/data'
# app.constant 'RESOURCES', 'https://forabi.github.io/aQuran/resources'
app.constant 'RESOURCES', 'resources'

app.run ['$rootScope', 'AppCacheManager', 'Preferences', 'MessageService', '$window', ($rootScope, AppCacheManager, Preferences, MessageService, $window) ->
    $rootScope.online = $window.navigator.onLine
    $rootScope.options = Preferences
    $rootScope.messages = MessageService.store

    $window.addEventListener 'online',  ->
        $rootScope.online = yes
        $rootScope.$apply()

    $window.addEventListener 'offline', ->
        $rootScope.online = no
        $rootScope.$apply()
]

app.config ['$stateProvider', '$urlRouterProvider', '$locationProvider', '$logProvider' , ($stateProvider, $urlRouterProvider, $locationProvider, $logProvider) ->

    $logProvider.debugEnabled no

    $stateProvider
    .state 'reader',
      url: '/reader/:current?highlight&scrollTo'
      templateUrl: 'views/reader.html'
      # controller: 'ReadingController'

    .state 'aya',
      url: '/aya/:gid?highlight'
      templateUrl: 'views/aya.html'
      controller: 'AyaController'

    .state 'navigate',
      url: '/navigate'
      templateUrl: 'views/navigation.html'
      controller: 'NavigationController'

    .state 'search',
      url: '/search?query'
      templateUrl: 'views/search.html'
      controller: 'SearchController'

    .state 'preferences',
      url: '/preferences'
      templateUrl: 'views/preferences.html'
      controller: 'PreferencesController'

    .state 'themes',
      url: '/preferences/themes'
      templateUrl: 'views/themes.html'
      controller: 'PreferencesController'

    .state 'sura-name',
      url: '/preferences/sura_name'
      templateUrl: 'views/sura_name.html'
      controller: 'PreferencesController'

    .state 'explanations',
      url: '/preferences/explanations'
      templateUrl: 'views/explanations.html'
      controller: 'ExplanationsController'

    .state 'recitations',
      url: '/preferences/recitations'
      templateUrl: 'views/recitations.html'
      controller: 'RecitationsController'

    .state 'about',
      url: '/about'
      templateUrl: 'views/about.html'
      controller: ['$http', '$scope', ($http, $scope) ->
        $http.get 'manifest.webapp', headers: 'application/json', cache: yes
        .then (response) ->
          # $scope.info = _.merge response.data, response.data.locales.ar
          $scope.info = response.data
      ]

    $urlRouterProvider.otherwise '/reader/1'
    # $locationProvider.html5Mode on
]