# angular = require 'angular/'
app   =   angular.module 'quran', ['ionic', 'audioPlayer']

app.constant 'API', 'http://www.alfanous.org/jos2'
app.constant 'EveryAyah', 'http://www.everyayah.com/data'

app.run ['$rootScope', ($rootScope) ->
    $rootScope.online = navigator.onLine
    window.addEventListener 'online',  () -> $rootScope.online = yes
    window.addEventListener 'offline', () -> $rootScope.online = no
  ]


app.config ['$stateProvider', '$urlRouterProvider', '$locationProvider' , ($stateProvider, $urlRouterProvider, $locationProvider) ->
    
    $stateProvider
    .state 'reader', 
      url: '/reader/:current?highlight'
      templateUrl: 'views/reader.html'
      controller: 'ReadingController'
    
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
    

    $urlRouterProvider.otherwise '/reader/1'
    # $locationProvider.html5Mode(true);
]

# (require './services/arabic-service') Quran
# (require './services/content-service') Quran
# (require './services/search-service') Quran
# (require './directives/colorized-directive') Quran
# (require './controllers/reading-controller') Quran