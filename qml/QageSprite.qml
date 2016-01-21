import QtQuick 2.5

SourceEntity {

    id: sprite

    //target: image

    Image {
        id: image
        //asynchronous: true
        anchors.fill: parent
    }

    AnimatedSprite {
        id: animatedSprite
    }

    Sprite {
        id: qtSprite
    }
}
