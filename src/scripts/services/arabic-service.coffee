# module.exports = (app) ->
    app.service 'ArabicService', [() ->

        _arabic_alphapet = /[\u060c-\u06fe\ufb50-\ufefc]/g
        # _diacritics_str = '([\u064b-\u0652])'
        _diacritics_str = '([\u0618\u0619\u061A\u064B\u064C\u064D\u064E\u064F\u0650\u0651\u0652\u0657\u0658\u06E1\u08F0\u08F1\u08F2\u064B.small\u064E.small\u08F1.small\u064F.small\u08F0.small\u064C.small\u0657.small\u0650.small\u064D.small\u0652.small2\u0650.small2\u064E.small2\u0657.urd])'
        # _quranic_annotation_signs = /[\u0617-\u061a\u06d6-\u06ed]/g
        _quranic_annotation_signs = /[\u0615\u0617\u065C\u0670\u06D6\u06D7\u06D8\u06D9\u06DA\u06DB\u06DC\u06DD\u06DE\u06DF\u06E0\u06E2\u06E3\u06E4\u06E5\u06E6\u06E7\u06E8\u06E9\u06EA\u06EB\u06EC\u06ED\u0670.isol\u0670.medi\u06E5.medi\u06E6]/
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

        _replaces = [
            (id: 'alefHamzas', replace: /[أإآا]/g, with: '[أإآا]')
            # (id: 'wawHamza', replace: /[وؤ]/g, with: '[ؤو]')
            # (id: 'ya2Hamza', replace: /[ىئي]/g, with: '[ىئي]')
            # (id: 'alefMaqsura', replace: /[ىي]/g, with: '[ىي]')
            (id: 'alefMadda', replace: /آ|(?:ءا)/g, with: '(?:آ|(?:ءا))')
            # (id: 'diacritics', replace: /[\u064b-\u0652]/g, with: '[\u064b-\u0652]?')
        ]

        getRegExp: (text) ->
            _replaces.forEach (obj) ->
                text = text.replace obj.replace, obj.with
            new RegExp "(#{text})", 'g'
        Alphabet:
            RegExp: _arabic_alphapet
        Diacritics:
            RegExp: new RegExp _diacritics_str, 'g'
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



