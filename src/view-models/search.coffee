Dexie = require 'Dexie'
Vue = require 'vue'
throttle = require 'lodash.throttle'
db = require '../db'

db.open()

searchFn = (e) ->
    e.preventDefault()

    try Dexie.currentTransaction.abort()
    
    term = @searchTerm
    first = term.split(' ')[0]
    
    for table in @tables
        # db.transaction 'r!', [table.name], =>
        db[table.name]
        .where 'words'
        .startsWith first
        .and (aya) -> aya.standard.indexOf(term) isnt -1
        .distinct().limit 5
        .toArray (results) => @results[table.name] = results.map table.transform
        .catch (e) -> console.log e # @TODO: Handle error

module.exports = Vue.extend {
    template: '#search-view'
    data:
        tables: [
            {
                name: 'ayas'
                transform: (aya) ->
                    aya.text = aya.uthmani
                    aya
            }
        ]
        results: { ayas: [] }
    methods:
        search: throttle searchFn, 1000
}