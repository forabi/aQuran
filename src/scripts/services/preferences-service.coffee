# _ = require 'lodash'
app.service ['StorageService', (Storage) ->
	_defaults =
		search:
			online:
				enabled: false
		reader:
			view:
				type: 'page'
				current: 1
				colorized: true
				aya_mode: 'standard_full'
				sura_name: 'sura_name'
				

	get: (section) -> Storage.get section
	set: (section) -> Storage.set section
]