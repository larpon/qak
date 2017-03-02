import QtQuick 2.0

import Qak 1.0

Node {
    id: node

    property bool running: false

    property alias current: scheduler.current
    property string text: scheduler.text

//    onRunningChanged: { //¤qakdbg
//        if(running) { //¤qakdbg
//            sequential(node,function(item,text){ //¤qakdbg
//                Qak.debug('Item',item,'says',text) //¤qakdbg
//            }) //¤qakdbg
//        } //¤qakdbg
//    } //¤qakdbg

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

        property string text
        property int cIndex: 0
        property var callback

        property var cText: []
        property int cTextIndex: 0

        function isArray(test) {
            return ( Object.prototype.toString.call( test ) === '[object Array]' )
        }

        function reset() {
            stop()
            text = ""
            cText = null
            cIndex = 0
            cTextIndex = 0
        }

        onRootChanged: {
            reset()
            // TODO error checking
            //current = root.children[cIndex]

            restart()
        }

        onTriggered: {

            if(root.children[cIndex]) {
                current = root.children[cIndex]
                cText = current.text

                var isArr = isArray(cText)
                var doNextItem = false

                if(isArr)
                    text = cText[cTextIndex]
                else {
                    doNextItem = true
                    text = cText
                }

                callback(current,text,scheduler)

                // TODO if is Ask type
                //if(isAskType)
                //  stop()

                cTextIndex++

                if(isArr && !cText[cTextIndex])
                    doNextItem = true

                if(doNextItem)
                    cIndex++

            } else
                stop()

        }
    }


}
