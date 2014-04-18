# _ = require 'lodash'
app.service 'Preferences', ['$localStorage', ($localStorage) ->
    defaults =

        first_time: yes

        theme: 'balanced'

        search:
            history: []
            max_history: 10
            online:
                enabled: no
                prompt: yes

        explanations:
            enabled: yes
            ids: ['ar.muyassar', 'en.ahmedali']

        nav:
            view:
                id: 'sura_id'

        reader:
            arabic_text: on
            standard_text: no
            diacritics: on
            view:
                type: 'page_id'
                current: 1
                total: 604
            colorized: yes
            aya_mode: 'uthmani'
            sura_name: 'sura_name_romanization'
            sura_name_transliteration: on

        audio:
            recitation:
                subfolder: 'Abdul_Basit_Murattal_64kbps'
                name: 'Abdul Basit Murattal'
                bitrate: '64kbps'
            auto_quality: yes
            enabled: yes

        connection:
            # bandwidth: 0.25 # MB/s
            bandwidth: Infinity
            # auto: no
            auto: yes

    # defaults
    $localStorage.$default defaults
]