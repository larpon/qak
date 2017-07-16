import QtQuick 2.0

import Qak 1.0

Item {
    id: item

    readonly property real halfWidth: width*0.5
    readonly property real halfHeight: height*0.5

    // TODO optimize search for the few items that actually use this property and then remove this - a lot of these are spawned
    //readonly property real aspectRatio: width/height

    property bool paused: Qak.paused
//    onPausedChanged: Qak.log(paused ? 'paused' : 'continued') //¤qakdbg

//    DebugVisual { } //¤qakdbg
}
