app.service 'MessageService', ['$timeout', '$log', ($timeout, $log) ->
    class Message
        _timeout = undefined
        constructor: (msg, @dismissable = yes) ->
            msg = _.defaults msg,
                type: 'info', dismissed = no, timeout: 5000
            for value, key in msg
                @[key] = value
            @id = _.uniqueId()


        dismiss: ->
            @dismissed = yes

        if not @dismissable then delete @dismiss

        reset: ->
            @dismissed = no
            try
                _timeout.cancel()
            _timeout = $timeout @.dismiss, @.timeout


    @store = []
    @add = (msg, dismissable) ->
        msg = new Message msg, dismissable
        @store.unshift msg
        # $log.debug "Message #{msg.id} added", msg, @store
        msg.id
    @update = (id, update) ->
        update.dismissed = no
        i = _.findIndex @store, id: id
        msg = @store[i]
        @store[i] = _.extend msg, update
        msg.reset()
        # $log.debug "Message #{id} updated", @store[i], @store
        msg.id
    @remove = (id) ->
        _.pull @store, id: id
        # $log.debug "Message #{id} removed", @store
        id
    @
]