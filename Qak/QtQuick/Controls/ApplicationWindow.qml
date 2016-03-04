import QtQuick 2.5
import QtQuick.Controls 1.2
import QtQuick.Window 2.2

import Qak 1.0

ApplicationWindow {

    id: app

    title: qsTr('Qak (%1x%2)').arg(width).arg(height)

    x: multiMonitor ? (Screen.desktopAvailableWidth/2)+(Screen.width/2)-(width/2) : (Screen.width/2)-(width/2)
    y: (Screen.desktopAvailableHeight/2)-(height/2)

    width: 800
    height: 600

    //flags: Qt.FramelessWindowHint | Qt.CustomizeWindowHint

    visible: true

    //color: "transparent"
    color: "black"

    property bool pause: Qak.pause

    property bool multiMonitor: (Screen.desktopAvailableWidth > Screen.width) ? true : false

    property string screenMode: "windowed"

    onScreenModeChanged: {
        if(screenMode == "full")
            app.showFullScreen()
        else if(app.screenMode == "windowed")
            app.showNormal()
        else
            app.showNormal()
        Qak.log("ApplicationWindow","Screen mode",screenMode)
    }


    function toggleScreenMode() {
        if(screenMode === "windowed")
           screenMode = "full"
        else
           screenMode = "windowed"
    }

    //onScreenChanged: Qak.log("ApplicationWindow","Screen",screen)
}
