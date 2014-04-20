app.service 'AppCacheManager', ['MessageService', '$window', '$rootScope', '$log', (MessageService, $window, $rootScope, $log) ->
    id = undefined
    $window.applicationCache.onchecking = (e) ->
        id = MessageService.add text: 'Checking for updates...'
    $window.applicationCache.onupdateready = (e) ->
        MessageService.update id,
            text: 'Update is ready, changes will take effect after reload'
            icon: 'ion-refresh'
            action: () -> location.reload()
    # $window.applicationCache.onobsolete = (e) ->
    #     MessageService. 'AppCache Obsolete', e
    #     # Update is available
    $window.applicationCache.ondownloading = (e) ->
        # $log.info 'AppCache Downloading...', e
        MessageService.update id, text: 'Downloading updates...'
    $window.applicationCache.onprogress = (e) ->
        percent = ''
        percent = " (#{(100 * e.loaded / e.total).toFixed 0}%)" if e.lengthComputable
        MessageService.update id, text: "Downloading updates#{percent}..."
    $window.applicationCache.onerror = (e) ->
        MessageService.update id, text: 'Error updating the application', type: 'error'
    $window.applicationCache.oncached = (e) ->
        MessageService.update id, text: 'This application is now avialable offline'
    $window.applicationCache.onnoupdate = (e) ->
        MessageService.update id, text: 'No updates found'
    $window.applicationCache
]