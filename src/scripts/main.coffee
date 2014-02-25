angular = require 'angular'
Quran   =   angular.module 'quran', []
(require './services/content-service') Quran
(require './services/search-service') Quran
(require './controllers/content-controller') Quran