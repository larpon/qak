import QtQuick 2.0

import Qak 1.0

Rectangle {
    id: item

    property real halfWidth: width*0.5
    property real halfHeight: height*0.5

    property bool paused: Qak.paused

//    DebugVisual { } //¤qakdbg
}
