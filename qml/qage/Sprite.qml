import QtQuick 2.5

Sprite {
    id: sprite

    property alias realSource: sprite.source
    property alias source: adaptive.source
    AdaptiveSource {
        id: adaptive
        target: sprite
        targetSourceProperty: "realSource"
    }
}
