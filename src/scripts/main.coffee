# angular = require 'angular'
app   =   angular.module 'quran', ['ngSanitize', 'ngStorage', 'ionic', 'ngAudioPlayer']

app.constant 'API', 'http://www.alfanous.org/jos2'
app.constant 'EveryAyah', 'http://www.everyayah.com/data'

app.run ['$rootScope', 'Preferences', '$window', ($rootScope, Preferences, $window) ->
    $rootScope.online = navigator.onLine
    $rootScope.options = Preferences
    $window.addEventListener 'online',  () ->
      $rootScope.online = yes
      $rootScope.$apply()
    $window.addEventListener 'offline', () ->
      $rootScope.online = no
      $rootScope.$apply()
  ]


app.config ['$stateProvider', '$urlRouterProvider', '$locationProvider', '$logProvider' , ($stateProvider, $urlRouterProvider, $locationProvider, $logProvider) ->
    
    # $logProvider.debugEnabled no

    $stateProvider
    .state 'reader', 
      url: '/reader/:current?highlight'
      templateUrl: 'views/reader.html'
      controller: 'ReadingController'

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

    .state 'explanations', 
      url: '/explanations'
      templateUrl: 'views/explanations.html'
      controller: 'ExplanationsController'

    .state 'recitations', 
      url: '/recitations'
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