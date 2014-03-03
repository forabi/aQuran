app.service 'NavigationService', [() ->
	go: (query) ->
		aya_id: query.match(/(?!aya\s*(\d+))|\d+\W(\d+)/gi)[1],
		page_id: query.match(/page\s*(\d+)/gi)[1]
		sura_id: query.match(/(?!surah*\s*(\d+))|(d+)\W\d+/gi)[1]
		sura_name: query.match(/surah*\s*(\D+)/gi)[1]
]