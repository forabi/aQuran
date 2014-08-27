module.exports = [
  {
    name: 'aQuran'
    versions: [
      {
        version: 16
        tables: [
          {
            table_name: 'ayas'
            filename: 'quran.json'
            schema: 'gid, page_id, [aya_id+page_id], sura_id,
            juz_id, standard, standard_full, *words'
            hooks: {
                creating: (primKey, obj, transaction) ->
                    obj.words = obj.standard.split ' '
                    return undefined
            }
          }
          {
            table_name: 'synonyms'
            filename: 'synonyms.json'
            schema: '++id, word, *synonyms'
          }
        ]
      }
    ]
  }
]