
'use strict';

var Quran = angular.module('quran', []);

Quran.controller('OfflineController', function($http, $log, $scope, $rootScope) {

    $scope.progress = {
        status: 'init',
        current: 0,
        total: 0
    };

    var error = function(data) {
        $scope.progress.status = 'error';
        $log.error('Content not loaded:', data);
    };

    var success = function(server) {
        $rootScope.server = server;
        $rootScope.$broadcast('serverReady', server);

        server.info.query().filter('id', 'saved').execute().done(function(result) {

            // if (result.length && result[0].va8lue) {
            if (false) {

                // Database ready
                $log.debug('Database found. No need to fetch again.');
                $rootScope.$broadcast('databaseReady');

            } else {

                // Database not available, let's create it
                $scope.progress.status = 'fetching';

                $http.get('resources/ayas.json').then(function(response) {

                    $log.debug('Response:', response);
                    $rootScope.$broadcast('jsonFetched', response.data);

                    var ayas = response.data;

                    $scope.progress.status = 'saving';
                    $scope.progress.total = ayas.length;

                    var insert = function() {

                        var store = function(aya, callback) {
                            server.ayas.add(aya).done(function(aya) {
                                $scope.progress.current++;
                                $scope.$apply();
                                callback();
                            }).fail(callback);
                        };

                        async.eachSeries(ayas, store, function(err) {
                            if (err) return error(err);
                            server.info.add({ id: 'saved', value: true }).done(function() {
                                $log.info('All ayas are now stored in an IndexedDB database.');
                                $scope.progress.status = 'ready';
                                $scope.$apply();
                                $rootScope.$broadcast('databaseReady');
                            });
                        });

                    };

                    // server.ayas.clear().done(insert).fail(insert);

                }, error);
            }
        });
    };

    db.open({
        server: 'quran',
        version: 2,
        schema: {
            info: { 
                key: { keyPath: 'id' }
            },
            ayas: {
                key: { keyPath: 'gid' },
                indexes: {
                    aya_id: { },
                    sura_id: { },
                    page_id: { name: 'index_page_id' }
                }
            }
        }
    }).done(success).fail(error);
    
});

Quran.controller('ContentController', function($scope, $log, $rootScope) {
    $scope.content = {
        page_id: 0
    };

    $scope.progress = {
        status: 'init'
    };

    $scope.$on('serverReady', function(e, server) {

        var use = 'json';

        $scope.modes = [{
            id: 'standard',
            name: 'Simplified'
        }, {
            id: 'standard_full',
            name: 'Full'
        }, {
            id: 'uthmani',
            name: 'Uthmani'
        }, {
            id: 'uthmani_min',
            name: 'Uthmani (minimum)'
        }];

        $scope.mode = $scope.modes[0].id;

        var transform = function(ayas) {
            var suras = _.chain(ayas).groupBy('sura_name').map(function(sura_ayas, key) {
                return {
                    ayas: sura_ayas,
                    sura_name: key
                };
            }).value();

            return { suras: suras, page_id: $scope.content.page_id };
        };

        $scope.$watch('content.page_id', function(id) {
            $scope.progress.status = 'loading';
            if (use !== 'database') {
                $scope.progress.status = 'ready';
                $scope.content = transform(_.chain($scope.json).where({ page_id: id }).sortBy('gid').value());
                $log.debug('Got temporary page %s from JSON:', id, $scope.content);
            } else {
                server.ayas.query('index_page_id').filter('page_id', id).execute().done(function(ayas) {
                    $scope.progress.status = 'ready';
                    $scope.content = transform(ayas);
                    $scope.$apply();
                    $log.debug('Got page %s from IndexedDB:', id, $scope.content);
                }).fail(function(err) {
                    $scope.progress.status = 'error';
                    $scope.error = err;
                    $scope.$apply();
                    $log.debug('Error loading page %s:', id, err);
                });
            }
        });

        $scope.$on('jsonFetched', function(e, json) {
            $scope.json = json;
            if (!$scope.page.page_id) {
                $scope.content = {
                    page_id: 1
                };
                $scope.$apply();
            }
        });

        $scope.$on('databaseReady', function(e) {
            use = 'database';
            if (!$scope.content.page_id) {
                $scope.content = {
                    page_id: 1
                };
                $scope.$apply();
            }
        });
    });
});