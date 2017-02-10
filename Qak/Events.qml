import Qak.QtQuick 2.0

Item {

    default property alias content: viewport.data

    readonly property alias viewport: viewport

    property bool mattes: true
    property color mattesColor: "black"

    Viewport {
        id: viewport

        width: 1100
        height: 660
    }

    // Mattes (black boxes / letterboxing)

    // Left box
    Rectangle {
        enabled: visible
        visible: mattes
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: viewport.left
        anchors.bottom: parent.bottom
        color: mattesColor
    }

    // Top box
    Rectangle {
        enabled: visible
        visible: mattes
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: viewport.top
        color: mattesColor
    }

    // Right box
    Rectangle {
        enabled: visible
        visible: mattes
        x: viewport.x+viewport.scaledWidth; y: viewport.y
        width: parent.width - x
        height: viewport.scaledHeight
        color: mattesColor
    }

    // Bottom box
    Rectangle {
        enabled: visible
        visible: mattes
        x: 0; y: viewport.y+viewport.scaledHeight
        width: parent.width
        height: parent.height - y
        color: mattesColor
    }
}
