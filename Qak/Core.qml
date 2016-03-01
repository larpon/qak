import Qak.QtQuick 1.0
import Qak.QtQuick.Controls 1.0

// ApplicationWindow from Qak.QtQuick.Controls
ApplicationWindow {

    default property alias content: canvas.data

    View { // Child Items of "View" can
        id: view

        anchors.fill: parent

        viewport.width: 1100
        viewport.height: 660

        Item {
            id: canvas
            anchors.fill: parent


        }
    }

}
