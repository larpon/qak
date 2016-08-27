import QtWebSockets 1.0

WebSocket {
    id: socket

    signal connectionError(string message)
    signal connectionClosed
    signal connectionClosing
    signal connecting
    signal connected

    signal messageReceived(string message)

    function sendMessage(message) {
        sendTextMessage(message)
    }

    onTextMessageReceived: messageReceived(message)

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
}
