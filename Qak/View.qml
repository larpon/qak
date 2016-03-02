import Qak.QtQuick 1.0

Item {

    default property alias content: viewport.data

    readonly property alias viewport: viewport

    Viewport {
        id: viewport

        width: 1100
        height: 660

    }
}
