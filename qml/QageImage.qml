import QtQuick 2.5

Image {
    id: image

    property alias realSource: image.source
    property alias source: sourceEntity.source

    SourceEntity {
        id: sourceEntity
        target: image
        targetSourceProperty: "realSource"
    }
}
