import QtQuick 2.5

Entity {

    id: entity

    property alias realSource: entity.source
    property alias source: adaptive.source

    AdaptiveSource {
        id: adaptive
        target: entity
        targetSourceProperty: "realSource"
    }

    Rectangle {
        id: error
        anchors.fill: parent
        visible: adaptive.error

        color: "lightgrey"
        border.color: "grey"
        border.width: 3
    }


}
