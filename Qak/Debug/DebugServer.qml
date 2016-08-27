import QtWebSockets 1.0

WebSocketServer {
    id: server

    name: 'QakDebugServer'

    listen: true
    port: 40402

    property var clients: ({})

    property int clientId: 0

    signal connectionError(string errorString)

    signal messageReceived(string message)


    onClientConnected: {
        clients['qdbs-'+clientId] = webSocket
        console.debug('Client',clientId,'connected')

        webSocket.onTextMessageReceived.connect(function(message) {
            for(var id in clients) {
                if(clients[id] === webSocket) {
                    console.info('Message from',id,message)
                    webSocket.sendTextMessage(id)
                    messageReceived(message)
                }
            }
        });

        webSocket.onStatusChanged.connect(function(status) {
            for(var id in clients) {
                if(clients[id] === webSocket) {
                    if (status === WebSocket.Error) {
                        console.error('Qak.Debug.DebugServer','websocket to client',id,'error',webSocket.errorString)
                    } else if (status === WebSocket.Closed) {
                        console.info('Qak.Debug.DebugServer','websocket to client',id,'closed connection')
                        clients[id] = undefined
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

        clientId++
    }

    onErrorStringChanged: {
        connectionError(server.errorString)
    }

}

