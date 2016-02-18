import QtQuick 2.5
import QtQuick.Controls 1.2
import QtQuick.Window 2.2

ApplicationWindow {

    id: app

    title: qsTr("QAK")+" ("+width+"x"+height+")"

     //flags: Qt.FramelessWindowHint | Qt.CustomizeWindowHint

    x: 2200
    y: (Screen.desktopAvailableHeight/2)-(height/2)

    width: 800
    height: 600

    //color: "transparent"
}
