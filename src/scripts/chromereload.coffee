# Reload client for Chrome Apps & Extensions.
# The relaod client has a compatibility with livereload.
# WARNING: only supports reload command.

LIVERELOAD_HOST = 'localhost:'
LIVERELOAD_PORT = 35729
connection = new WebSocket 'ws://' + LIVERELOAD_HOST + LIVERELOAD_PORT + '/livereload'

connection.onerror = (error) ->
    console.error 'LiveReload connection error', error

connection.onmessage = (event) ->
    data = JSON.parse event.data if (event.data)
    chrome.runtime.reload() if data and data.command == 'reload'