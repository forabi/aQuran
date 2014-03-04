# _ = require 'lodash'
app.service 'Preferences', [() ->
    defaults =
        search:
            history: ['قرآن', 'سبحانك']
            online:
                enabled: no
                prompt: yes
        
        explanations:
            enabled: yes
            ids: ['ar.muyassar', 'en.ahmedali']

        reader:
            arabic_text: on
            standard_text: no
            diacritics: on
            type: 'page'
            current: 1
            colorized: yes
            aya_mode: 'uthmani'
            sura_name: 'sura_name'
            sura_name_transliteration: on
        
        audio:
            id: 'Abdullah_Basfar_32kbps'
            recitor: 'عبد الباسط عبد الصمد'
            tags: ['مرتَّل']
            auto_quality: yes
            enabled: yes


    # get: (section) -> Storage.get section
    # set: (section) -> Storage.set section
    defaults
]