Vue = require 'vue'
db = require '../db'

deleteDb = (e) ->
    db.delete()
    .then ->
        alert 'Database deleted.'
    .catch (error) ->
        alert 'Error deleting database!'
        console.log error

module.exports = Vue.extend {
    template: '#perferences-view'
    data: results: []
    methods: { deleteDb }
}