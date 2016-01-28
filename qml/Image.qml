import QtQuick 2.5

Image {
    id: image

    property alias realSource: image.source
    property alias source: adaptive.source
    AdaptiveSource {
        id: adaptive
        target: image
        targetSourceProperty: "realSource"
    }
}
