# Reload client for Chrome Apps & Extensions.
# The relaod client has a compatibility with livereload.
# WARNING: only supports reload command.

LIVERELOAD_HOST = 'localhost:'
LIVERELOAD_PORT = 35729
connection = new WebSocket 'ws://' + LIVERELOAD_HOST + LIVERELOAD_PORT + '/livereload'

connection.onerror = (error) ->
    console.log 'Reload connection got error ' + JSON.stringify error

connection.onmessage = (e) ->
    data = JSON.parse e.data
    chrome.runtime.reload() if data and data.command == 'reload'