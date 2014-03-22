# angular = require 'angular/'
app   =   angular.module 'quran', ['ngSanitize', 'ngStorage', 'ionic', 'audioPlayer']

app.constant 'API', 'http://www.alfanous.org/jos2'
app.constant 'EveryAyah', 'http://www.everyayah.com/data/'

app.run ['$rootScope', ($rootScope) ->
    $rootScope.online = navigator.onLine
    window.addEventListener 'online',  () -> 
      $rootScope.online = yes
      $rootScope.$apply()
    window.addEventListener 'offline', () -> 
      $rootScope.online = no
      $rootScope.$apply()
  ]


app.config ['$stateProvider', '$urlRouterProvider', '$locationProvider' , ($stateProvider, $urlRouterProvider, $locationProvider) ->
    
    $stateProvider
    .state 'reader', 
      url: '/reader/:current?highlight'
      templateUrl: 'views/reader.html'
      controller: 'ReadingController'

    .state 'aya', 
      url: '/:gid?highlight'
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
    

    $urlRouterProvider.otherwise '/reader/1'
    # $locationProvider.html5Mode on
]

# (require './services/arabic-service') Quran
# (require './services/content-service') Quran
# (require './services/search-service') Quran
# (require './directives/colorized-directive') Quran
# (require './controllers/reading-controller') Quran