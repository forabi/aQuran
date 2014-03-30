app.service 'AppCacheManager', ['$window', '$rootScope', ($window, $rootScope) ->
    $window.applicationCache.onchecking = () ->
        # Checking for updates
    $window.applicationCache.onupdateready = () ->
        # Update is ready
    $window.applicationCache.onobsolete = () ->
        # Update is available
    $window.applicationCache.ondownloading = () ->
        # Downloading...
    $window.applicationCache.onprogress = () ->
        # Progress
    $window.applicationCache.onerror = () ->
        # Something wrong happened
    $window.applicationCache.oncached = () ->
        # The latest version is now available offline
    $window.applicationCache
]