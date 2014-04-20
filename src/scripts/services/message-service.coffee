app.service 'MessageService', ['$timeout', '$log', ($timeout, $log) ->
    @store = []
    @add = (msg, dismissable = yes) ->
        msg = _.defaults msg,
            type: 'info', dismissed = no, timeout: 5000
        
        msg.id = _.uniqueId()

        if dismissable then msg.dismiss = () ->
            msg.dismissed = yes
            # $log.debug "Message #{msg.id} dismissed."
        
        msg.reset = () ->
            msg.dismissed = no
            try 
                msg._timeout.cancel()
            msg._timeout = $timeout msg.dismiss, msg.timeout

        @store.unshift msg
        # $log.debug "Message #{msg.id} added", msg, @store
        msg.id
    @update = (id, update) ->
        update.dismissed = no
        for i, msg of @store
            if msg.id is id then @store[i] = _.extend msg, update
            msg.reset()
            # $log.debug "Message #{id} updated", @store[i], @store
            return msg.id
    @remove = (id) ->
        _.pull @store, id: id
        # $log.debug "Message #{id} removed", @store
        id
    @
]