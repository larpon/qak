import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Window 2.0

import Qak 1.0

ApplicationWindow {

    id: app

    title: qsTr('Qak (%1x%2)').arg(width).arg(height)

    //flags: Qt.FramelessWindowHint | Qt.CustomizeWindowHint

    visible: true

    //color: "transparent"
    color: "black"

    property bool paused: Qak.paused

    readonly property bool multiMonitor: multiMonitorHorizontal || multiMonitorVertical
    readonly property bool multiMonitorHorizontal: Screen.desktopAvailableWidth > Screen.width
    readonly property bool multiMonitorVertical: Screen.desktopAvailableHeight > Screen.height

    property string screenMode: "windowed"

    onScreenModeChanged: {
        if(screenMode == "full")
            showFullScreen()
        else if(screenMode == "windowed")
            showNormal()
        else
            showNormal()
        Qak.debug("ApplicationWindow","onScreenModeChanged",screenMode)
    }

    function toggleScreenMode() {
        if(screenMode === "windowed")
           screenMode = "full"
        else
           screenMode = "windowed"
    }

    onScreenChanged: Qak.debug("ApplicationWindow","onScreenChanged",screen)
}
