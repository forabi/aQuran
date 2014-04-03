app.service 'AppCacheManager', ['$window', '$rootScope', '$log', ($window, $rootScope, $log) ->
    $window.applicationCache.onchecking = (e) ->
        $log.info 'AppCache Checking...', e
        # Checking for updates
    $window.applicationCache.onupdateready = (e) ->
        $log.info 'AppCache Update Ready', e
        # Update is ready
    $window.applicationCache.onobsolete = (e) ->
        $log.info 'AppCache Obsolete', e
        # Update is available
    $window.applicationCache.ondownloading = (e) ->
        $log.info 'AppCache Downloading...', e
        # Downloading...
    $window.applicationCache.onprogress = (e) ->
        $log.info 'AppCache in progress', e
        # Progress
    $window.applicationCache.onerror = (e) ->
        $log.error 'AppCache Error', e
        # Something wrong happened
    $window.applicationCache.oncached = (e) ->
        $log.info 'AppCache Cached', e
        # The latest version is now available offline
    $window.applicationCache
]