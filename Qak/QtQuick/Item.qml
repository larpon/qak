import QtQuick 2.5

import Qak 1.0

Item {
    id: item

    readonly property real halfWidth: width/2
    readonly property real halfHeight: height/2

    readonly property real aspectRatio: width/height

    property bool pause: Qak.pause
    onPauseChanged: Qak.log(pause ? 'paused' : 'continued')

    property bool debug: Qak.debug

    // Debug visuals
    DebugVisual { }
}
