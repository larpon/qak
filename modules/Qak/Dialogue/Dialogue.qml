import QtQuick 2.5

import Qak 1.0

Node {
    id: node

    property bool running: false

    property alias current: scheduler.current
    property string said: ""

    onRunningChanged: {
        if(running) {
            sequential(node,function(item){
                Qak.db('Sequence at',item.text)
            })
        }
    }

    // Sequential
    function sequential(item,f) {
        scheduler.callback = f
        scheduler.root = item
    }

    Timer {
        id: scheduler

        triggeredOnStart: true
        interval: 2500
        repeat: true

        property Item root
        property Item current
        property int cIndex: 0
        property var callback

        function reset() {
            stop()
            cIndex = 0
        }

        onRootChanged: {
            reset()
            // TODO error checking
            current = root.children[cIndex]
            restart()
        }

        onTriggered: {
            callback(current,scheduler)

            cIndex++
            if(root.children[cIndex])
                current = root.children[cIndex]
            else
                stop()
        }
    }


}
