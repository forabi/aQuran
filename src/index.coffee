Vue = require 'vue'
{ Router } = require 'director'

# Register view-models as reusable components
Vue.component 'search-view', require './view-models/search.coffee'
Vue.component 'preferences-view', require './view-models/preferences.coffee'

app = new Vue {
    el: '#app'
    data: currentView: 'search-view'
}

Vue.filter 'ayaNumber', (value) ->
    '\u06DD' + value

# Register routes
new Router({
    '/preferences': ->
        app.currentView = 'preferences-view'
    '/search': ->
        app.currentView = 'search-view'
}).init()