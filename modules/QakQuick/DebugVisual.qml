import QtQuick 2.5

import QakQuick 1.0

Rectangle {
    anchors.fill: parent

    visible: Qak.debug
    enabled: visible

    color: "transparent"
    border.color: Qak.pause ? "red" : "tomato"
    border.width: 2
}
