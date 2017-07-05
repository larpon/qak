import QtQuick 2.0

import Qak 1.0

// TODO work as PolygonMouseArea
Item {
    id: roundMouseArea

    property alias mouseX: mouseArea.mouseX
    property alias mouseY: mouseArea.mouseY

    property bool containsMouse: {
        if(!enabled)
            return false
        var x1 = width / 2;
        var y1 = height / 2;
        var x2 = mouseX;
        var y2 = mouseY;
        var distanceFromCenter = Math.pow(x1 - x2, 2) + Math.pow(y1 - y2, 2);
        var radiusSquared = Math.pow(Math.min(width, height) / 2, 2);
        var isWithinOurRadius = distanceFromCenter < radiusSquared;
        return isWithinOurRadius;
    }

    readonly property bool pressed: containsMouse && mouseArea.pressed

    signal clicked(var mouse)

//    DebugVisual { enabled: mouseArea.enabled; radius: width / 2 } //¤qakdbg

    MouseArea {
        id: mouseArea
        anchors { fill: parent }
        enabled: roundMouseArea.enabled
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: if (roundMouseArea.containsMouse) roundMouseArea.clicked(mouse)
    }

}
