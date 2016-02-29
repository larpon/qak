import QtQuick 2.5

import Qak 1.0

Image {
    id: image

    // NOTE Neat trick to store the Image.source property before reassigning it
    property alias __targetSource: image.source
    property alias source: adaptive.source

    AdaptiveSource {
        id: adaptive
        target: image
        targetSourceProperty: "__targetSource"
    }

    DebugVisual { }
}
