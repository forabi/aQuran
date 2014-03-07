app.service 'ExplanationService', ['$q', '$http', '$log', ($q, $http, $log) ->
    ###
    TODO: fix this so we won't have to load the file every time
    we fetch a translation because this way performance will suffer

    Maybe a Nedb per translation is a good idea, but we will have
    to load all translations ahead of time as this service is independent
    of the Preferences service and the selected translations may change
    during runtime
    ###
    getExplanation: (id) ->
    	$q.all [
    		($http.get "resources/#{id}.trans/#{id}.txt", cache: yes)
    		($http.get "resources/#{id}.trans/translation.properties", cache: yes)
    	]
    	.then (results) ->
            $log.debug 'Translation response:', results
            p = results[1].data

            localizedName = p.match(/localizedName=(.+)/)[1]
            name = p.match(/name=(.+)/)[0]
            copyright = p.match(/copyright=(.+)/)[0]

            properties:
            	name: name
            	localizedName: localizedName
            	copyright: copyright
            content:
                results[0].data.split /\n/g
]