# _ = require 'lodash'
app.service 'Preferences', [() ->
    defaults =
        search:
            online:
                enabled: no
                prompt: yes
        reader:
            view:
                type: 'page'
                current: 1
                colorized: yes
                aya_mode: 'uthmani'
                sura_name: 'sura_name'
        audio:
            recitation: 'Hudaify'
            quality: 32
            enabled: yes
            

    # get: (section) -> Storage.get section
    # set: (section) -> Storage.set section
    defaults
]