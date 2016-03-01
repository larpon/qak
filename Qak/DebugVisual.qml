import QtQuick 2.5

import Qak 1.0

Rectangle {
    anchors.fill: parent
    anchors.margins: -border.width

    visible: Qak.debug
    enabled: visible

    color: "transparent"
    border.color: Qak.pause ? "red" : "tomato"
    border.width: 2
}
