# angular = require 'angular/'
app   =   angular.module 'quran', ['ionic']

app.config ['$stateProvider', '$urlRouterProvider', ($stateProvider, $urlRouterProvider) ->
    
    $stateProvider
    .state 'reader', 
      url: '/reader/:current?highlight'
      templateUrl: 'views/reader.html'
      controller: 'ReadingController'
    
    .state 'search', 
      url: '/search'
      templateUrl: 'views/search.html'
      controller: 'SearchController'
    
    .state 'preferences', 
      url: '/preferences'
      templateUrl: 'views/preferences.html'
    

    $urlRouterProvider.otherwise '/reader/1'
]

# (require './services/arabic-service') Quran
# (require './services/content-service') Quran
# (require './services/search-service') Quran
# (require './directives/colorized-directive') Quran
# (require './controllers/reading-controller') Quran