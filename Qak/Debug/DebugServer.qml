import QtWebSockets 1.0

import Qak.Tools 1.0

WebSocketServer {
    id: server

    name: 'QakDebugServer'

    listen: true
    port: 40402

    property var clients: ({})
    property int clientId: 0

    property var watches: ({})

    signal connectionError(string errorString)

    signal request(var client, var request)
    signal log(string type, var message)

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

    function getClientId(ws) {
        for(var id in clients) {
            var client = clients[id]
            if('socket' in client && client.socket === ws)
                return id
        }
        return
    }

    function getClient(cid) {
        return clients[cid]
    }

    function handleRequest(cid, message) {

        var client = getClient(cid)
        if(client) {
            if(isJSON(message)) {
                message = JSON.parse(message)

                if('r' in message && message.r === 'auth') {
                    var rId = { auth: cid }
                    client.socket.sendTextMessage(JSON.stringify(rId))
                    return
                }

                if('auth' in message) {
                    if('log' in message && 'type' in message) {
                        if(message.type === 'log')
                            console.log(message.log)
                        if(message.type === 'info')
                            console.info(message.log)
                        if(message.type === 'error')
                            console.error(message.log)
                        if(message.type === 'warn')
                            console.warn(message.log)
                        if(message.type === 'debug')
                            console.debug(message.log)
                        log(message.type, message.log)
                    }

                    if('watch' in message && 'tag' in message) {
                        console.log('Adding watch',message.tag)
                        var t = watches
                        if(!Aid.isArray(t[cid]))
                            t[cid] = []
                        t[cid].push({
                            tag: message.tag,
                            cid: cid,
                            properties: message.properties,
                            functions: message.functions,
                            data: message.data
                        })
                        watches = t
                    }

                    request(client,message)
                } else {
                    console.error('Client',cid,'with message',message,'is not authorized')
                }

            } else
                console.info('Raw message from',cid,message)
        } else
            console.error('Unknown client',cid,message)
    }

    function isJSON(str) {
        try {
            JSON.parse(str)
        } catch (e) {
            return false
        }
        return true
    }

    onClientConnected: {
        clientId++
        clients['qdbs-'+clientId] = { id: 'qdbs-'+clientId, socket: webSocket }

//        console.debug('Qak.Debug.DebugServer','client',clientId,'connected') //¤qakdbg

        webSocket.onTextMessageReceived.connect(function(message) {
            var id = getClientId(webSocket)
            if(id)
                handleRequest(id,message)
            else
                console.error('Qak.Debug.DebugServer','can\'t handle client request from websocket',webSocket,'body',message)
        });

        webSocket.onStatusChanged.connect(function(status) {
            for(var id in clients) {
                if(clients[id] === webSocket) {
                    if (status === WebSocket.Error) {
                        console.error('Qak.Debug.DebugServer','websocket to client',id,'error',webSocket.errorString)
                    } else if (status === WebSocket.Closed) {
                        console.info('Qak.Debug.DebugServer','websocket to client',id,'closed connection')
                        clients[id] = undefined

                        var t = watches
                        t[id] = {}
                        watches = t
                    } else if (status === WebSocket.Closing) {
                        console.info('Qak.Debug.DebugServer','websocket to client',id,'closing connection')
                    } else if (status === WebSocket.Connecting) {
                        console.info('Qak.Debug.DebugServer','websocket to client',id,'is connecting')
                    } else if (status === WebSocket.Open) {
                        console.info('Qak.Debug.DebugServer','websocket to client',id,'connected')
                    } else
                        console.error('Qak.Debug.DebugServer','websocket to client',id,'unknown status',status)
                }
            }
        });


    }

    onErrorStringChanged: {
        connectionError(server.errorString)
    }

}

