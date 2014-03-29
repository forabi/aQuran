app.filter 'ArabicNumber', ['ArabicService', (Arabic) ->
    (text) ->
        Arabic.Numbers.Array.forEach (num, i) ->
            text = text.replace (new RegExp i.toString, 'g'), i.toLocaleString()
        text
]