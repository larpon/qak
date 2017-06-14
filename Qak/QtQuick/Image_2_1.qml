import QtQuick 2.1

import Qak 1.0

Image {
    id: image

    readonly property real halfWidth: width/2
    readonly property real halfHeight: height/2

    readonly property real aspectRatio: width/height

    //sourceSize: optimize ? Qt.size(width,0) : undefined

    //property bool optimize: false

    // NOTE Neat trick to store the Image.source property before reassigning it
    property alias __targetSource: image.source
    property alias source: adaptive.source

    AdaptiveSource {
        id: adaptive
        target: image
        targetSourceProperty: "__targetSource"
    }

//    DebugVisual { } //¤qakdbg
}
