
import QtQuick 2.5

import "qml" as Qage

Qage.Core {
    id: core

    width: 800
    height: 400

    viewportWidth: 1100
    viewportHeight: 660

    canvas.width: 1400
    canvas.height: 700
    canvas.x: -(canvas.width-viewportWidth)/2
    canvas.y: -(canvas.height-viewportHeight)/2

    //color: "transparent"

    debug: true

    //fillmode: Image.Stretch

    Qage.Entity {
        id: entity
        anchors.fill: parent

        source: "canvas_test_1400x700.png"

        Image {
            anchors.fill: parent
            source: entity.adaptiveSource
        }
    }

    /*
    Qage.Entity {
        id: entity
        anchors.fill: parent

        source: "test.png"

        Image {
            anchors.fill: parent
            source: entity.adaptiveSource
        }
    }

    Qage.Image {
        id: errorTestSprite
        x: 500
        y: 500
        width: 120
        height: width
        source: "test_error.png"
        MouseArea {
            anchors.fill: parent
            onClicked: {

                errorTestSprite.source = "test.x-2.png"

                //canvas.rotation = 40
            }
        }
    }

    Qage.Image {
        id: error2TestSprite
        x: 400
        y: 400
        width: 120
        height: width
        MouseArea {
            anchors.fill: parent
            onClicked: {
                error2TestSprite.source = "test.png"
            }
        }
    }

    Qage.Image {
        id: testSprite1
        x: 20
        y: 350
        width: targetWidth*0.2
        height: targetHeight*0.2
        source: "test.png"
    }
*/
    Qage.Entity {
        x: 600
        y: 400
        width: 70
        height: width

        Rectangle {
            anchors.fill: parent
            color: "green"
        }

        DropArea {
            keys: [ "test_drop" ]
            anchors.fill: parent
            onDropped: {
                drop.accept()
            }
        }
    }

    Qage.Entity {

        x: 200
        y: 200
        width: 30
        height: width

        draggable: true
        Drag.keys: "test_drop"

        Rectangle {
            anchors.fill: parent
            color: "tomato"
        }
    }

    Qage.Entity {
        rotatable: true
        anchors.centerIn: parent
        width: 50
        height: width

        Rectangle {
            anchors.fill: parent
            color: "orange"

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 10
                color: "blue"
            }
        }
    }



    /*
    WalkPath {
        anchors.fill: parent

    }
    */
}
