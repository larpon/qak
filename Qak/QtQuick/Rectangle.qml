import QtQuick 2.0

import Qak 1.0

Rectangle {
    id: item

    readonly property real halfWidth: width/2
    readonly property real halfHeight: height/2

    readonly property real aspectRatio: width/height

    property bool pause: Qak.pause

    property bool debug: Qak.debug

    // Debug visuals
    DebugVisual { }
}
