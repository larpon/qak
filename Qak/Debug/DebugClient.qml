import QtWebSockets 1.0

WebSocket {
    id: socket

    url: 'ws://localhost:40402'

    property string auth

    signal connectionError(string message)
    signal connectionClosed
    signal connectionClosing
    signal connecting
    signal connected

    signal response(var response)

    property var watches: ({})

    function watch(object, prop, tag) {
        tag = tag || prop
        var uprop = prop.charAt(0).toUpperCase() + prop.slice(1)

        var w = function() {
            var request = { watch: true, tag: tag, value: object[prop] }
            send(request)
        }
        watches[object.toString()+tag] = w

        object['on'+uprop+'Changed'].connect(w)
    }

    /*
    function unwatch(object, prop, tag) {
        tag = tag || prop
        var uprop = prop.charAt(0).toUpperCase() + prop.slice(1)

        //object.toString()+tag
        var uprop = prop.charAt(0).toUpperCase() + prop.slice(1)
        object['on'+uprop+'Changed'].disconnect(function(){
            var request = { watch: false, tag: tag, value: object[prop] }
            send(request)
        })
    }
    */

    function extend(target, source) {
        target = target || {}
        for (var prop in source) {
            if (typeof source[prop] === 'object')
                target[prop] = extend(target[prop], source[prop])
            else
                target[prop] = source[prop]
        }
        return target
    }

    function send(message) {
        if(status != WebSocket.Open)
            return

        if (typeof message === 'string' || message instanceof String)
            sendTextMessage(message)
        else {
            if(auth)
                message = extend(message,{ auth: auth })
            sendTextMessage(JSON.stringify(message))
        }
    }

    function log(message) {
        var request = { type: 'log', log: message }
        send(request)
    }

    function info(message) {
        var request = { type: 'info', log: message }
        send(request)
    }

    function error(message) {
        var request = { type: 'error', log: message }
        send(request)
    }

    function warn(message) {
        var request = { type: 'warn', log: message }
        send(request)
    }

    function debug(message) {
        var request = { type: 'debug', log: message }
        send(request)
    }

    function handleResponse(message) {
        if(isJSON(message)) {
            console.info('Got response',message)
            message = JSON.parse(message)

            if('auth' in message) {
                socket.auth = message.auth
                return
            }
            response(message)
        } else
            console.info('String message from server',message)
    }

    function isJSON(str) {
        try {
            JSON.parse(str)
        } catch (e) {
            return false
        }
        return true
    }

    onTextMessageReceived: handleResponse(message)

    onStatusChanged: {
        if (status === WebSocket.Error) {
            connectionError(socket.errorString)
        } else if (status === WebSocket.Closed) {
            connectionClosed()
        } else if (status === WebSocket.Closing) {
            connectionClosing()
        } else if (status === WebSocket.Connecting) {
            connecting()
        } else if (status === WebSocket.Open) {
            connected()
        } else
            console.error('Qak.Debug.DebugClient','Unknown websocket status',status)
    }

    onConnected: {
        var authRequest = { r: 'auth' }
        send(authRequest)
    }

    onConnectionError: console.error('Connection error',url,errorString)

}
