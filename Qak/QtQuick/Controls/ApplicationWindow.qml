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
    property bool allowFullscreen: true

    property bool resizable: true
    onResizableChanged: {
        if(!resizable) {
            maximumWidth = width
            maximumHeight = height

            minimumWidth = width
            minimumHeight = height
        } else {
            maximumWidth = 16777215
            maximumHeight = 16777215

            minimumWidth = 0
            minimumHeight = 0
        }
    }

    signal beforeScreenModeChange

    onScreenModeChanged: {
        if(allowFullscreen && screenMode == "full") {
            beforeScreenModeChange()
            showFullScreen()
        } else {
            beforeScreenModeChange()
            showNormal()
        }
//        Qak.debug("ApplicationWindow","onScreenModeChanged",screenMode) //¤qakdbg
    }

    function toggleScreenMode() {
        if(screenMode === "windowed")
           screenMode = "full"
        else
           screenMode = "windowed"
    }

    //onScreenChanged: Qak.debug("ApplicationWindow","onScreenChanged",screen) //-¤qakdbg (only available from Qt 5.9)
}
