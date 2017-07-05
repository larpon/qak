import QtQuick 2.0

import Qak 1.0

Rectangle {
    anchors { fill: parent }
    anchors.margins: -border.width

    visible: Qak.doDebug && enabled
    enabled: Qak.doDebug

    color: "transparent"
    border.color: Qak.paused ? "red" : "tomato"
    border.width: 2
}
