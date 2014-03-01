# module.exports = (app) ->
    app.service 'ArabicService', [() ->
        _arabic_alphapet = /[\u060c-\u06fe\ufb50-\ufefc]/g
        _diacritics_str = '([\u064b-\u0652])'
        _quranic_annotation_signs = /[\u0617-\u061a\u06d6-\u06ed]/g
        _hamza_str = '([آإأءئؤاىو])'
        _numbers = [
            "\u0660"
            "\u0661"
            "\u0662"
            "\u0663"
            "\u0664"
            "\u0665"
            "\u0666"
            "\u0667"
            "\u0668"
            "\u0669"
        ]

        Alphabet:
            RegExp: _arabic_alphapet
        Diacritics:
            RegExp: /([\u064b-\u0652])/g
            String: _diacritics_str
        Hamzas:
            String: _hamza_str
            RegExp: new RegExp _hamza_str, 'g'
        Numbers:
            Array: _numbers
        Quranic:
            Sign:
                RegExp: _quranic_annotation_signs
            # Word:
            #     RegExp: /((\s?[\u0617-\u061a\u06d6-\u06ed])?[\u060c-\u06fe\ufb50-\ufefc](\s?[\u0617-\u061a\u06d6-\u06ed])?)+\s+/g

    ]

        # Points from ISO 8859-6
        #     064B  ARABIC FATHATAN
        #     064C  ARABIC DAMMATAN
        #     064D  ARABIC KASRATAN
        #     064E  ARABIC FATHA
        #     064F  ARABIC DAMMA
        #     0650  ARABIC KASRA
        #     0651  ARABIC SHADDA
        #     0652  ARABIC SUKUN

        # = [\u064b-\u0652]

        # Koranic annotation signs
        #     0617  ARABIC SMALL HIGH ZAIN
        #     0618  ARABIC SMALL FATHA
        #     • should not be confused with 064E   FATHA
        #     0619  ARABIC SMALL DAMMA
        #     • should not be confused with 064F   DAMMA
        #     061A  ARABIC SMALL KASRA
        #     • should not be confused with 0650   KASRA

        # = [\u0617-\u061a]

        # Koranic annotation signs
        #     06D6  ARABIC SMALL HIGH LIGATURE SAD WITH LAM
        #     WITH ALEF MAKSURA
        #     06D7  ARABIC SMALL HIGH LIGATURE QAF WITH LAM
        #     WITH ALEF MAKSURA
        #     06D8  ARABIC SMALL HIGH MEEM INITIAL FORM
        #     06D9  ARABIC SMALL HIGH LAM ALEF
        #     06DA  ARABIC SMALL HIGH JEEM
        #     06DB  ARABIC SMALL HIGH THREE DOTS
        #     06DC  ARABIC SMALL HIGH SEEN
        #     06DD  ARABIC END OF AYAH
        #     06DE  ARABIC START OF RUB EL HIZB
        #     06DF  ARABIC SMALL HIGH ROUNDED ZERO
        #     • smaller than the typical circular shape used for
        #     0652  
        #     06E0  ARABIC SMALL HIGH UPRIGHT RECTANGULAR
        #     ZERO
        #     06E1  ARABIC SMALL HIGH DOTLESS HEAD OF KHAH
        #     = Arabic jazm
        #     • presentation form of 0652  , using font
        #     technology to select the variant is preferred
        #     • used in some Korans to mark absence of a
        #     vowel
        #     → 0652   arabic sukun
        #     06E2  ARABIC SMALL HIGH MEEM ISOLATED FORM
        #     06E3  ARABIC SMALL LOW SEEN
        #     06E4  ARABIC SMALL HIGH MADDA
        #     06E5  ARABIC SMALL WAW
        #     06E6  ARABIC SMALL YEH
        #     06E7  ARABIC SMALL HIGH YEH
        #     06E8  ARABIC SMALL HIGH NOON
        #     06E9  ARABIC PLACE OF SAJDAH
        #     • there is a range of acceptable glyphs for this
        #     character
        #     06EA  ARABIC EMPTY CENTRE LOW STOP
        #     06EB  ARABIC EMPTY CENTRE HIGH STOP
        #     06EC  ARABIC ROUNDED HIGH STOP WITH FILLED
        #     CENTRE
        #     06ED  ARABIC SMALL LOW MEEM

        # = [\u06d6-\u06ed]

        # Point
        # 0670 
        # ARABIC LETTER SUPERSCRIPT ALEF
        # • actually a vowel sign, despite the name

        # Extended Arabic letters
        # 0671  ARABIC LETTER ALEF WASLA
        # • Koranic Arabic
        # 0672  ARABIC LETTER ALEF WITH WAVY HAMZA
        # ABOVE
        # • Baluchi, Kashmiri

        # Deprecated letter
        # 0673  ARABIC LETTER ALEF WITH WAVY HAMZA
        # BELOW
        # • Kashmiri
        # • this character is deprecated and its use is
        # strongly discouraged
        # • use the sequence 0627   065F   instead



